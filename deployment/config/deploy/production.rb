server ENV["PRODUCTION_SERVER"], user: ENV["PRODUCTION_USER"], roles: %w(app db web)
set :branch, 'production'
