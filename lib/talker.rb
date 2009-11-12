require "eventmachine"
require "yajl"

class Talker < EM::Connection
  class Error < RuntimeError; end
  
  attr_accessor :room, :token, :thread
  
  def self.connect(options={})
    host = options[:host] || "talkerapp.com"
    port = (options[:port] || 8500).to_i
    room = options[:room].to_i
    token = options[:token]
    
    thread = Thread.new { EM.run } unless EM.reactor_running?
    
    EM.connect host, port, self do |c|
      c.thread = thread
      c.room = room
      c.token = token
      yield c if block_given?
    end
    
    thread.join unless thread.nil?
  end
  
  def initialize
    @users = {}
  end
  
  # Callbacks
  %w( connected message join idle back leave presence error close ).each do |method|
    class_eval <<-EOS
      def on_#{method}(&block)
        @on_#{method} = block
      end
    EOS
  end
  
  def users
    @users.values
  end
  
  def send_message(message, attributes={})
    send({ :type => "message", :content => message }.merge(attributes))
  end
  
  def send_private_message(to, message)
    if to.is_a?(String)
      user = @users.values.detect { |user| user["name"] == to }
      raise Error, "User #{to} not found" unless user
      user_id = user["id"]
    else
      user_id = to
    end
    send_message message, :to => user_id
  end
  
  
  ## EventMachine callbacks
  
  def connection_completed
    send :type => "connect", :room => @room, :token => @token
    EM.add_periodic_timer(20) { send :type => "ping" }
  end
  
  def leave
    send :type => "close"
    close
  end
  
  def close
    close_connection_after_writing
  end
  
  def post_init
    @parser = Yajl::Parser.new
    @parser.on_parse_complete = method(:event_parsed)
  end
  
  def receive_data(data)
    @parser << data
  end
  
  def unbind
    trigger :close
    @thread.kill if @thread
  end
  
  
  private
    def event_parsed(event)
      case event["type"]
      when "connected"
        trigger :connected
      when "error"
        if @on_error
          @on_error.call(event["message"])
        else
          raise Error, event["message"]
        end
      when "users"
        event["users"].each do |user|
          @users[user["id"]] = user
        end
        trigger :presence, @users.values
      when "join"
        @users[event["user"]["id"]] = event["user"]
        trigger :join, event["user"]
      when "leave"
        @users.delete(event["user"]["id"])
        trigger :leave, event["user"]
      when "idle"
        trigger :idle, event["user"]
      when "back"
        trigger :back, event["user"]
      when "message"
        @users[event["user"]["id"]] ||= event["user"]
        trigger :message, event["user"], event["content"], event
      else
        raise Error, "unknown event type received from server: " + event["type"]
      end
    rescue
      close
      raise
    end
    
    def trigger(callback, *args)
      callback = instance_variable_get(:"@on_#{callback}")
      callback.call(*args[0,callback.arity]) if callback
    end
    
    def send(data)
      send_data Yajl::Encoder.encode(data) + "\n"
    end
end
