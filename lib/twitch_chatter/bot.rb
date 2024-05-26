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
          dispatch_ready

          while (ws_message = ws.read)
            data = ws_message.to_str
            if data.start_with?("PING")
              ws.write("PONG :tmi.twitch.tv")
              next
            end

            next unless data.include?("PRIVMSG")

            dispatch(Message.new(data, connection: self))
          end
        end
      end
    end

    # @return [Array<Symbol>]
    def channels
      streams.keys
    end

    # @yield
    # @yieldparam streamer [Symbol]
    # @yieldreturn [nil]
    def joined(&block)
      @join_handle = block
    end

    # @yield
    # @yieldparam streamer [Symbol]
    # @yieldreturn [nil]
    def left(&block)
      @leave_handle = block
    end

    # @param streamer [Symbol, String]
    # @yield
    # @yieldparam message [Twitch::Message]
    # @yieldreturn [nil]
    # @example
    #   bot.join(:twitchgaming) do |message|
    #     puts "##{message.channel} #{message.sender}: #{message}"
    #   end
    def join(streamer, &block)
      streamer = streamer.to_sym
      unless ready?
        yield_join(streamer, &block)
        return
      end

      streams[streamer] = [] unless streams.key?(streamer)
      streams[streamer] << block if block_given?
      @ws.write("JOIN ##{streamer}")
      @join_handle&.call(streamer)
    end

    # @param streamer [Symbol, String]
    # @example
    #   bot.leave(:twitchgaming)
    def leave(streamer)
      streamer = streamer.to_sym
      streams[streamer] = []
      @ws.write("PART ##{streamer}")
      @leave_handle&.call(streamer)
    end

    # @yield
    # @yieldparam message [Twitch::Message]
    # @yieldreturn [nil]
    # @example
    #   bot.message do |message|
    #     puts "##{message.channel} #{message.sender}: #{message}"
    #   end
    def message(&block)
      @message_handle = block
    end

    alias_method :part, :leave
    alias_method :on_leave, :leave
    alias_method :on_join, :joined
    alias_method :on_message, :message

    private

    def dispatch(message)
      @message_handle&.call(message)
      streams[message.channel.to_sym].each do |block|
        block.call(message)
      end
    end

    def dispatch_ready
      join_all
      @ready_handle&.call
    end

    def streams
      @streams ||= {}
    end

    def pending
      @pending ||= {}
    end

    def yield_join(streamer, &block)
      pending[streamer] = [] if streamer
      pending[streamer] << block
    end

    def join_all
      pending.each do |streamer, blocks|
        blocks.each { |block| join(streamer, &block) }
      end
    end
  end
end
