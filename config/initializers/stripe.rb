Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key)
STRIPE_SUPPORTED_COUNTRIES = ["AU", "AT", "BE", "BG", "CA", "CY", "CZ", "DK", "EE", "FI", "FR", "DE", "GR", "HK", "HU", "IE", "IT", "JP", "LV", "LT", "LU", "MT", "NL", "NZ", "NO", "PL", "PT", "RO", "SG", "SK", "SI", "ES", "SE", "CH", "GB", "US"].freeze
