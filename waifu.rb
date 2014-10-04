require "yaml"
require "twitter"
require "ostruct"

keys = YAML.load_file File.expand_path(".", "config.yml")

waifu = [
  { name: "Yuuji Kazami", series: "Grisaia no Kajitsu" },
  { name: "Yumiko Sakake", series: "Grisaia no Kajitsu" },
  { name: "Amane Suou", series: "Grisaia no Kajitsu" },
  { name: "Michiru Matsushima", series: "Grisaia no Kajitsu" },
  { name: "Makina Irisu", series: "Grisaia no Kajitsu" },
  { name: "Sachi Komine", series: "Grisaia no Kajitsu" },
  { name: "Chizuru Tachibana", series: "Grisaia no Kajitsu" },
  { name: "Kazuki Kazami", series: "Grisaia no Kajitsu" },
  { name: "Hanako Ikezawa", series: "Katawa Shoujo" },
  { name: "Lilly Satou", series: "Katawa Shoujo" },
  { name: "Shizune Hakamichi", series: "Katawa Shoujo" },
  { name: "Hideaki Hakamichi", series: "Katawa Shoujo" },
  { name: "Shiina \"Misha\" Mikado", series: "Katawa Shoujo" },
  { name: "Emi Ibarazaki", series: "Katawa Shoujo" },
  { name: "Rin Tezuka", series: "Katawa Shoujo" },
  { name: "Kenji Setou", series: "Katawa Shoujo" },
  { name: "Suzu Suzuki", series: "Katawa Shoujo" },
  { name: "Ryouta Murakami", series: "Gokukoku no Brynhildr" },
  { name: "Neko Kuroha", series: "Gokukoku no Brynhildr" },
  { name: "Kana Tachibana", series: "Gokukoku no Brynhildr" },
  { name: "Kazumi Schlierenzauer", series: "Gokukoku no Brynhildr" },
  { name: "Kotori Takatori", series: "Gokukoku no Brynhildr" },
  { name: "Hatsuna Wakabayashi", series: "Gokukoku no Brynhildr" },
]

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
  current_user.id = config["access_token"].split("-")[0]
end

streamer.user do |object|
  if object.is_a? Twitter::Tweet
    unless current_user.id == object.user.id
      unless object.text.start_with? "RT @"
        chosen_one = waifu.sample
        puts "#{object.user.screen_name}: #{chosen_one[:name]} - #{chosen_one[:series]}"
        client.update "@#{object.user.screen_name} Your waifu is #{chosen_one[:name]} (#{chosen_one[:series]})", in_reply_to_status:object
      end
    end
  end
end
