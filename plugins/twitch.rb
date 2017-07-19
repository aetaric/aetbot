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

  def follow(m, plug)
    if mod?(m) 
      3.times { m.reply "Hey Chat! You should follow https://www.twitch.tv/#{plug} !" }
    end
  end

  def source(m)
    m.reply ".w #{m.user} I'm written in Ruby and my developer accepts pull reqs that resolve active issues or feature requests."
    m.reply ".w #{m.user} You can find my source code here: https://github.com/aetaric/aetbot ."
  end

  def barrier(m)
    m.reply "@#{m.user} Barrier skip involves canceling your knockback by using the wind waker normally given by the barrier. Using item slide and the perfect angle you can phase through the barrier using a specific speed in which a portion of the barrier doesn't check for."
  end

end
