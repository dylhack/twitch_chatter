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
  #   message = Twitch::Message.new(":ttlnow!ttlnow@ttlnow.tmi.twitch.tv PRIVMSG #ttlnow :Hello world!\r\n")
  #   message.sender.name  # => :ttlnow
  #   message.channel.name # => :ttlnow
  #   message.content      # => "Hello world!"
  #   message.raw          # => ":ttlnow!ttlnow@ttlnow.tmi.twitch.tv PRIVMSG #ttlnow :Hello world!\r\n"
  class Message < String
    attr_reader :sender, :channel, :content, :raw

    # @param raw [String] Raw IRC websocket message from Twitch
    # @param connection [Bot, nil] For internal usage
    # @example
    #   message = Twitch::Message.new(":ttlnow!ttlnow@ttlnow.tmi.twitch.tv PRIVMSG #ttlnow :Hello world!\r\n")
    def initialize(raw, connection: nil)
      split = raw.split(" ")
      content = split[3..-1].join(" ")[1..-1]
      super(content)

      @content = content
      @channel = Channel.new(split[2][1..-1], connection: connection)
      @sender = Channel.new(split[0].split("!")[0][1..-1])
      @raw = raw
    end

    alias_method :text, :content
    alias_method :streamer, :channel
  end
end
