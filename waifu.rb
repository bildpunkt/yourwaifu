#!/usr/bin/env ruby
require "yaml"
require "twitter"
require "tumblr_client"
require "ostruct"

version = "v2.0.10"

# loading the config file
keys = YAML.load_file File.expand_path(".", "config.yml")

# loading the filter lists
FILTER_WORDS = YAML.load_file File.expand_path(".", "filters/words.yml")
FILTER_USERS = YAML.load_file File.expand_path(".", "filters/users.yml")
FILTER_CLIENTS = YAML.load_file File.expand_path(".", "filters/clients.yml")

# loading the lists containing characters
waifu = YAML.load_file File.expand_path(".", "lists/waifu.yml")
husbando = YAML.load_file File.expand_path(".", "lists/husbando.yml")
imouto = YAML.load_file File.expand_path(".", "lists/imouto.yml")
shipgirl = YAML.load_file File.expand_path(".", "lists/kancolle.yml")
touhou = YAML.load_file File.expand_path(".", "lists/touhou.yml")

# regex to get client name
SOURCE_REGEX = /^<a href=\"(https?:\/\/\S+|erased_\d+)\" rel=\"nofollow\">(.+)<\/a>$/

# Twitter client configuration
client = Twitter::REST::Client.new do |config|
  config.consumer_key = keys['twitter']['consumer_key']
  config.consumer_secret = keys['twitter']['consumer_secret']
  config.access_token = keys['twitter']['access_token']
  config.access_token_secret = keys['twitter']['access_token_secret']
end
 
streamer = Twitter::Streaming::Client.new do |config|
  config.consumer_key = keys['twitter']['consumer_key']
  config.consumer_secret = keys['twitter']['consumer_secret']
  config.access_token = keys['twitter']['access_token']
  config.access_token_secret = keys['twitter']['access_token_secret']
end

# OPTIONAL: Tumblr configuration
if keys['tumblr']['enabled']
  Tumblr.configure do |config|
    config.consumer_key = keys['tumblr']['consumer_key']
    config.consumer_secret = keys['tumblr']['consumer_secret']
    config.oauth_token = keys['tumblr']['access_token']
    config.oauth_token_secret = keys['tumblr']['access_token_secret']
  end
  
  tumblr_client = Tumblr::Client.new
end

limited = false

begin
  $current_user = client.current_user
rescue Exception => e
  puts "Exception: #{e.message}"
  # best hack:
  $current_user = OpenStruct.new
  $current_user.id = keys['twitter']["access_token"].split("-")[0].to_i
end

puts "yourwaifu #{version}"
puts "-------------------------------"
puts "Entries: [\033[34;1m#{waifu.count}\033[0m] waifu"
puts "         [\033[34;1m#{husbando.count}\033[0m] husbando"
puts "         [\033[34;1m#{shipgirl.count}\033[0m] shipgirls"
puts "         [\033[34;1m #{touhou.count}\033[0m] touhou"
puts "         [\033[34;1m #{imouto.count}\033[0m] imouto"
puts "-------------------------------"
puts "Filters: [ \033[33;1m#{FILTER_WORDS.count}\033[0m] words"
puts "         [  \033[33;1m#{FILTER_USERS.count}\033[0m] users"
puts "         [  \033[33;1m#{FILTER_CLIENTS.count}\033[0m] clients"
puts "-------------------------------"
if keys['tumblr']['enabled']
  puts "\033[36;1mposting to Tumblr if status limit occurs\033[0m"
  puts "-------------------------------"
end


class NotImportantException < Exception
end

class FilteredException < Exception
end

class FilteredClientException < FilteredException
end

class FilteredUserException < FilteredException
end

class FilteredTweetException < FilteredException
end

class Twitter::Tweet
  def raise_if_current_user!
    raise NotImportantException if $current_user.id == self.user.id
  end

  def raise_if_retweet!
    raise NotImportantException if self.text.start_with? "RT @"
  end
  
  def raise_if_client_filtered!
    FILTER_CLIENTS.each do |fc|
    filter_client = self.source.match SOURCE_REGEX
      if filter_client[2].downcase.include? fc.downcase
        raise FilteredClientException, "#{self.user.screen_name} is replying with #{fc}, a filtered client"
      end
    end
  end

  def raise_if_word_filtered!
    FILTER_WORDS.each do |fw|
      if self.text.downcase.include? fw.downcase
        raise FilteredTweetException, "#{self.user.screen_name} triggered filter: '#{fw}'"
      end
    end
  end
  
  def raise_if_user_filtered!
    FILTER_USERS.each do |fu|
      if self.user.screen_name.downcase.include? fu.downcase
        raise FilteredUserException, "#{self.user.screen_name} is filtered, not going to reply"
      end
    end
  end
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
          when /shipgirl/i
            chosen_one = shipgirl.sample
            chosen_one['title'] = "shipgirl"
          when /touhou/i
            chosen_one = touhou.sample
            chosen_one['title'] = "touhou"
          else
            chosen_one = waifu.sample
            chosen_one['title'] = "waifu"
        end
        puts "[#{Time.new.to_s}][#{chosen_one["title"]}] #{object.user.screen_name}: #{chosen_one["name"]} - #{chosen_one["series"]}"
        if File.exists? File.expand_path("../img/#{chosen_one["series"]}/#{chosen_one["name"]}.#{chosen_one["filetype"]}", __FILE__)
          client.update_with_media "@#{object.user.screen_name} Your #{chosen_one["title"]} is #{chosen_one["name"]} (#{chosen_one["series"]})", File.new("img/#{chosen_one["series"]}/#{chosen_one["name"]}.#{chosen_one["filetype"]}"), in_reply_to_status:object
        else
          client.update "@#{object.user.screen_name} Your #{chosen_one["title"]} is #{chosen_one["name"]} (#{chosen_one["series"]})", in_reply_to_status:object
          puts "\033[34;1m[#{Time.new.to_s}] posted without image!\033[0m"
        end
        if limited
          limited = false
          if keys['tumblr']['enabled']
            tumblr_client.text(keys['tumblr']['blog_name'], title: "I'm back!", body: "The limit is gone now and you can get waifus/husbandos again! [Bot has been unlimited since: #{Time.new.to_s}]")
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
          if keys['tumblr']['enabled']
            tumblr_client.text(keys['tumblr']['blog_name'], title: "Bot is limited", body: "I've reached the \"daily\" limit for now! Please wait a bit before mentioning me again. [Bot has been limited since: #{Time.new.to_s}]")
          end
        end
      end
    end
  end
  sleep 1
end
