Spree.config do |config|
  # Example:
  # Uncomment to stop tracking inventory levels in the application
  # config.track_inventory_levels = false
end

Spree.user_class = 'Spree::User'

if !Rails.env.development? && !Rails.env.test?
  attachment_config = {
    s3_credentials: {
      access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      bucket:            ENV['S3_BUCKET_NAME']
    },

    storage:        :s3,
    s3_protocol:    'https',
    s3_host_name:   ENV['S3_HOST_NAME'],
    s3_region:      ENV['S3_REGION'],
    bucket:         ENV['S3_BUCKET_NAME'],

    url:            '/spree/:class/:id/:style/:basename.:extension',
    path:           '/spree/:class/:id/:style/:basename.:extension'
  }

  attachment_config.each do |key, value|
    Spree::Image.attachment_definitions[:attachment][key.to_sym] = value
  end
end
