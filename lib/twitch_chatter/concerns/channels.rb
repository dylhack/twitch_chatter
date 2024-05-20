# frozen_string_literal: true

module Twitch
  # Mixin modules
  # @private
  module Concerns
    # Mixin for channel-related methods
    # @private
    module Channels
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

      def resume_pending
        pending.each do |streamer, blocks|
          blocks.each { |block| join(streamer, &block) }
        end
      end
    end
  end
end
