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

# loading the lists containing characters
waifu = YAML.load_file File.expand_path(".", "lists/waifu.yml")
husbando = YAML.load_file File.expand_path(".", "lists/husbando.yml")
imouto = YAML.load_file File.expand_path(".", "lists/imouto.yml")
shipgirl = YAML.load_file File.expand_path(".", "lists/kancolle.yml")
touhou = YAML.load_file File.expand_path(".", "lists/touhou.yml")
vocaloid = YAML.load_file File.expand_path(".", "lists/vocaloid.yml")
idol = YAML.load_file File.expand_path(".", "lists/idol.yml")

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
otp = {status: false, type: ""}
chosen_one = {}

$current_user = client.get_current_user

puts "yourwaifu #{version}"
puts "-------------------------------"
puts "Entries: [\033[34;1m#{waifu.count}\033[0m] waifu"
puts "         [\033[34;1m#{husbando.count}\033[0m] husbando"
puts "         [\033[34;1m#{shipgirl.count}\033[0m] shipgirls"
puts "         [\033[34;1m #{touhou.count}\033[0m] touhou"
puts "         [\033[34;1m #{vocaloid.count}\033[0m] vocaloids"
puts "         [\033[34;1m #{idol.count}\033[0m] idols"
puts "         [\033[34;1m #{imouto.count}\033[0m] imouto"
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

