require 'cinch'
require 'active_support'
require 'json'

class Twitch
  include Cinch::Plugin
  include ActiveSupport::Inflector

  listen_to :connect,    :method => :setup
  listen_to :channel,    :method => :public_message

  def setup(*)
    @collection = $mongo[:chatters]
    puts @collection.indexes.count
    if @collection.indexes.count < 3
      @collection.indexes.create_one(
        { username: 1 },
        unique: true,
      )
      @collection.indexes.create_one(
        { time: 1 },
        expire_after: 300,
      )
    end
  end

  def public_message(msg)
    #puts @collection.find(:username => msg.user.name).limit(1).public_methods
    if @collection.find(:username => msg.user.name).limit(1).none?
      @collection.insert_one({ username: msg.user.name, time: DateTime.now })
    else
      @collection.find(:username => msg.user.name).find_one_and_update( '$set' => { :time => DateTime.now } )
    end
  end

end
