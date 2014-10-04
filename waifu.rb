require "yaml"
require "twitter"
require "ostruct"

keys = YAML.load_file File.expand_path(".", "config.yml")

waifu = [
  # Grisaia no Kajitsu
  { name: "Yuuji Kazami", series: "Grisaia no Kajitsu" },
  { name: "Yumiko Sakake", series: "Grisaia no Kajitsu" },
  { name: "Amane Suou", series: "Grisaia no Kajitsu" },
  { name: "Michiru Matsushima", series: "Grisaia no Kajitsu" },
  { name: "Makina Irisu", series: "Grisaia no Kajitsu" },
  { name: "Sachi Komine", series: "Grisaia no Kajitsu" },
  { name: "Chizuru Tachibana", series: "Grisaia no Kajitsu" },
  { name: "Kazuki Kazami", series: "Grisaia no Kajitsu" },
  
  # Katawa Shoujo
  { name: "Hanako Ikezawa", series: "Katawa Shoujo" },
  { name: "Lilly Satou", series: "Katawa Shoujo" },
  { name: "Shizune Hakamichi", series: "Katawa Shoujo" },
  { name: "Hideaki Hakamichi", series: "Katawa Shoujo" },
  { name: "Shiina \"Misha\" Mikado", series: "Katawa Shoujo" },
  { name: "Emi Ibarazaki", series: "Katawa Shoujo" },
  { name: "Rin Tezuka", series: "Katawa Shoujo" },
  { name: "Kenji Setou", series: "Katawa Shoujo" },
  { name: "Suzu Suzuki", series: "Katawa Shoujo" },
  
  # Gokukoku no Brynhildr
  { name: "Ryouta Murakami", series: "Gokukoku no Brynhildr" },
  { name: "Neko Kuroha", series: "Gokukoku no Brynhildr" },
  { name: "Kana Tachibana", series: "Gokukoku no Brynhildr" },
  { name: "Kazumi Schlierenzauer", series: "Gokukoku no Brynhildr" },
  { name: "Kotori Takatori", series: "Gokukoku no Brynhildr" },
  { name: "Hatsuna Wakabayashi", series: "Gokukoku no Brynhildr" },
  
  # Steins;Gate
  { name: "Rintarō Okabe", series: "Steins;Gate" },
  { name: "Kurisu Makise", series: "Steins;Gate" },
  { name: "Mayuri Shiina", series: "Steins;Gate" },
  { name: "Ruka Urushibara", series: "Steins;Gate" },
  
  # To Aru Kagaku no Railgun
  { name: "Misaka Mikoto", series: "To Aru Kagaku no Railgun" },
  { name: "Ruiko Saten", series: "To Aru Kagaku no Railgun" },
  { name: "Kazari Uiharu", series: "To Aru Kagaku no Railgun" },
  { name: "Kuroko Shirai", series: "To Aru Kagaku no Railgun" },
  
  # Monogatari Series
  { name: "Tsukihi Araragi", series: "Monogatari Series" },
  { name: "Tsubasa Hanekawa", series: "Monogatari Series" },
  { name: "Shinobu Oshino", series: "Monogatari Series" },
  { name: "Nadeko Sengoku", series: "Monogatari Series" },
  { name: "Karen Araragi", series: "Monogatari Series" },
  
  # Kill la Kill
  { name: "Ryuuko Matoi", series: "Kill la Kill" },
  { name: "Satsuki Kiryuuin", series: "Kill la Kill" },
  { name: "Nonon Jakuzure", series: "Kill la Kill" },
  
  # Rail Wars
  { name: "Aoi Sakurai", series: "Rail Wars" },
  { name: "Haruka Koumi", series: "Rail Wars" },
  
  # Yuru Yuri
  { name: "Akari Akaza", series: "Yuru Yuri" },
  { name: "Kyouko Toshino", series: "Yuru Yuri" },
  { name: "Yui Funami", series: "Yuru Yuri" },
  { name: "Chinatsu Yoshikawa", series: "Yuru Yuri" },
  
  # DanganRonpa
  { name: "Junko Enoshima", series: "DanganRonpa" },
  { name: "Chihiro Fujisaki", series: "DanganRonpa" },
  
  # Kyoukai no Kanata
  { name: "Mirai Kuriyama", series: "Kyoukai no Kanata" },
  { name: "Izumi Nase", series: "Kyoukai no Kanata" },
  
  # Fate Series
  { name: "Illyasviel von Einzbern", series: "Fate/kaleid liner Prisma☆Illya" },
  { name: "Rin Tohsaka", series: "Fate/kaleid liner Prisma☆Illya" },
  { name: "Luvia Edelfelt", series: "Fate/stay" },
  { name: "Irisviel von Einzbern", series: "Fate/zero" },
  
  # OreImo
  { name: "Ayase Aragaki", series: "OreImo" },
  { name: "Kanako Kurusu", series: "OreImo" },
  
  # Evangelion
  { name: "Asuka Langley", series: "Evangelion" },
  { name: "Misato Kitsuragi", series: "Evangelion" },
  
  # No Game No Life
  { name: "Shiro", series: "No Game No Life" },
  { name: "Stephanie Dora", series: "No Game No Life" },
  { name: "Jibril", series: "No Game No Life" },
  { name: "Izuna Hatsuse", series: "No Game No Life" },
  
  # Tonari no Kaibutsu-kun
  { name: "Shizuku Mizutani", series: "Tonari no Kaibutsu-kun" },
  { name: "Asako Natsume", series: "Tonari no Kaibutsu-kun" },
  { name: "Iyo Yamaguchi", series: "Tonari no Kaibutsu-kun" },
  
  # Toradora
  { name: "Aisaka Taiga", series: "Toradora" },
  { name: "Minori Kushieda", series: "Toradora" },
  { name: "Ami Kawashima", series: "Toradora" },
  
  # Highschool DxD
  { name: "Akeno Himejima", series: "Highschool DxD" },
  { name: "Koneko Toujou", series: "Highschool DxD" },
  { name: "Xenovia", series: "Highschool DxD" },
  
  # The Idolm@ster
  { name: "Chihaya Kisaragi", series: "The Idolm@\u200bster" },
  { name: "Producer", series: "The Idolm@\u200bster" },
  { name: "Makoto Kikuchi", series: "The Idolm@\u200bster" },
  { name: "Haruka Amami", series: "The Idolm@\u200bster" },
  { name: "Chihaya Kisaragi", series: "The Idolm@\u200bster" },
  { name: "Yukiho Hagiwara", series: "The Idolm@\u200bster" },
  { name: "Yayoi Takatsuki", series: "The Idolm@\u200bster" },
  { name: "Ritsuko Akizuki", series: "The Idolm@\u200bster" },
  { name: "Azusa Miura", series: "The Idolm@\u200bster" },
  { name: "Iori Minase", series: "The Idolm@\u200bster" },
  { name: "Mami Futami", series: "The Idolm@\u200bster" },
  { name: "Ami Futami", series: "The Idolm@\u200bster" },
  
  # Love Live!
  { name: "Nozomi Toujou", series: "Love Live!" },
  { name: "Kira Tsubasa", series: "Love Live!" },
  { name: "Honoka Kōsaka", series: "Love Live!" },
  { name: "Umi Sonoda", series: "Love Live!" },
  { name: "Kotori Minami", series: "Love Live!" },
  { name: "Nico Yazawa", series: "Love Live!" },
  { name: "Eli Ayase", series: "Love Live!" },
  { name: "Maki Nishikino", series: "Love Live!" },
  { name: "Hanayo Koizumi", series: "Love Live!" },
  { name: "Rin Hoshizora", series: "Love Live!" },
  
  # Himegoto
  { name: "18-kin", series: "Himegoto" },
  { name: "Unko", series: "Himegoto" },
  
  # K-ON!
  { name: "Yui Hirasawa", series: "K-ON!" },
  { name: "Ritsu Tainaka", series: "K-ON!" },
  
  # Kiniro Mosaic
  { name: "Shinobu Omiya", series: "Kiniro Mosaic" },
  { name: "Alice Cartalet", series: "Kiniro Mosaic" },
  { name: "Aya Komichi", series: "Kiniro Mosaic" },
  { name: "Yoko Inokuma", series: "Kiniro Mosaic" },
  { name: "Karen Kujo", series: "Kiniro Mosaic" },
  { name: "Isami Omiya", series: "Kiniro Mosaic" },
  { name: "Sakura Karasuma", series: "Kiniro Mosaic" },
  { name: "Akari Kuzehashi", series: "Kiniro Mosaic" },
  { name: "Honoka Matsubara", series: "Kiniro Mosaic" },
  
  # Mahou Shoujo Madoka★Magica
  { name: "Akemi Homura", series: "Mahou Shoujo Madoka★Magica" },
  { name: "Sakura Kyoko", series: "Mahou Shoujo Madoka★Magica" },
  { name: "Madoka Kaname", series: "Mahou Shoujo Madoka★Magica" },
  { name: "Mami Tomoe", series: "Mahou Shoujo Madoka★Magica" },
  { name: "Sayaka Miki", series: "Mahou Shoujo Madoka★Magica" },
  { name: "Nagisa Momoe", series: "Mahou Shoujo Madoka★Magica" },
  { name: "Kyubey", series: "Mahou Shoujo Madoka★Magica" },
  
  # Haganai
  { name: "Maria Takayama", series: "Haganai" },
  { name: "Yukimura Kusunoki", series: "Haganai" },
  
  # Angel Beats
  { name: "Kanade Tachibana", series: "Angel Beats!" },
  
  # Aria the Origination
  { name: "Akari Mizunashi", series: "Aria the Origination" },
  
  # C³
  { name: "Fear Kubrick", series: "C³" },
  
  # Corpse Party
  { name: "Ayumi Shinozaki", series: "Corpse Party" },
  
  # Date a Live
  { name: "Kurumi Tokisaki", series: "Date a Live" },
  
  # Deadman Wonderland
  { name: "Shiro", series: "Deadman Wonderland" },
  
  # Kore wa Zombie desu ka?
  { name: "Haruna", series: "Kore wa Zombie desu ka?" },
  
  # Sailor Moon
  { name: "Makoto Kino", series: "Sailor Moon" },
  
  # Spice & Wolf
  { name: "Horo", series: "Spice & Wolf" },
  
  # Shingeki no Kyojin
  { name: "Mikasa Ackerman", series: "Shingeki no Kyojin" },
  
  # Shinsekai Yori
  { name: "Saki Watanabe", series: "Shinsekai Yori" },
  
  # Suzumiya Haruhi no Yūutsu
  { name: "Haruhi Suzumiya", series: "Suzumiya Haruhi no Yūutsu" },
  
  # Teekyu
  { name: "Kanae Shinjou", series: "Teekyu" },
  
  # Wake Up, Girls!
  { name: "Yoshino \"Yoppi\" Nanase", series: "Wake Up, Girls!" },
  { name: "Mayu Shimada", series: "Wake Up, Girls!" },
  { name: "Airi Hayashida", series: "Wake Up, Girls!" },
  { name: "Minami Katayama", series: "Wake Up, Girls!" },
  { name: "Nanami Hisami", series: "Wake Up, Girls!" },
  { name: "Kaya Kikuma", series: "Wake Up, Girls!" },
  { name: "Miyu Okamoto", series: "Wake Up, Girls!" },
  
  # WataMote
  { name: "Tomoko Kuroki", series: "WataMote" },
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
