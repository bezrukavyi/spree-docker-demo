class SecretsEnvLoader
  LOCAL_CREDENTIALS = 'config/credentials.local.yml'.freeze

  def call
    secrets = local_credentials? ? local_credentials : secret_credentials
    return if secrets.blank?
    secrets.each { |key, value| ENV[key.to_s] ||= value.to_s }
  end

  private

  def local_credentials?
    Rails.env.development?
  end

  def local_credentials
    return unless File.exist?(LOCAL_CREDENTIALS)
    YAML.safe_load(File.read(LOCAL_CREDENTIALS))
  end

  def secret_credentials
    Rails.application.credentials.public_send(Rails.env)
  end
end
