# frozen_string_literal: true

module Twitch
  # @!attribute [r] name
  #  @return [Symbol] Name of the channel
  # @example
  #   channel = Twitch::Channel.new("twitchgaming")
  class Channel
    attr_reader :name

    # @param name [String, Symbol]
    # @param connection [Bot, nil] For internal usage
    def initialize(name, connection: nil)
      @name = name.to_sym
      @connection = connection
    end

    # @yield
    # @yieldparam message [Twitch::Message]
    # @return [nil]
    def join(&block)
      @connection.join(@name, &block)
    end

    # @return [nil]
    def leave
      @connection.leave(@name)
    end

    # @return [Symbol]
    def to_sym
      @name
    end

    # @return [String]
    def to_s
      @name.to_s
    end

    # @param other [Channel, Symbol]
    # @return [Boolean]
    def ==(other)
      if other.is_a?(Channel)
        return @name == other.name
      end

      @name == other.to_sym
    end
  end
end
