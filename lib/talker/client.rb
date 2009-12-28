require "eventmachine"
require "yajl"

module Talker
  class Client < EM::Connection
    CALLBACKS = %w( connected message private_message join idle back leave presence error close event )
    
    class Error < RuntimeError; end
    
    attr_accessor :connect_options, :thread, :current_user
    
    def self.connect(options={})
      host = options.delete(:host) || "talkerapp.com"
      port = (options.delete(:port) || 8500).to_i
      
      thread = Thread.new { EM.run } unless EM.reactor_running?
      
      connection = EM.connect host, port, self do |c|
        c.thread = thread
        c.connect_options = options
        yield c if block_given?
      end
      
      thread.join if thread
      
      connection
    end
    
    def initialize
      @users = {}
    end
    
    # Callbacks
    CALLBACKS.each do |method|
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
    
    def find_user!(user_name)
      @users.values.detect { |user| user["name"] == user_name } || raise(Error, "User #{user_name} not found")
    end
    
    def send_private_message(to, message)
      if to.is_a?(String)
        user_id = find_user!(to)["id"]
      else
        user_id = to
      end
      send_message message, :to => user_id
    end
    
    def leave
      send :type => "close"
      close
    end
    
    def close
      close_connection_after_writing
    end
    
    
    ## EventMachine callbacks
    
    def connection_completed
      send @connect_options.merge(:type => "connect")
      EM.add_periodic_timer(20) { send :type => "ping" }
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
        trigger :event, event
        
        case event["type"]
        when "connected"
          @current_user = event["user"]
          trigger :connected, event["user"]
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
          if event["private"]
            trigger :private_message, event["user"], event["content"]
          else
            trigger :message, event["user"], event["content"]
          end
        else
          raise Error, "unknown event type received from server: " + event["type"]
        end
      
      rescue
        close
        raise
      end
      
      def trigger(callback, *args)
        callback = instance_variable_get(:"@on_#{callback}")
        callback.call(*args) if callback
      end
      
      def send(data)
        send_data Yajl::Encoder.encode(data) + "\n"
      end
  end
end
