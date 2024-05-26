
```sh
gem install twitch_chatter
```

- [Documentation](https://rubydoc.info/gems/twitch_chatter)

# Example Usage

```ruby
require "twitch_chatter"

STREAMER = :piratesoftware
bot = Twitch::Bot.new

bot.ready do
  puts "Ready!"
end

bot.left do |streamer|
  puts "Left #{streamer}"
end

bot.joined do |streamer|
  puts "Joined #{streamer}"
end

bot.join(STREAMER) do |message|
  puts "##{message.channel} #{message.user}: #{message.text}"
end

bot.start
```

