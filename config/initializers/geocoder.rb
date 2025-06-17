Geocoder.configure(
  ip_lookup: :ipinfo_io, # or :ipapi, :ipdata, etc.
  use_https: true,
  timeout: 5,
  units: :mi,
  cache: Rails.cache,
  cache_prefix: "geocoder:",

  # Enable automatic time zone detection
  timezone: :auto,

  # Use API key from credentials
  api_key: Rails.application.credentials.dig(:geocoder, :api_key)
)
