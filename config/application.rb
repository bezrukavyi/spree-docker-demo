require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)
require_relative 'secrets_env_loader'

module SpreeDemo
  class Application < Rails::Application
    SecretsEnvLoader.new.call

    config.to_prepare do
      # Load application's model / class decorators
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

      # Load application's view overrides
      Dir.glob(File.join(File.dirname(__FILE__), "../app/overrides/*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.load_defaults 5.2

    # use Paperclip (will be deprecated in Spree 4.0) instead of ActiveStorage
    ENV['SPREE_USE_PAPERCLIP'] = 'true'
  end
end
