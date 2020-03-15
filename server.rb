require 'sinatra'
require 'mongo'

Dir["./lib/*.rb"].each {|file| load file}

$brain = Brain.new

if !$brain.config
  $brain.setup
end

$mongo = Mongo::Client.new($brain.mongo["replSet"]["members"], :database => $brain.mongo["db"])
Mongo::Logger.logger.level = ::Logger::FATAL

get '/random' do
  random = $mongo[:chatters].aggregate([{ '$sample': { 'size': 1 } }])
  random.each do |doc|
    return doc["username"]
  end
end