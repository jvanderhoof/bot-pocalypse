require 'rubygems'

require 'dotenv'
Dotenv.load

require 'bundler/setup'
Bundler.require

client = Slack::Web::Client.new(token: ENV['DEPLOYER_KEY'])
client.auth_test


class SlackDeploy
  include Sidekiq::Worker

  def perform(channel, build, app_name, environment)
    client = Slack::Web::Client.new
    client.auth_test

    client.chat_postMessage(channel: channel, text: "Deploying build v#{build} to #{environment} #{app_name}", as_user: true)
    sleep(3)
    client.chat_postMessage(channel: channel, text: "Deploy Complete, Restarting #{environment} #{app_name}", as_user: true)
    sleep(1)
    client.chat_postMessage(channel: channel, text: "Restart Complete. #{app_name} v#{build} has been deployed to #{environment}", as_user: true)

  end
end

class SlackDestroy
  include Sidekiq::Worker

  def perform(channel, build, app_name, environment)
    client = Slack::Web::Client.new
    client.auth_test

    client.chat_postMessage channel: channel, text: "I don’t understand `#{app_name}` so ignoring", as_user: true
    client.chat_postMessage channel: channel, text: "Destroying #{environment}", as_user: true
    sleep(5)
    client.chat_postMessage channel: channel, text: "Stopping services", as_user: true
    sleep(3)
    client.chat_postMessage channel: channel, text: "Decommissioning Infrastructure", as_user: true
    sleep(3)
    client.chat_postMessage channel: channel, text: "#{environment} has been successfully destroyed", as_user: true

  end
end
