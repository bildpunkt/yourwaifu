#!/usr/bin/env ruby
require 'sinatra'
require 'httparty'
require 'haml'
require 'yaml'

WAIFU = YAML.load_file File.expand_path(".", "lists/waifu.yml")
HUSBANDO = YAML.load_file File.expand_path(".", "lists/husbando.yml")
IMOUTO = YAML.load_file File.expand_path(".", "lists/imouto.yml")
SHIPGIRL = YAML.load_file File.expand_path(".", "lists/kancolle.yml")
TOUHOU = YAML.load_file File.expand_path(".", "lists/touhou.yml")
VOCALOID = YAML.load_file File.expand_path(".", "lists/vocaloid.yml")
IDOL = YAML.load_file File.expand_path(".", "lists/idol.yml")

get '/' do
  @waifu = WAIFU.sample
  @tweet = URI::encode("My waifu is #{@waifu['name']}! Who is yours? Find out at")
  haml :waifu, layout: :layout
end

get '/:list' do
  case params[:list]
    when /waifu/i
      @waifu = WAIFU.sample
      @type = "waifu"
    when /husbando/i
      @waifu = HUSBANDO.sample
      @type = "husbando"
    when /imouto/i
      @waifu = IMOUTO.sample
      @type = "imouto"
    when /shipgirl/i
      @waifu = SHIPGIRL.sample
      @type = "shipgirl"
    when /touhou/i
      @waifu = TOUHOU.sample
      @type = "touhou"
    when /vocaloid/i
      @waifu = VOCALOID.sample
      @type = "vocaloid"
    when /idol/i
      @waifu = IDOL.sample
      @type = "idol"
    else
      @waifu = WAIFU.sample
      @type = "waifu"
  end
  @tweet = URI::encode("My #{@type} is #{@waifu['name']}! Who is yours? Find it out at")
  haml :list, layout: :layout
end

get '/otp/' do
  @partner_a = WAIFU.sample
  @partner_b = HUSBANDO.sample
  @tweet = URI::encode("My OTP is #{@partner_a['name']} x #{@partner_b['name']}! Which is yours? Find out at")
  haml :otp, layout: :layout
end

get '/otp/:type' do
  case params[:type]
    when /yaoi/i
      @partner_a = HUSBANDO.sample
      @partner_b = HUSBANDO.sample
      @type = "yaoi OTP"
    when /yuri/i
      @partner_a = WAIFU.sample
      @partner_b = WAIFU.sample
      @type = "yuri OTP"
    else
      @partner_a = WAIFU.sample
      @partner_b = HUSBANDO.sample
      @type = "OTP"
  end
  @tweet = URI::encode("My #{@type} is #{@partner_a['name']} x #{@partner_b['name']}! Which is yours? Find out at")
  haml :otps, layout: :layout
end
