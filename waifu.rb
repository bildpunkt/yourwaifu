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
  { name: "Rintarō Okabe", series: "Steins;Gate" },
  { name: "Kurisu Makise", series: "Steins;Gate" },
  { name: "Mayuri Shiina", series: "Steins;Gate" },
  { name: "Ruka Urushibara", series: "Steins;Gate" },
  { name: "Misaka Mikoto", series: "To Aru Kagaku no Railgun" },
  { name: "Ruiko Saten", series: "To Aru Kagaku no Railgun" },
  { name: "Kazari Uiharu", series: "To Aru Kagaku no Railgun" },
  { name: "Kuroko Shirai", series: "To Aru Kagaku no Railgun" },
  { name: "Tsukihi Araragi", series: "Monogatari Series" },
  { name: "Tsubasa Hanekawa", series: "Monogatari Series" },
  { name: "Shinobu Oshino", series: "Monogatari Series" },
  { name: "Nadeko Sengoku", series: "Monogatari Series" },
  { name: "Karen Araragi", series: "Monogatari Series" },
  { name: "Ryuuko Matoi", series: "Kill la Kill" },
  { name: "Satsuki Kiryuuin", series: "Kill la Kill" },
  { name: "Nonon Jakuzure", series: "Kill la Kill" },
  { name: "Aoi Sakurai", series: "Rail Wars" },
  { name: "Haruka Koumi", series: "Rail Wars" },
  { name: "Akari Akaza", series: "Yuru Yuri" },
  { name: "Kyouko Toshino", series: "Yuru Yuri" },
  { name: "Junko Enoshima", series: "DanganRonpa" },
  { name: "Chihiro Fujisaki", series: "DanganRonpa" },
  { name: "Mirai Kuriyama", series: "Kyoukai no Kanata" },
  { name: "Izumi Nase", series: "Kyoukai no Kanata" },
  { name: "Illyasviel von Einzbern", series: "Fate/kaleid liner Prisma☆Illya" },
  { name: "Rin Tohsaka", series: "Fate/kaleid liner Prisma☆Illya" },
  { name: "Luvia Edelfelt", series: "Fate/stay" },
  { name: "Irisviel von Einzbern", series: "Fate/zero" },
  { name: "Ayase Aragaki", series: "OreImo" },
  { name: "Kanako Kurusu", series: "OreImo" },
  { name: "Asuka Langley", series: "Evangelion" },
  { name: "Misato Kitsuragi", series: "Evangelion" },
  { name: "Shiro", series: "No Game No Life" },
  { name: "Stephanie Dora", series: "No Game No Life" },
  { name: "Jibril", series: "No Game No Life" },
  { name: "Izuna Hatsuse", series: "No Game No Life" },
  { name: "Shizuku Mizutani", series: "Tonari no Kaibutsu-kun" },
  { name: "Asako Natsume", series: "Tonari no Kaibutsu-kun" },
  { name: "Iyo Yamaguchi", series: "Tonari no Kaibutsu-kun" },
  { name: "Aisaka Taiga", series: "Toradora" },
  { name: "Minori Kushieda", series: "Toradora" },
  { name: "Ami Kawashima", series: "Toradora" },
  { name: "Akeno Himejima", series: "Highschool DxD" },
  { name: "Koneko Toujou", series: "Highschool DxD" },
  { name: "Xenovia", series: "Highschool DxD" },
  { name: "Chihaya Kisaragi", series: "The Idolm@" + "\u200b" + "ster" },
  { name: "Producer", series: "The Idolm@" + "\u200b" + "ster" },
  { name: "Makoto Kikuchi", series: "The Idolm@" + "\u200b" + "ster" },
  { name: "Nozomi Toujou", series: "Love Live!" },
  { name: "Kira Tsubasa", series: "Love Live!" },
  { name: "18-kin", series: "Himegoto" },
  { name: "Unko", series: "Himegoto" },
  { name: "Yui Hirasawa", series: "K-ON!" },
  { name: "Ritsu Tainaka", series: "K-ON!" },
  { name: "Akemi Homura", series: "Mahou Shoujo Madoka★Magica" },
  { name: "Sakura Miki", series: "Mahou Shoujo Madoka★Magica" },
  { name: "Maria Takayama", series: "Haganai" },
  { name: "Yukimura Kusunoki", series: "Haganai" },
  { name: "Kanade Tachibana", series: "Angel Beats!" },
  { name: "Akari Mizunashi", series: "Aria the Origination" },
  { name: "Fear Kubrick", series: "C³" },
  { name: "Ayumi Shinozaki", series: "Corpse Party" },
  { name: "Kurumi Tokisaki", series: "Date a Live" },
  { name: "Shiro", series: "Deadman Wonderland" },
  { name: "Haruna", series: "Kore wa Zombie desu ka?" },
  { name: "Makoto Kino", series: "Sailor Moon" },
  { name: "Horo", series: "Spice & Wolf" },
  { name: "Mikasa Ackerman", series: "Shingeki no Kyojin" },
  { name: "Saki Watanabe", series: "Shinsekai Yori" },
  { name: "Haruhi Suzumiya", series: "Suzumiya Haruhi no Yūutsu" },
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
