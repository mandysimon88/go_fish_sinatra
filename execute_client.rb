require './lib/client.rb'

def over?
  @client.socket.closed?
end

@client = Client.new
@client.start

loop do
  @client.puts_message
  @client.give_input_when_asked
end


# These will block each other and prevent the program from running
# putsing = Thread.new {
#   loop do
#     sleep 2
#     @client.puts_message
#   end
# }
#
# getsing = Thread.new {
#   loop do
#     sleep 2
#     input = gets.chomp
#     @client.provide_input(input)
#   end
# }
#
# loop do
#   Thread.kill(putsing) if over?
#   Thread.kill(getsing) if over?
# end
