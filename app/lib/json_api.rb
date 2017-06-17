module JsonApi

  #TODO don't write this shit, AMS should do it for me.
  def hyphenate(hash)
    hash.map {|k,v| [k.to_s.gsub('_', '-').to_sym, v]}.to_h
  end

  def params_to_active_record(params)
    params.map {|k,v| [k.to_s.gsub('-', '_').to_sym, v]}.to_h
  end

  def json_api_error_response(errors)
    {
      errors: errors.map { |error|
        {
          title: error.message
        }
      }
    }
  end
end