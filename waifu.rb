#!/usr/bin/env ruby
require "yaml"
require "twitter"
require "tumblr_client"
require "ostruct"

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require "waifugen"

wf = WaifuGenerator.new

version = "4s1"

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
vocaloid = YAML.load_file File.expand_path(".", "lists/vocaloid.yml")
idol = YAML.load_file File.expand_path(".", "lists/idol.yml")

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

# OPTIONAL: Second Twitter configuration (status account)
if keys['statustwitter']['enabled']
  status = Twitter::REST::Client.new do |config|
    config.consumer_key = keys['statustwitter']['consumer_key']
    config.consumer_secret = keys['statustwitter']['consumer_secret']
    config.access_token = keys['statustwitter']['access_token']
    config.access_token_secret = keys['statustwitter']['access_token_secret']
  end
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
otp = {status: false}
chosen_one = {}

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
puts "         [\033[34;1m #{vocaloid.count}\033[0m] vocaloids"
puts "         [\033[34;1m #{idol.count}\033[0m] idols"
puts "         [\033[34;1m #{imouto.count}\033[0m] imouto"
puts "-------------------------------"
puts "Filters: [ \033[33;1m#{FILTER_WORDS.count}\033[0m] words"
puts "         [ \033[33;1m#{FILTER_USERS.count}\033[0m] users"
puts "         [  \033[33;1m#{FILTER_CLIENTS.count}\033[0m] clients"
puts "-------------------------------"
if keys['tumblr']['enabled']
  puts "\033[36;1mposting to Tumblr if status limit occurs\033[0m"
  puts "-------------------------------"
end
if keys['statustwitter']['enabled']
  puts "\033[36;1mposting to Twitter if status limit occurs\033[0m"
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
            chosen_one = wf.gen_single("husbando", husbando, object.user.screen_name)
          when /imouto/i
            chosen_one = wf.gen_single("imouto", imouto, object.user.screen_name)
            if object.text.downcase.include? "otp"
              otp['status'] = true
              chosen_one = wf.gen_multi("imouto", imouto, imouto, object.user.screen_name)
            end
          when /shipgirl/i
            chosen_one = wf.gen_single("shipgirl", shipgirl, object.user.screen_name)
            if object.text.downcase.include? "otp"
              otp['status'] = true
              chosen_one = wf.gen_double("shipgirl", shipgirl, object.user.screen_name)
            end
          when /touhou/i
            chosen_one = wf.gen_single("touhou", touhou, object.user.screen_name)
            if object.text.downcase.include? "otp"
              otp['status'] = true
              chosen_one = wf.gen_double("touhou", touhou, object.user.screen_name) 
            end
          when /vocaloid/i
            chosen_one = wf.gen_single("vocaloid", vocaloid, object.user.screen_name)
            if object.text.downcase.include? "otp"
              otp['status'] = true
              chosen_one = wf.gen_multi("vocaloid", vocaloid, vocaloid, object.user.screen_name)
            end
          when /idol/i
            chosen_one = wf.gen_single("idol", idol, object.user.screen_name)
            if object.text.downcase.include? "otp"
              otp['status'] = true
              chosen_one = wf.gen_multi("idol", idol, idol, object.user.screen_name)
            end   
          when /yuri otp/i
            otp['status'] = true
            chosen_one = wf.gen_multi("yuri", waifu, waifu, object.user.screen_name)
          when /yaoi otp/i
            otp['status'] = true
            chosen_one = wf.gen_multi("yaoi", husbando, husbando, object.user.screen_name)
          when /otp/i
            otp['status'] = true
            chosen_one = wf.gen_multi("default", waifu, husbando, object.user.screen_name)
          else
            chosen_one = wf.gen_single("waifu", waifu, object.user.screen_name)
        end
        if otp['status']
          otp['status'] = false
          puts "[#{Time.new.to_s}]#{chosen_one['console']}"
          client.update chosen_one['tweet'], in_reply_to_status: object
        else
          puts "[#{Time.new.to_s}]#{chosen_one['console']}"
          if File.exists? File.expand_path("../img/#{chosen_one['path']}", __FILE__)
            client.update_with_media chosen_one['tweet'], File.new("img/#{chosen_one['path']}"), in_reply_to_status: object
          else
            client.update chosen_one['tweet'], in_reply_to_status: object
            puts "\033[34;1m[#{Time.new.to_s}] posted without image!\033[0m"
          end
        end
        if limited
          limited = false
          if keys['tumblr']['enabled']
            tumblr_client.text(keys['tumblr']['blog_name'], title: "I'm back!", body: "The limit is gone now and you can get waifus/husbandos again! [Bot has been unlimited since: #{Time.new.to_s}]")
          end
          if keys['statustwitter']['enabled']
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
          if keys['tumblr']['enabled']
            tumblr_client.text(keys['tumblr']['blog_name'], title: 'Bot is limited', body: "I've reached the \"daily\" limit for now! Please wait a bit before mentioning me again. [Bot has been limited since: #{Time.new.to_s}]")
          end
          if keys['statustwitter']['enabled']
            status.update "\"Daily\" limit reached, please wait a bit before mentioning again! [Bot has been limited since: #{Time.new.to_s}]"
          end
        end
      end
    end
  end
  sleep 1
end
