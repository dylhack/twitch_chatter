# frozen_string_literal: true

module Twitch
  # @!attribute [r] name
  #  @return [Symbol] Name of the channel
  # @example
  #   channel = Twitch::Channel.new(:twitchgaming)
  class Channel
    # @return [String]
    attr_reader :name

    # @param [String, Symbol] name
    # @param [Bot, nil] bot
    def initialize(name, bot: nil)
      @name = name.to_sym
      @bot = bot
    end

    # (see Bot#join)
    def join(&block)
      @bot.join(@name, &block)
    end

    # (see Bot#join)
    def leave
      @bot.leave(@name)
    end

    # @return [Symbol]
    def to_sym
      @name
    end

    # @return [String]
    def to_s
      @name.to_s
    end

    # @return [String]
    def to_url
      "https://twitch.tv/#{@name}"
    end

    alias_method :link, :to_url
    alias_method :href, :to_url

    # @param [Channel, String, Symbol] other
    # @return [Boolean]
    def ==(other)
      if other.is_a?(Channel)
        return @name == other.name
      end

      @name == other.to_sym
    end
  end
end
