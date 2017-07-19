#!/usr/bin/ruby

# Load '.'
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

# require Cinch IRCBot Framwork
require 'cinch'

# require activesupport for various Rails like magics
require 'active_support'

# add Inflector methods and overrides.
include ActiveSupport::Inflector

# require mongodb driver for working with various long term storage of data
require 'mongo'

# load libs
Dir["./lib/*.rb"].each {|file| load file}

# load custom cinch plugins
Dir["./plugins/*.rb"].each {|file| load file}

$brain = Brain.new

$host_chans = []
$live_chans = []
$team_chans = []

if !$brain.config
  $brain.setup
end

$mongo = Mongo::Client.new($brain.mongo["replSet"]["members"], :database => $brain.mongo["db"], replica_set: $brain.mongo["replSet"]["name"])
Mongo::Logger.logger.level = ::Logger::FATAL

channels = []
$brain.channels.each do |chan|
  channels.push chan["name"]
end

plugins = []
$brain.plugins.each do |plugin|
  plugins.push constantize(plugin)
end

@bot = Cinch::Bot.new do
  configure do |c|
    c.nick = $brain.bot["nick"]
    c.server = $brain.bot["server"]
    c.port = $brain.bot["port"]
    c.ssl.use = $brain.bot["ssl"]
    c.ssl.verify = $brain.bot["ssl_verify"]
    c.password = $brain.bot["password"]
    c.channels = channels
    c.caps = [:"twitch.tv/membership", :"twitch.tv/commands", :"twitch.tv/tags"]
    c.shared[:cooldown] = { :config => { linkus7: { global: 10, user: 20 } } }
    c.plugins.plugins = plugins
  end

  on :notice do |m|
    # implement now hosting handling here
    if !(/has gone offline. Exiting host mode./.match(m.message)).nil?
      @bot.warn "#{chan_to_user(m)} no longer hosting"
    end
  end

  on :hosttarget do |m|
    # implement hosttarget tracking and redirection here
    @bot.warn "channel: " + m.channel.to_s
    @bot.warn "target: " + m.message
  end
  
end

$plugin_list = Cinch::PluginList.new @bot
@bot.start
