require 'rubygems'

require 'dotenv'
Dotenv.load

require 'bundler/setup'
Bundler.require

def jason
  @jason_slack ||= begin
    client = Slack::Web::Client.new(token: ENV['JASON_KEY'])
    client.auth_test
    client
  end
end

def elizabeth
  @elizabeth_client ||= begin
    client = Slack::Web::Client.new(token: ENV['ELIZABETH_KEY'])
    client.auth_test
    client
  end
end

def s_message(client, msg)
  client.chat_postMessage(channel: '#general', text: msg, as_user: true)
end

[
  { client: jason, message: 'deployer show staging flying-monkey health' },
  { client: jason, message: 'deployer show flying-monkey tests' },
  { client: jason, message: 'deployer deploy staging flying-monkey' },
  { client: jason, message: 'deployer show staging flying-monkey health' },
  { client: jason, message: 'deployer rollback staging flying-monkey' },
  { client: jason, message: 'deployer show staging flying-monkey health' },
  { client: jason, message: 'deployer show production flying-monkey health' },
  { client: jason, message: 'deployer scale-up production flying-monkey' },
  { client: elizabeth, message: "We're up now in the ping-pong tournament. You're going down!" },
  { client: jason, message: 'Doing a production push, be there in a minute...' },
  { client: jason, message: "No way!! I'll destroy you!" },
  { client: jason, message: 'deployer destroy production flying-monky' },
  { client: jason, message: 'deployer stop' },
].each do |msg|
  puts "run: `#{msg[:message]}`"
  gets.chomp
  s_message(msg[:client], msg[:message])
end
