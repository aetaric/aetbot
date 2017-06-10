class Channel
  attr_accessor :name, :id, :game, :status, :live, :viewcount

  def go_live
    @live = true
  end

  def go_offline
    @live = false
  end

end
