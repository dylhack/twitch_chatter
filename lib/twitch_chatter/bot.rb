# frozen_string_literal: true

module Twitch
  # @example
  #   bot = Twitch::Bot.new
  #
  #   bot.ready do
  #     puts "Ready!"
  #   end
  #
  #   bot.join(:twitchgaming) do |message|
  #     puts "#{message.channel} #{message.user}: #{message.text}"
  #   end
  #
  #   bot.start
  class Bot
    # Default options for Twitch websocket. Nicknames starting with "justinfan" are considered anonymous.
    # @api private
    DEFAULT_OPTIONS = {
      nick: "justinfan0735",
      websocket_url: "wss://irc-ws.chat.twitch.tv:443",
    }.freeze

    include Concerns::Channels

    def initialize(**options)
      @nick = options[:nick] || DEFAULT_OPTIONS[:nick]
      @websocket_url = Async::HTTP::Endpoint.parse(options[:websocket_url] || DEFAULT_OPTIONS[:websocket_url])
    end

    # @yield
    # @yieldparam
    def ready(&block)
      @ready_handle = block
    end

    # @return [Boolean]
    def ready?
      @ws != nil
    end

    # @return [Async::Task]
    def start
      Async do
        Async::WebSocket::Client.connect(@websocket_url) do |ws|
          @ws = ws
          ws.write("NICK #{@nick}")
          resume_pending
          @ready_handle&.call

          while (ws_message = ws.read)
            data = ws_message.to_str
            if data.start_with?("PING")
              ws.write("PONG :tmi.twitch.tv")
              next
            end

            next unless data.include?("PRIVMSG")

            message = Message.new(data, connection: self)
            @message_handle&.call(message)
            streams[message.channel.to_sym].each do |block|
              block.call(message)
            end
          end
        end
      end
    end
  end
end
