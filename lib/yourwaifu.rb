require 'yourwaifu/defaults'
require 'yourwaifu/basewaifu'

module YourWaifu
  # @param tweet [Twitter::Tweet] A tweet object.
  # @param tweet [String] The tweet text.
  # @return [Array] Array containing the perfect husbando/OTP as a subclass of YourWaifu::Base.
  def self.pick(tweet)
    text = (tweet.is_a?(Twitter::Tweet) ? tweet.text : tweet)
    pick_otp = !!text.match(/(?:^|\s)otp(?:\s|$)/i)  # matches if it contains the whole word 'otp'
    case text
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
   []
  end
end
