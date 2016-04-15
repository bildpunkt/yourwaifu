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
  waifu = WAIFU.sample
  "Your waifu is #{waifu['name']} from #{waifu['series']}"
end

get '/:list' do
  case params[:list]
    when /waifu/i
      waifu = WAIFU.sample
      type = "waifu"
    when /husbando/i
      waifu = HUSBANDO.sample
      type = "husbando"
    when /imouto/i
      waifu = IMOUTO.sample
      type = "imouto"
    when /shipgirl/i
      waifu = SHIPGIRL.sample
      type = "shipgirl"
    when /touhou/i
      waifu = TOUHOU.sample
      type = "touhou"
    when /vocaloid/i
      waifu = VOCALOID.sample
      type = "vocaloid"
    when /idol/i
      waifu = IDOL.sample
      type = "idol"
    else
      waifu = WAIFU.sample
      type = "waifu"
  end
  "Your #{type} is #{waifu['name']} from #{waifu['series']}"
end

get '/otp/' do
  partner_a = WAIFU.sample
  partner_b = HUSBANDO.sample
  "Your OTP is #{partner_a['name']} x #{partner_b['name']} (#{partner_a['series']}/#{partner_b['series']})"
end

get '/otp/:type' do
  case params[:type]
    when /yaoi/i
      partner_a = HUSBANDO.sample
      partner_b = HUSBANDO.sample
      type = "yaoi OTP"
    when /yuri/i
      partner_a = WAIFU.sample
      partner_b = WAIFU.sample
      type = "yuri OTP"
    else
      partner_a = WAIFU.sample
      partner_b = HUSBANDO.sample
      type = "OTP"
  end
  "Your #{type} is #{partner_a['name']} x #{partner_b['name']} (#{partner_a['series']}/#{partner_b['series']})"
end
