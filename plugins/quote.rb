class TwitchQuotes
  include Cinch::Plugin
  
  listen_to :connect,    :method => :setup

  match /quote\s?(\d+)?/i, method: :quote
  match /addquote ([a-zA-Z0-9\w\W ]*)/i, method: :add_quote
  match /editquote (\d+) ([a-zA-Z0-9\w\W ]*)/i, method: :edit_quote
  match /delquote (\d+)/i, method: :del_quote

  def setup(*)
    @collection = $mongo[:quotes]
  end

  def quote(m,quote_num)
    rand = Kernel.rand()
    if !mod?(m)
      quote = @collection.find({ :channel => m.channel.name, :number => { '$gte' => rand }, :deleted => 0 },{:limit => 1}).first
      if quote.nil?
        quote = @collection.find({ :channel => m.channel.name, :number => { '$lte' => rand }, :deleted => 0 }, {:limit => 1}).first
      end
    else
      if quote_num.nil?
        quote = @collection.find({ :channel => m.channel.name, :number => { '$gte' => rand }, :deleted => 0 },{:limit => 1}).first
        if quote.nil?
          quote = @collection.find({ :channel => m.channel.name, :number => { '$lte' => rand }, :deleted => 0 },{:limit => 1}).first
        end
      else
        quote = @collection.find({ :channel => m.channel.name, :number => quote_num, :deleted => 0 },{:limit => 1}).first
      end
    end

    m.reply "##{quote['number'].to_i}: #{quote['quote']} @ #{quote['date']}"
  end

  def add_quote(m,quote)
    if mod?(m)
#      $channels.each do |channel|
#        if channel['name'] == chan_to_name(m)
#          if !channel['locale'].nil?
#            locale = channel['locale']
#          else
            locale = "UTC"
#            m.reply "No Timezone locale set. Using UTC."
#          end
#        end
#      end

      tz = TZInfo::Timezone.get(locale)
      local = tz.utc_to_local(Time.now)
      local.iso8601.gsub /Z/, ''

      count = @collection.count({ :channel => m.channel.name, :deleted => 0 }).to_i
      @collection.insert_one({ :date => local, :channel => m.channel.name, :quote => quote, :number => count, :deleted => 0 })
      m.reply "Successfully added quote ##{count}!"
      m.reply "##{count} | #{quote} @ #{local}"
    end
  end

  def edit_quote(m,quote_num,quote)
    @collection.update_one({ :number => quote_num, :channel => m.channel.name, :deleted => 0 },
      { :channel => m.channel.name, :number => quote_num, :quote => quote, :deleted => 0 })
    m.reply "Successfully edited quote ##{quote_num}!"
    quote =
    m.reply
  end

  def del_quote(m,quote_num)
    @collection.update_one({ :number => quote_num, :channel => m.channel.name }, { :deleted => 1 } )
    m.reply "Deleted quote ##{quote_num}!"
  end
end
