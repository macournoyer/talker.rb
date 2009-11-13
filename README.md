# Talker Ruby Client
A real-time Talker Ruby client.

# Usage
1) Get a Talker account at https://talkerapp.com/signup

2) Get your Talker Token on https://myaccount.talkerapp.com/settings

3) Find the Room ID you want to connect to. This is the last part of the URL:

     https://myaccount.talkerapp.com/rooms/<room_id>

4) Serve hot and enjoy

    Talker.connect(:room => ROOM_ID, :token => YOUR_TALKER_TOKEN) do |client|
      client.on_connected do
        client.send_message "hello!"
      end
      
      client.on_message do |user, message|
        puts user["name"] + ": " + message
      end
      
      trap("INT") { client.close }
    end

# Callbacks
All arguments are optional.

## <code>on_connected(user)</code>
Called when the user is authenticated and ready to receive events. "user" is a Hash containing your user info: <code>{"id"=>1, "name"=>"macournoyer", "email"=>"macournoyer@talkerapp.com"}</code>.

## <code>on_presence(users)</code>
Called after <code>on_connected</code> with the list of connected users.
With <code>users</code> being something like this:

    [{"id"=>1, "name"=>"macournoyer", "email"=>"macournoyer@talkerapp.com"},
     {"id"=>2, "name"=>"gary", "email"=>"gary@talkerapp.com"}]

## <code>on_message(user, message)</code>
Called when a new message is received.
<code>user</code> is the sender.

## <code>on_private_message(user, message)</code>
Called when a new private message is received.
<code>user</code> is the sender.

## <code>on_join(user)</code>
Called when a user joins the room.

## <code>on_idle(user)</code>
Called when a user becomes idle (closed connection without leaving).

## <code>on_back(user)</code>
Called when a user is back from idle.

## <code>on_leave(user)</code>
Called when a user leaves.

## <code>on_close</code>
Called when the connection is closed.

## <code>on_error(error_message)</code>
Called when an error is received from the Talker server.

## <code>on_event(event)</code>
Called when any kind of event (all of the above) is received. "event" is a Hash: <code>{"type":"event type",... event specific attributes}</code>.

# Methods
Methods of an instance of Talker class.

## <code>users</code>
Array of users currently in the room. In the form:

    [{"id"=>1, "name"=>"macournoyer", "email"=>"macournoyer@talkerapp.com"},
     {"id"=>2, "name"=>"gary", "email"=>"gary@talkerapp.com"}]

## <code>leave</code>
Leave the room and close the connection.

## <code>close</code>
Close the connection without leaving the room.

## <code>send_message(message)</code>
Send a message.

## <code>send_private_message(user_name, message)</code>
Send a private message to <code>user_name</code>.

# Running the specs
Howdy brave lil' one! To run the specs you'll need courage, hard work and some luck:

1) Install from source my "special" fork of em-spec at http://github.com/macournoyer/em-spec.

2) Edit the file spec/talker.example.yml with your info and rename it to spec/talker.yml.

3) Run <code>rake</code> and everything should be green, birds should start signing and someone will make you a chocolate cake

(results may vary).

# Credits & License
Released under the Ruby License, (c) Talker

Thanks to http://github.com/raggi for kicking this off.
