# frozen_string_literal: true

require "rspec"
require_relative "../lib/twitch_chatter"

def message(channel:, sender:, content:)
  {
    raw: ":#{sender}!#{sender}@#{sender}.tmi.twitch.tv PRIVMSG ##{channel} :#{content}\r\n",
    content: content,
    channel: channel,
    sender: sender,
  }
end

describe Twitch::Message do
  it "parses a message" do
    sample = message(channel: "twitchgaming", sender: "justinfan", content: "Hello world!")
    result = Twitch::Message.new(sample[:raw])

    expect(result.channel).to(eq(sample[:channel]))
    expect(result.sender).to(eq(sample[:sender]))
    expect(result.content).to(eq(sample[:content]))
  end

  it "parses all links" do
    sample = message(
      channel: "twitchgaming",
      sender: "justinfan",
      content: "Checkout this cool site https://kagi.com & https://coolors.co/?home",
    )
    result = Twitch::Message.new(sample[:raw])

    expect(result.channel).to(eq(sample[:channel]))
    expect(result.sender).to(eq(sample[:sender]))
    expect(result.content).to(eq(sample[:content]))
    expect(result.links).to(eq(["https://kagi.com", "https://coolors.co/?home"]))
  end

  it "parses all mentions" do
    sample = message(channel: "twitchgaming", sender: "justinfan", content: "Hey @twitchgaming, @piratesoftware!")
    result = Twitch::Message.new(sample[:raw])

    expect(result.channel).to(eq(sample[:channel]))
    expect(result.sender).to(eq(sample[:sender]))
    expect(result.content).to(eq(sample[:content]))
    expect(result.mentions).to(eq(["twitchgaming", "piratesoftware"]))
  end
end
