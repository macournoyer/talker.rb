require File.dirname(__FILE__) + "/spec_helper"

EM.describe Talker do
  it "should connect" do
    connect do |client|
      client.on_connected do
        done
      end
    end
  end
  
  it "should close" do
    connect do |client|
      client.on_connected do
        client.close
      end
      client.on_close do
        done
      end
    end
  end
  
  it "should receive presence" do
    connect do |client|
      client.on_presence do |users|
        users.size.should >= 1
        users.map { |user| user["name"] }.should include(TALKER_CONFIG["user_name"])
        done
      end
    end
  end

  it "should send and receive message" do
    connect do |client|
      client.on_connected do
        client.send_message "it works, magic!"
      end
      client.on_message do |user, message|
        message.should == "it works, magic!"
        done
      end
    end
  end
  
  it "should send and receive private message" do
    connect do |client|
      client.on_presence do
        client.send_private_message TALKER_CONFIG["user_name"], "private magic"
      end
      client.on_message do |user, message|
        message.should == "private magic"
        done
      end
    end
  end
  
  # Keep at the end, mmmkay?
  it "should leave" do
    connect do |client|
      client.on_connected do
        client.leave
      end
      client.on_close do
        done
      end
    end
  end
end