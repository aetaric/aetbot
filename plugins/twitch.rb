require 'cinch'
require 'active_support'
require 'active_view'
require 'json'
require 'net/http'
require 'uri'

class Twitch
  include Cinch::Plugin
  include ActiveSupport::Inflector
  include ActionView::Helpers::DateHelper

  match /follow (.+)/, method: :follow
  match /source/, method: :source
  match /host (.+)/, method: :host
  match /commands/, method: :commands
  match /day/, method: :day
  match /game (.+)/, method: :game
  match /title (.+)/, mehtod: :title
  match /uptime/, method: :uptime

  def follow(m, plug)
    if mod?(m)
      3.times { m.reply "Hey Chat! You should follow https://www.twitch.tv/#{plug} !" }
    end
  end

  def source(m)
    m.reply ".w #{m.user} I'm written in Ruby and my developer accepts pull reqs that resolve active issues or feature requests."
    m.reply ".w #{m.user} You can find my source code here: https://github.com/aetaric/aetbot ."
  end

  def host(m, target)
    if mod?(m)
      m.reply ".host #{target}"
    end
  end

  def day(m)
    m.reply "@#{m.user} It's #{Date.today.strftime("%A")}"
  end

  def commands(m)
    if mod?(m)
      m.reply ".w #{m.user} My Commands are here: https://gist.githubusercontent.com/aetaric/deda5ab253caf926f4eca632355a6a4f/raw/be73471cc875b5701ebe87e9f35902bb0b33b16a/aetbot%2520Commands"
    end
  end

  def game(m, gamename)
    if mod?(m)
      @collection = $mongo[:users]
      user = @collection.find(name: chan_to_user(m)).first

      uri = URI.parse("https://api.twitch.tv/kraken/channels/" + user["uid"].to_s)
      request = Net::HTTP::Put.new(uri)
      request.content_type = "application/json"
      request["Client-Id"] = $brain.twitch["client"]
      request["Accept"] = "application/vnd.twitchtv.v5+json"
      request["Authorization"] = "OAuth " + user["oauth"]
      request.body = JSON.dump({
        "channel" => {
          "game" => gamename
        }
      })

      req_options = {
        use_ssl: uri.scheme == "https",
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      m.reply "I've set the game to #{gamename}"
    end
  end

  def title(m, title_string)
    if mod?(m)
      @collection = $mongo[:users]
      user = @collection.find(name: chan_to_user(m)).first

      uri = URI.parse("https://api.twitch.tv/kraken/channels/" + user["uid"].to_s)
      request = Net::HTTP::Put.new(uri)
      request.content_type = "application/json"
      request["Client-Id"] = $brain.twitch["client"]
      request["Accept"] = "application/vnd.twitchtv.v5+json"
      request["Authorization"] = "OAuth " + user["oauth"]
      request.body = JSON.dump({
        "channel" => {
          "status" => title_string
        }
      })

      req_options = {
        use_ssl: uri.scheme == "https",
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      m.reply "I've set the title to #{title_string}"
    end
  end

  def uptime(m)
    user_uri = URI.parse("https://api.twitch.tv/kraken/users?login=" + chan_to_user(m))
    user_request = Net::HTTP::Get.new(uri)
    user_request["Accept"] = "application/vnd.twitchtv.v5+json"
    request["Client-Id"] = $brain.twitch["client"]
    
    user_req_options = {
      use_ssl: uri.scheme == "https",
    }
    
    user_response = Net::HTTP.start(user_uri.hostname, user_uri.port, user_req_options) do |http|
      http.request(request)
    end

    user_json = JSON.load(response.body)

    uri = URI.parse("https://api.twitch.tv/kraken/streams/" + user_json["users"][0]["_id"])
    request = Net::HTTP::Get.new(uri)
    request["Accept"] = "application/vnd.twitchtv.v5+json"
    request["Client-Id"] = $brain.twitch["client"]
    
    req_options = {
      use_ssl: uri.scheme == "https",
    }
    
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    json = JSON.load(response.body)

    m.reply "#{time_ago_in_words json["stream"]["created_at"]} OpieOP"
  end
end
