require 'cinch'
require 'cinch/cooldown'
require 'active_support'
require 'json'
require 'net/http'
require 'uri'

class Twitch
  include Cinch::Plugin
  include ActiveSupport::Inflector

  enforce_cooldown

  match /follow (.+)/, method: :follow
  match /source/, method: :source
<<<<<<< HEAD
  match /host (.+)/, method: :host
  match /synthesis/, method: :synthesis
  match /commands/, methods: :commands
=======
>>>>>>> 9f0bae82460281362cc4c399d7eb70c923e55bd3

  def follow(m, plug)
    if mod?(m) 
      3.times { m.reply "Hey Chat! You should follow https://www.twitch.tv/#{plug} !" }
    end
  end

  def source(m)
    m.reply ".w #{m.user} I'm written in Ruby and my developer accepts pull reqs that resolve active issues or feature requests."
    m.reply ".w #{m.user} You can find my source code here: https://github.com/aetaric/aetbot ."
  end

<<<<<<< HEAD
  def host(m, target)
    if mod?(m)
      m.reply ".host #{target}"
    end
  end

  def synthesis(m)
    m.reply "synthesis is a team: https://www.twitch.tv/team/synthesis  Twitter: https://twitter.com/synthesistwitch"
  end

  def commands(m)
    if mod?(m)
      m.reply ".w #{m.user} My Commands are here: https://gist.githubusercontent.com/aetaric/df04e55c159baabafc2194f8516715fc/raw/e77e5db52718db1ca48cea64f3ccdb3c1c59e13f/gistfile1.txt"
    end
  end
=======
  def barrier(m)
    m.reply "@#{m.user} Barrier skip involves canceling your knockback by using the wind waker normally given by the barrier. Using item slide and the perfect angle you can phase through the barrier using a specific speed in which a portion of the barrier doesn't check for."
  end

>>>>>>> 9f0bae82460281362cc4c399d7eb70c923e55bd3
end
