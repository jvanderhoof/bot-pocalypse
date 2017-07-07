require 'rubygems'

require 'dotenv'
Dotenv.load

require 'bundler/setup'
Bundler.require

load 'jobs.rb'

Sidekiq.configure_server do |config|
  config.redis = { :namespace => 'slack-demo' }
end

client = Slack::RealTime::Client.new(token: ENV['DEPLOYER_KEY'])

client.on :hello do
  puts "Successfully connected, welcome '#{client.self.name}' to the '#{client.team.name}' team at https://#{client.team.domain}.slack.com."
end


def move_back(str)
  parts = str.split('.')
  parts[parts.length - 1] = parts.last.to_i - 1
  parts.join('.')
end

def move_forward(str)
  parts = str.split('.')
  parts[parts.length - 1] = parts.last.to_i + 1
  parts.join('.')
end

load_hsh = {
  'staging' => 0.001,
  'production' => 0.100
}

build_hsh = {
  'staging' => '12.4.11',
  'production' => '12.4.11'
}

scale_hsh = {
  'staging' => 2,
  'production' => 10
}



client.on :message do |data|
  msg = data.text
  if msg.match(/^deployer/)
    sleep(2)

    case msg
    # test status request:
    # deployer show flying-monkey tests
    when /^deployer show ([a-z\-]+) tests$/

      client.message channel: data.channel, text: "#{$1} tests are green. Build number is v12.4.12"

    # health request:
    # deployer show staging flying-monkey health
    # deployer show staging flying-monkey health
    # deployer show staging flying-monkey health
    # deployer show production flying-monkey health
    when /^deployer show (\w+) ([a-z\-]+) health$/
      environment = $1
      app_name = $2

      client.message channel: data.channel, text: "#{app_name} in #{environment} is healthy\nErrors: 0 in the last hour\nAvg Load: #{load_hsh[environment]}\nBuild: v#{build_hsh[environment]}\nScale: #{scale_hsh[environment]} nodes"

    # deployer deploy staging flying-monkey
    when /^deployer deploy (\w+) ([a-z\-]+)$/
      environment = $1
      app_name = $2

      build_hsh[environment] = move_forward(build_hsh[environment])
      SlackDeploy.perform_async(data.channel, build_hsh[environment], app_name, environment)

    # deployer rollback staging flying-monkey
    when /^deployer rollback (\w+) ([a-z\-]+)$/
      environment = $1
      app_name = $2

      build_hsh[environment] = move_back(build_hsh[environment])
      SlackDeploy.perform_async(data.channel, build_hsh[environment], app_name, environment)

    # deployer scale-up production flying-monkey
    when /^deployer scale-up (\w+) ([a-z\-]+)$/
      environment = $1
      app_name = $2

      scale_hsh[environment] += 1
      load_hsh[environment] = (load_hsh[environment] / 1.2).round(3)

      sleep(2)
      client.message channel: data.channel, text: "#{app_name} in #{environment}  has been scaled up to #{scale_hsh[environment]} nodes"
      client.message channel: data.channel, text: "Avg Load: #{load_hsh[environment]}"


    # deployer destroy production flying-monky
    when /^deployer destroy (\w+) ([a-z\-]+)$/
      environment = $1
      app_name = $2

      SlackDestroy.perform_async(data.channel, build_hsh[environment], app_name, environment)

    # deployer stop
    when /^deployer stop$/
      client.message channel: data.channel, text: "I’m sorry <@#{data.user}>, I can’t do that"
    else
      puts "message not understood: #{msg}"
    end
  else
    puts 'skipped'
    puts data.inspect
  end
end

client.on :close do |_data|
  puts "Client is about to disconnect"
end

client.on :closed do |_data|
  puts "Client has disconnected successfully!"
end

client.start!
