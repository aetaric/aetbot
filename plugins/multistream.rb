require 'cinch'
require 'active_support'
require 'json'
require 'net/http'
require 'uri'

class MultiStream
  include Cinch::Plugin
  include ActiveSupport::Inflector

  listen_to :connect, :method => :setup

  match /multi/i, method: :multi
  match /addmulti ([a-zA-Z0-9\w\W ]*)/, method: :set_multi
  match /updatemulti ([a-zA-Z0-9\/\w\W ]*)/, method: :update_multi
  match /removemulti/, method: :delete_multi

  def setup(*)
    @collection = $mongo[:multi]
  end

  def multi(m)
    results = @collection.find(channel: m.channel.name)
    if results.any?
      #if target == nil
        m.reply "@#{m.user.name}, https://multistre.am/#{results.first["list"]}"
      #else
      #  m.reply "@#{target}, https://multistre.am/#{results.first["list"]}"
      #end
    end
  end

  def set_multi(m, list)
    if mod? m
      if !list.nil?
        @collection.insert_one( { :channel => m.channel.name, :list => list } )
        m.reply "@#{m.user.name}, Set Multi-stream"
      end
    end
  end

  def update_multi(m, list)
    if mod? m
      if !list.nil? 
        @collection.update_one( { :channel => m.channel.name },
                           { :channel => m.channel.name, :list => list } )
        m.reply "@#{m.user.name}, Updated Multi-stream"
      end
    end
  end

  def delete_multi(m)
    if mod? m
        @collection.delete_one( { :channel => m.channel.name } )
        m.reply "@#{m.user.name}, Deleted Multi-stream"
    end
  end
end
