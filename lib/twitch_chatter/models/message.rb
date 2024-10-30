# frozen_string_literal: true

module Twitch
  # @example
  #   message = Twitch::Message.new(":justinfan!justinfan@justinfan.tmi.twitch.tv PRIVMSG #twitchgaming :Hello world!\r\n")
  #   message.sender.name  # => :justinfan
  #   message.channel.name # => :twitchgaming
  #   message.content      # => "Hello world!"
  #   message.raw          # => ":justinfan!justinfan@justinfan.tmi.twitch.tv PRIVMSG #justinfan :Hello world!\r\n"
  class Message
    # @return [Channel] Sender of the message
    attr_reader :sender
    # @return [Channel] Channel the message was sent to
    attr_reader :channel
    # @return [String] Content of the message
    attr_reader :content
    # @return [String] Raw message from Twitch
    attr_reader :raw

    # @param raw [String] Raw IRC websocket message from Twitch
    # @param bot [Bot, nil] bot
    # @example
    #   message = Twitch::Message.new(":justinfan!justinfan@justinfan.tmi.twitch.tv PRIVMSG #twitchgaming :Hello world!\r\n")
    def initialize(raw, bot: nil)
      split = raw.split(" ")
      content = split[3..-1].join(" ")[1..-1]

      @content = content
      @bot = bot
      @channel = Channel.new(split[2][1..-1], bot: bot)
      @sender = Channel.new(split[0].split("!")[0][1..-1], bot: bot)
      @raw = raw
    end

    alias_method :text, :content
    alias_method :streamer, :channel
    alias_method :user, :sender

    # Username regexp
    # @api private
    USERNAME = /[a-zA-Z0-9_]{4,25}/
    # @return [Array<Twitch::Channel>] List of usernames mentioned in the message
    def mentions
      return @mentions if @mentions

      @mentions = []
      @content.split(" ").each do |word|
        match = word.match(/@#{USERNAME}/)
        next unless match

        @mentions << Channel.new(match[0][1..-1], bot: @bot)
      end

      @mentions
    end

    # Link regexp
    # @api private
    LINK = %r{(https?://[^\s]+)}
    # @return [Array<String>] List of links mentioned in the message
    # @example
    #   bot.join(:twitchgaming) do |message|
    #     if message.links.any?
    #       puts "Links: #{message.links.join(", ")}"
    #     end
    #   end
    def links
      return @links if @links

      @links = []
      @content.split(" ").each do |word|
        match = word.match(LINK)
        next unless match

        @links << match[0]
      end

      @links
    end
  end
end
