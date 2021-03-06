require 'spec_helper'

describe Client do
  let(:client) { Client.new }
  let(:client2) { Client.new }
  let(:server) { Server.new }

  def capture_stdout(&blk)
    old = $stdout
    $stdout = fake = StringIO.new
    blk.call
    fake.string
  ensure
    $stdout = old
  end

  def provide_stdin(input = "", &blk)
    old = $stdin
    $stdin = StringIO.new
    $stdin << input
    $stdin.rewind
    blk.call
  ensure
    $stdin = old
  end

  it 'does nothing when initialized' do
    expect { client }.to_not raise_exception
  end

  it '#start tries to connect to the server, with new socket attribute' do
    begin
      client.start
    rescue => e
      expect(e.message).to match(/connection refused/i)
    end
  end

  context 'server started' do
    before do
      server.start
    end

    after do
      server.stop
    end

    it 'makes a connection when started' do
      expect { client.start }.to_not raise_exception
    end

    context 'server and client started, connection accepted' do
      before do
        client.start
        @client_socket = server.accept
      end

      it 'can receive messages and display them ' do
        output = capture_stdout do
          expect { client.puts_message }.to_not raise_exception
        end
        expect(output.size).to be > 0
        output = capture_stdout do
          expect { client.puts_message }.to_not raise_exception
        end
        expect(output.size).to be 0
      end

      it 'provides input' do
        client.provide_input("yes")
        expect(server.get_input(@client_socket)).to eq "yes"
      end

      it 'gives input when asked' do
        provide_stdin("Fred\n") do
          client.give_input_when_asked
          expect(server.get_input(@client_socket)).to eq "Fred"
        end
      end
    end
  end

  context 'second user is connected and game is in progress' do
    let!(:match) { create(:match) }

    before do
      server.start
      client.start
      client2.start
      @client_socket = server.socket.accept
      @client2_socket = server.socket.accept
      match.users[0].client = @client_socket
      match.users[1].client = @client2_socket
      match.game.deal
    end

    after do
      @client_socket.close
      @client2_socket.close
      server.stop
    end

    it 'interprets json and prints match state' do
      server.tell_match(match)
      putted = capture_stdout { client.puts_message }
      # build expect for new style json ouput
    end

    it 'interprets json and prints player state correctly' do
      server.tell_player_his_view(match, match.users[0])
      putted = capture_stdout { client.puts_message }
      # build expect for new style json ouput
    end

    it 'turns an array of card strings into a simple string' do
      expect(client.seriesify(["one", "two", "three"])).to eq "one, two and three"
    end
  end
end
