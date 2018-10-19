require 'sidekiq'
require 'slack-ruby-client'
require 'yaml'
require 'pry'

CNF = YAML::load_file(File.join(Dir.pwd, 'config/local_env.yml'))

# If your client is single-threaded, we just need a single connection in our Redis connection pool
Sidekiq.configure_server do |config|
  config.redis = { url: CNF['REDIS_URI_SERVER'] || 'redis://localhost:6379' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: CNF['REDIS_URI_CLIENT'] || 'redis://localhost:6379' }
end

class StartSchedule
  include Sidekiq::Worker
  sidekiq_options queue: 'adhan'

  def perform(message)
    begin
      client = Slack::Web::Client.new(token: CNF['SLACK_TOKEN'])
      client.auth_test
      client.chat_postMessage(channel: '#panggilansholat', text: message, as_user: true)
      puts "Message send : #{message}"
    rescue Exception => e
      puts e.backtrace
    end
  end
end
