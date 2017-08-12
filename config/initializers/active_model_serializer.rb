require 'active_model_serializers/register_jsonapi_renderer'

ActiveModelSerializers.config.adapter = :json_api
ActiveModelSerializers.config.key_transform = :underscore # This doesn't appear to work at the moment, transforming on Ember side