loop do
  streamer.user do |object|
    if object.is_a? Twitter::Tweet
      begin
        object.raise_if_current_user!
        object.raise_if_retweet!
        object.raise_if_client_filtered!
        object.raise_if_word_filtered!
        object.raise_if_user_filtered!
        case object.text
          when /husbando?/i
            chosen_one = husbando.sample
            chosen_one['title'] = "husbando"
          when /imouto/i
            chosen_one = imouto.sample
            chosen_one['title'] = "imouto"
            if object.text.downcase.include? "otp"
              otp['status'] = true
              otp['type'] = "imouto"
              chosen_one['partner_a'] = imouto.sample
              chosen_one['partner_b'] = imouto.sample
              chosen_one['title'] = "OTP"
            end
          when /shipgirl/i
            chosen_one = shipgirl.sample
            chosen_one['title'] = "shipgirl"
            if object.text.downcase.include? "otp"
              otp['status'] = true
              otp['type'] = "shipgirl"
              chosen_one['partner_a'] = shipgirl.sample
              chosen_one['partner_b'] = shipgirl.sample
              chosen_one['title'] = "OTP"
            end
          when /touhou/i
            chosen_one = touhou.sample
            chosen_one['title'] = "touhou"
            if object.text.downcase.include? "otp"
              otp['status'] = true
              otp['type'] = "touhou"
              chosen_one['partner_a'] = touhou.sample
              chosen_one['partner_b'] = touhou.sample
              chosen_one['title'] = "OTP"
            end
          when /vocaloid/i
            chosen_one = vocaloid.sample
            chosen_one['title'] = "vocaloid"
            if object.text.downcase.include? "otp"
              otp['status'] = true
              otp['type'] = "vocaloid"
              chosen_one['partner_a'] = vocaloid.sample
              chosen_one['partner_b'] = vocaloid.sample
              chosen_one['title'] = "OTP"
            end
          when /idol/i
            chosen_one = idol.sample
            chosen_one['title'] = "idol"
            if object.text.downcase.include? "otp"
              otp['status'] = true
              otp['type'] = "idol"
              chosen_one['partner_a'] = idol.sample
              chosen_one['partner_b'] = idol.sample
              chosen_one['title'] = "OTP"
            end
          when /yuri otp/i
            otp['status'] = true
            otp['type'] = "yuri"
            chosen_one['partner_a'] = waifu.sample
            chosen_one['partner_b'] = waifu.sample
            chosen_one['title'] = "OTP"
          when /yaoi otp/i
            otp['status'] = true
            otp['type'] = "yaoi"
            chosen_one['partner_a'] = husbando.sample
            chosen_one['partner_b'] = husbando.sample
            chosen_one['title'] = "OTP"
          when /otp/i
            otp['status'] = true
            chosen_one['partner_a'] = waifu.sample
            chosen_one['partner_b'] = husbando.sample
            chosen_one['title'] = "OTP"
          else
            chosen_one = waifu.sample
            chosen_one['title'] = "waifu"
        end
        if otp['status']
          otp['status'] = false
          case otp['type']
            when "idol"
              puts "[#{Time.new.to_s}][#{otp["type"]} OTP] #{object.user.screen_name}: #{chosen_one["partner_a"]["name"]} x #{chosen_one["partner_b"]["name"]}"
              client.update "@#{object.user.screen_name} Your #{chosen_one["title"]} is #{chosen_one["partner_a"]["name"]} x #{chosen_one["partner_b"]["name"]} (#{chosen_one["partner_a"]["series"]}|#{chosen_one["partner_b"]["series"]})", in_reply_to_status: object
            when "imouto"
              puts "[#{Time.new.to_s}][#{otp["type"]} OTP] #{object.user.screen_name}: #{chosen_one["partner_a"]["name"]} x #{chosen_one["partner_b"]["name"]}"
              client.update "@#{object.user.screen_name} Your #{chosen_one["title"]} is #{chosen_one["partner_a"]["name"]} x #{chosen_one["partner_b"]["name"]} (#{chosen_one["partner_a"]["series"]}|#{chosen_one["partner_b"]["series"]})", in_reply_to_status: object
            when "shipgirl"
              puts "[#{Time.new.to_s}][#{otp["type"]} OTP] #{object.user.screen_name}: #{chosen_one["partner_a"]["name"]} x #{chosen_one["partner_b"]["name"]}"
              client.update "@#{object.user.screen_name} Your #{chosen_one["title"]} is #{chosen_one["partner_a"]["name"]} x #{chosen_one["partner_b"]["name"]} (Kantai Collection)", in_reply_to_status: object
            when "touhou"
              puts "[#{Time.new.to_s}][#{otp["type"]} OTP] #{object.user.screen_name}: #{chosen_one["partner_a"]["name"]} x #{chosen_one["partner_b"]["name"]}"
              client.update "@#{object.user.screen_name} Your #{chosen_one["title"]} is #{chosen_one["partner_a"]["name"]} x #{chosen_one["partner_b"]["name"]} (Touhou)", in_reply_to_status: object
            when "vocaloid"
              puts "[#{Time.new.to_s}][#{otp["type"]} OTP] #{object.user.screen_name}: #{chosen_one["partner_a"]["name"]} x #{chosen_one["partner_b"]["name"]}"
              client.update "@#{object.user.screen_name} Your #{chosen_one["title"]} is #{chosen_one["partner_a"]["name"]} x #{chosen_one["partner_b"]["name"]} (#{chosen_one["partner_a"]["series"]}|#{chosen_one["partner_b"]["series"]})", in_reply_to_status: object
            when "yaoi"
              puts "[#{Time.new.to_s}][#{otp["type"]} OTP] #{object.user.screen_name}: #{chosen_one["partner_a"]["name"]} x #{chosen_one["partner_b"]["name"]}"
              client.update "@#{object.user.screen_name} Your #{chosen_one["title"]} is #{chosen_one["partner_a"]["name"]} x #{chosen_one["partner_b"]["name"]} (#{chosen_one["partner_a"]["series"]}|#{chosen_one["partner_b"]["series"]})", in_reply_to_status: object
            when "yuri"
              puts "[#{Time.new.to_s}][#{otp["type"]} OTP] #{object.user.screen_name}: #{chosen_one["partner_a"]["name"]} x #{chosen_one["partner_b"]["name"]}"
              client.update "@#{object.user.screen_name} Your #{chosen_one["title"]} is #{chosen_one["partner_a"]["name"]} x #{chosen_one["partner_b"]["name"]} (#{chosen_one["partner_a"]["series"]}|#{chosen_one["partner_b"]["series"]})", in_reply_to_status: object
            else
              puts "[#{Time.new.to_s}][#{chosen_one["title"]}] #{object.user.screen_name}: #{chosen_one["partner_a"]["name"]} x #{chosen_one["partner_b"]["name"]}"
              client.update "@#{object.user.screen_name} Your #{chosen_one["title"]} is #{chosen_one["partner_a"]["name"]} x #{chosen_one["partner_b"]["name"]} (#{chosen_one["partner_a"]["series"]}|#{chosen_one["partner_b"]["series"]})", in_reply_to_status: object
          end
          otp['type'] = ""
        else
          puts "[#{Time.new.to_s}][#{chosen_one["title"]}] #{object.user.screen_name}: #{chosen_one["name"]} - #{chosen_one["series"]}"
          if File.exists? File.expand_path("../img/#{chosen_one["series"]}/#{chosen_one["name"]}.#{chosen_one["filetype"]}", __FILE__)
            client.update_with_media "@#{object.user.screen_name} Your #{chosen_one["title"]} is #{chosen_one["name"]} (#{chosen_one["series"]})", File.new("img/#{chosen_one["series"]}/#{chosen_one["name"]}.#{chosen_one["filetype"]}"), in_reply_to_status: object
          else
            client.update "@#{object.user.screen_name} Your #{chosen_one["title"]} is #{chosen_one["name"]} (#{chosen_one["series"]})", in_reply_to_status: object
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
