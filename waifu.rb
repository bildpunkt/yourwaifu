require "yaml"
require "twitter"
require "ostruct"

keys = YAML.load_file File.expand_path(".", "config.yml")
filter = YAML.load_file File.expand_path(".", "filter.yml")
waifu = YAML.load_file File.expand_path(".", "waifu.yml")

client = Twitter::REST::Client.new do |config|
  config.consumer_key = keys['consumer_key']
  config.consumer_secret = keys['consumer_secret']
  config.access_token = keys['access_token']
  config.access_token_secret = keys['access_token_secret']
end
 
streamer = Twitter::Streaming::Client.new do |config|
  config.consumer_key = keys['consumer_key']
  config.consumer_secret = keys['consumer_secret']
  config.access_token = keys['access_token']
  config.access_token_secret = keys['access_token_secret']
end

begin
  current_user = client.current_user
rescue Exception => e
  puts "Exception: #{e.message}"
  # best hack:
  current_user = OpenStruct.new
  current_user.id = keys["access_token"].split("-")[0].to_i
end

puts "yourwaifu"
puts "-------------------------------"
puts "serving \033[34;1m#{waifu.count}\033[0m entries"
puts "filtering with \033[32;1m#{filter.count}\033[0m entries"
puts "-------------------------------"

loop do
  streamer.user do |object|
    if object.is_a? Twitter::Tweet
      unless current_user.id == object.user.id
        unless object.text.start_with? "RT @"
	  filtered = nil 
          filter.each do |f|
            if object.text.downcase.include? f.downcase
              filtered = f
	      break
	    end
	  end
	  unless filtered.nil?
            puts "\033[32;1m[#{Time.new.to_s}] #{object.user.screen_name} triggered filter: '#{filtered}'\033[0m"
          else
            chosen_one = waifu.sample
            puts "[#{Time.new.to_s}] #{object.user.screen_name}: #{chosen_one["name"]} - #{chosen_one["series"]}"
            begin
              begin
              client.update_with_media "@#{object.user.screen_name} Your waifu is #{chosen_one["name"]} (#{chosen_one["series"]})", File.new("img/#{chosen_one["series"]}/#{chosen_one["name"]}.png"), in_reply_to_status:object
              rescue Exception => m
                puts "\033[34;1m[#{Time.new.to_s}] #{m.message} Trying to post tweet without image!\033[0m"
                client.update "@#{object.user.screen_name} Your waifu is #{chosen_one["name"]} (#{chosen_one["series"]})", in_reply_to_status:object
              end
            rescue Exception => e
              puts "\033[31;1m[#{Time.new.to_s}] #{e.message}\033[0m"
            end
          end
        end
      end
    end
  end
  sleep 1
end
