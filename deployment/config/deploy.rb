lock '3.8.0'

set :application, -> { "callio" }
set :repo_url,  "git@github.com:netguru/twilio-slack-notifier.git"
set :deploy_to, -> { ENV["DEPLOY_TO"] }
