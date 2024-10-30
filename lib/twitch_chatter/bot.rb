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

    # @see [DEFAULT_OPTIONS]
    def initialize(**options)
      @nick = options[:nick] || DEFAULT_OPTIONS[:nick]
      @websocket_url = Async::HTTP::Endpoint.parse(options[:websocket_url] || DEFAULT_OPTIONS[:websocket_url])
    end

    # Dispatched on websocket connect, but before channel joins
    # @yield [nil]
    def ready(&block)
      @ready_handle = block
    end

    # If we're connected to Twitch's websocket
    # @return [Boolean]
    def ready?
      @ws != nil
    end

    # Begin pulling messages
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

            dispatch(Message.new(data, bot: self))
          end
        end
      end
    end

    alias_method :run, :start

    # @return [Array<Symbol>]
    def channels
      streams.keys.map { |s| Channel.new(s, bot: self) }
    end

    # @yieldparam [Symbol] streamer
    def joined(&block)
      @join_handle = block
    end

    # @yieldparam [Symbol] streamer
    def left(&block)
      @leave_handle = block
    end

    # @param streamer [Symbol, String]
    # @yieldparam message [Twitch::Message]
    # @return [nil]
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
      nil
    end

    # Disconnects from channel and removes all message callbacks.
    # @param streamer [Symbol, String]
    # @return [nil]
    # @example
    #   bot.leave(:twitchgaming)
    def leave(streamer)
      return unless ready?

      streamer = streamer.to_sym
      streams[streamer] = []
      @ws.write("PART ##{streamer}")
      @leave_handle&.call(streamer)
      nil
    end

    # @yieldparam message [Twitch::Message]
    # @example
    #   bot.message do |message|
    #     puts "##{message.channel} #{message.sender}: #{message}"
    #   end
    def message(&block)
      @message_handle = block
    end

    alias_method :part, :leave
    alias_method :on_leave, :left
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
      @ready_handle&.call
      join_all
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
