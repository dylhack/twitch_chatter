# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = "twitch_chatter"
  s.version     = "0.2.2"
  s.licenses    = ["MIT"]
  s.summary     = "Read-only Twitch chat client."
  s.description = "A Ruby gem for Twitch's chat IRC websocket"
  s.authors     = ["Dylan Hackworth"]
  s.email       = "me@dylhack.dev"
  s.files       = Dir.glob(["{lib}/**/*"], File::FNM_DOTMATCH, base: __dir__)
  s.homepage    = "https://github.com/dylhack/twitch_chatter"
  s.metadata    = { "source_code_uri" => "https://github.com/dylhack/twitch_chatter" }
  s.required_ruby_version = ">=3.1.1"
  s.add_dependency("async-websocket", "~> 0.26.1")
end
