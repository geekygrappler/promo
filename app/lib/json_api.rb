module JsonApi

  #TODO don't write this shit, AMS should do it for me.
  def hyphenate(hash)
    hash = hash.map {|k,v| [k.to_s.gsub('_', '-').to_sym, v]}.to_h
  end
end