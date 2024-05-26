# frozen_string_literal: true

module Twitch
  # @!attribute [r] sender
  #   @return [Channel] Sender of the message
  # @!attribute [r] channel
  #  @return [Channel] Channel the message was sent to
  # @!attribute [r] content
  #   @return [String] Content of the message
  # @!attribute [r] raw
  #   @return [String] Raw message from Twitch
  # @example
  #   message = Twitch::Message.new(":justinfan!justinfan@justinfan.tmi.twitch.tv PRIVMSG #twitchgaming :Hello world!\r\n")
  #   message.sender.name  # => :justinfan
  #   message.channel.name # => :twitchgaming
  #   message.content      # => "Hello world!"
  #   message.raw          # => ":justinfan!justinfan@justinfan.tmi.twitch.tv PRIVMSG #justinfan :Hello world!\r\n"
  class Message < String
    attr_reader :sender, :channel, :content, :raw

    # @param raw [String] Raw IRC websocket message from Twitch
    # @param connection [Bot, nil] For internal usage
    # @example
    #   message = Twitch::Message.new(":justinfan!justinfan@justinfan.tmi.twitch.tv PRIVMSG #twitchgaming :Hello world!\r\n")
    def initialize(raw, connection: nil)
      split = raw.split(" ")
      content = split[3..-1].join(" ")[1..-1]
      super(content)

      @content = content
      @connection = connection
      @channel = Channel.new(split[2][1..-1], connection: connection)
      @sender = Channel.new(split[0].split("!")[0][1..-1])
      @raw = raw
    end

    alias_method :text, :content
    alias_method :streamer, :channel
    alias_method :user, :sender

    USERNAME = /[a-zA-Z0-9_]{4,25}/
    # @return [Array<Twitch::Channel>] List of usernames mentioned in the message
    def mentions
      return @mentions if @mentions

      @mentions = []
      @content.split(" ").each do |word|
        match = word.match(/@#{USERNAME}/)
        next unless match

        @mentions << Channel.new(match[0][1..-1], connection: @connection)
      end

      @mentions
    end

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
