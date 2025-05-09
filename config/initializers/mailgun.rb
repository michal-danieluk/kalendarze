# Mailgun API configuration
if Rails.env.production?
  Mailgun.configure do |config|
    config.api_key = Rails.application.credentials.dig(:mailgun, :api_key)
    config.domain = Rails.application.credentials.dig(:mailgun, :domain)
  end
else
  # For development and test environments
  # You can still use production credentials via credentials.yml.enc 
  # or set up test credentials for development
  Mailgun.configure do |config|
    config.api_key = Rails.application.credentials.dig(:mailgun, :api_key) || 'test-api-key'
    config.domain = Rails.application.credentials.dig(:mailgun, :domain) || 'test.domain.com'
  end
end