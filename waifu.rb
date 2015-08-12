#!/usr/bin/env ruby
require "yaml"
require "twitter"
require "tumblr_client"
require "ostruct"

version = "v3.0.0"

# loading the config file
KEYS = YAML.load_file File.expand_path(".", "config.yml")

# regex to get client name
SOURCE_REGEX = /^<a href=\"(https?:\/\/\S+|erased_\d+)\" rel=\"nofollow\">(.+)<\/a>$/

# loading the filter lists
FILTER_WORDS = YAML.load_file File.expand_path(".", "filters/words.yml")
FILTER_USERS = YAML.load_file File.expand_path(".", "filters/users.yml")
FILTER_CLIENTS = YAML.load_file File.expand_path(".", "filters/clients.yml")

# loading scripts
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'twitter-extensions'
require 'yourwaifu'

# Twitter client configuration
client = Twitter::REST::Client.new do |config|
  config.consumer_key = KEYS['twitter']['consumer_key']
  config.consumer_secret = KEYS['twitter']['consumer_secret']
  config.access_token = KEYS['twitter']['access_token']
  config.access_token_secret = KEYS['twitter']['access_token_secret']
end

streamer = Twitter::Streaming::Client.new do |config|
  config.consumer_key = KEYS['twitter']['consumer_key']
  config.consumer_secret = KEYS['twitter']['consumer_secret']
  config.access_token = KEYS['twitter']['access_token']
  config.access_token_secret = KEYS['twitter']['access_token_secret']
end

# OPTIONAL: Second Twitter configuration (status account)
if KEYS['statustwitter']['enabled']
  status = Twitter::REST::Client.new do |config|
    config.consumer_key = KEYS['statustwitter']['consumer_key']
    config.consumer_secret = KEYS['statustwitter']['consumer_secret']
    config.access_token = KEYS['statustwitter']['access_token']
    config.access_token_secret = KEYS['statustwitter']['access_token_secret']
  end
end

# OPTIONAL: Tumblr configuration
if KEYS['tumblr']['enabled']
  Tumblr.configure do |config|
    config.consumer_key = KEYS['tumblr']['consumer_key']
    config.consumer_secret = KEYS['tumblr']['consumer_secret']
    config.oauth_token = KEYS['tumblr']['access_token']
    config.oauth_token_secret = KEYS['tumblr']['access_token_secret']
  end

  tumblr_client = Tumblr::Client.new
end

limited = false

$current_user = client.get_current_user

puts "yourwaifu #{version}"
puts "-------------------------------"
puts "Filters: [ \033[33;1m#{FILTER_WORDS.count}\033[0m] words"
puts "         [ \033[33;1m#{FILTER_USERS.count}\033[0m] users"
puts "         [  \033[33;1m#{FILTER_CLIENTS.count}\033[0m] clients"
puts "-------------------------------"
if KEYS['tumblr']['enabled']
  puts "\033[36;1mposting to Tumblr if status limit occurs\033[0m"
  puts "-------------------------------"
end
if KEYS['statustwitter']['enabled']
  puts "\033[36;1mposting to Twitter if status limit occurs\033[0m"
  puts "-------------------------------"
end

# @param obj [Hash] a hash with keys `'series'`, `'name'`, and `'filetype'`
# @return [Boolean]
def filename_for(obj)
  File.join(YourWaifu::IMAGE_PATH, "#{obj["series"]}/#{obj["name"]}.#{obj["filetype"]}")
end

# @param obj [Hash] a hash with keys `'series'`, `'name'`, and `'filetype'`
# @return [Boolean]
def image_exists_for?(obj)
  File.exists? filename_for(obj)
end

loop do
  streamer.user do |object|
    if object.is_a? Twitter::Tweet
      begin
        next if object.user.id == $current_user.id
        object.raise_if_retweet!
        object.raise_if_client_filtered!
        object.raise_if_word_filtered!
        object.raise_if_user_filtered!
        chosen_one = YourWaifu.pick object
        first = chosen_one[:matches].first
        if chosen_one[:is_otp]
          second = chosen_one[:matches].last
          puts "[#{Time.new.to_s}][#{chosen_one[:title]} OTP] #{object.user.screen_name}: #{first["name"]} x #{second["name"]}"
          client.update "@#{object.user.screen_name} Your #{chosen_one[:title]} OTP is #{first["name"]} x #{second["name"]} (#{first["series"]}#{ 
            unless first['series'] == second['series']
              "|#{second["series"]}"
            end})", in_reply_to_status: object  
        else
          text = "@#{object.user.screen_name} Your #{chosen_one[:title]} is #{first["name"]} (#{first["series"]})"
          puts "[#{Time.new.to_s}][#{chosen_one[:title]}] #{object.user.screen_name}: #{first["name"]} - #{first["series"]}"
          if image_exists_for? first
	    client.update_with_media text, File.new(filename_for(first)), in_reply_to_status: object
          else
            client.update text, in_reply_to_status: object
            puts "\033[34;1m[#{Time.new.to_s}] posted without image!\033[0m"
          end
        end

        if limited
          limited = false
          if KEYS['tumblr']['enabled']
            tumblr_client.text(KEYS['tumblr']['blog_name'], title: "I'm back!", body: "The limit is gone now and you can get waifus/husbandos again! [Bot has been unlimited since: #{Time.new.to_s}]")
          end
          if KEYS['statustwitter']['enabled']
            status.update "You can get waifus/husbandos again! [Bot has been unlimited since: #{Time.new.to_s}]"
          end
        end
      rescue NotImportantException => e
      rescue FilteredClientException => e
        puts "\033[33;1m[#{Time.new.to_s}] #{e.message}\033[0m"
      rescue FilteredTweetException => e
        puts "\033[33;1m[#{Time.new.to_s}] #{e.message}\033[0m"
      rescue FilteredUserException => e
        puts "\033[33;1m[#{Time.new.to_s}] #{e.message}\033[0m"
      rescue Exception => e
        puts "\033[31;1m[#{Time.new.to_s}] #{e.message}\033[0m"
        if e.message.match /update limit/i and !limited
          limited = true
          if KEYS['tumblr']['enabled']
            tumblr_client.text(KEYS['tumblr']['blog_name'], title: 'Bot is limited', body: "I've reached the \"daily\" limit for now! Please wait a bit before mentioning me again. [Bot has been limited since: #{Time.new.to_s}]")
          end
          if KEYS['statustwitter']['enabled']
            status.update "\"Daily\" limit reached, please wait a bit before mentioning again! [Bot has been limited since: #{Time.new.to_s}]"
          end
        end
      end
    end
  end
  sleep 1
end
