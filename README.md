
```sh
bundle add twitch_chatter
```

- [Documentation](https://rubydoc.info/gems/twitch_chatter)

# Example Usage

```ruby
require "twitch_chatter"

bot = Twitch::Bot.new

bot.ready do
  puts "Ready!"
end

bot.join(:piratesoftware) do |message|
  puts "##{message.channel} #{message.user}: #{message.text}"
end

bot.start
```

