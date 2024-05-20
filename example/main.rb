# frozen_string_literal: true

require_relative "../lib/twitch_chatter"

puts "What streamer would you like to join?"
bot = Twitch::Bot.new
streamer = gets.chomp

bot.ready do
  puts "Ready!"
end

bot.left do |streamer|
  puts "Left #{streamer}"
end

bot.joined do |streamer|
  puts "Joined #{streamer}"
end

bot.join(streamer) do |message|
  puts "##{message.channel} #{message.user}: #{message.text}"
end

bot.start
