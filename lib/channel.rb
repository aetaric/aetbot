class Channel
  attr_accessor :name, :id, :game, :status, :live, :viewcount, :host, :channel

  def go_live
    @live = true
    @host = false
  end

  def go_offline
    @live = false
    @host = true
  end

  def to_hash
    hash = {}
    hash["name"]      = @name
    hash["id"]        = @id
    hash["game"]      = @game
    hash["status"]    = @status
    hash["live"]      = @live
    hash["viewcount"] = @viewcount
    hash["host"]      = @host
    hash["channel"]   = @channel
    return hash
  end

  def to_json
    return to_hash.to_json
  end

  def to_s
    return @name
  end

  def to_i
    return @id
  end

end
