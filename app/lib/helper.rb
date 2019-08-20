module Helper
  def self.progress_bar(val, max)
    chars = 60
    filled = ([val, max].min * chars / max).round
    empty = chars - filled
    "[#{'|' * filled}#{'.' * empty}] #{val}/#{max}"
  end
end
