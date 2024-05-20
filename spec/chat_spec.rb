# frozen_string_literal: true

require "rspec"
require_relative "../lib/twitch_chatter"

describe Twitch::Message do
  it "parses a message" do
    [
      {
        sample: ":justinfan!justinfan@justinfan.tmi.twitch.tv PRIVMSG #twitchgaming :Hello world!\r\n",
        answer: { streamer: :twitchgaming, content: "Hello world!", sender: :justinfan },
      },
    ].each do |content|
      result = Twitch::Message.new(content[:sample])

      expect(result.channel).to(eq(content.dig(:answer, :streamer)))
      expect(result.sender).to(eq(content.dig(:answer, :sender)))
      expect(result).to(eq(content.dig(:answer, :content)))
    end
  end
end
