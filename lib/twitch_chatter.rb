# frozen_string_literal: true

require "async"
require "async/http/endpoint"
require "async/websocket/client"
require_relative "twitch_chatter/models"
require_relative "twitch_chatter/bot"

# @author Dylan Hackworth <me@dylhack.dev>
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
module Twitch
end
