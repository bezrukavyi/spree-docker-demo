Devise.setup do |config|
  config.router_name = :spree
  config.secret_key = ENV['DEVISE_SECRET_KEY']
end
