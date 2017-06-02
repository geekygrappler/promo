module Requests
  module JsonHelpers
    def json
      JSON.parse(response.body)
    end

    def json_api_attributes
      JSON.parse(response.body)['data']['attributes']
    end
  end
end
