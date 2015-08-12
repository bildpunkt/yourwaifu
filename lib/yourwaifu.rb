require 'yourwaifu/defaults'
require 'yourwaifu/base'

require 'yourwaifu/types/imouto'
require 'yourwaifu/types/touhou'
require 'yourwaifu/types/kancolle'
require 'yourwaifu/types/idol'
require 'yourwaifu/types/waifu'
require 'yourwaifu/types/vocaloid'
require 'yourwaifu/types/husbando'

# The YourWaifu module!
module YourWaifu
  # The class to get an entry from if nothing matched.
  DEFAULT_CLASS = YourWaifu::Waifu
  # Regular expression => class.  This is in the order of the lookup sequence.
  # Value may be a Array to make OTP combinations.  These will only be
  # triggered if an OTP must be picked.
  MATCHED_CLASSES = {
    /husbando?/i => YourWaifu::Husbando,
    /imouto/i    => YourWaifu::Imouto,
    /shipgirl/i  => YourWaifu::Kancolle,
    /touhou/i    => YourWaifu::Touhou,
    /vocaloid/i  => YourWaifu::Vocaloid,
    /idol/i      => YourWaifu::Idol,
    /yuri/i      => [YourWaifu::Waifu, YourWaifu::Waifu],
    /yaoi/i      => [YourWaifu::Husbando, YourWaifu::Husbando],
    /otp/i       => [YourWaifu::Waifu, YourWaifu::Husbando],
  }

  # @param tweet [Twitter::Tweet] A tweet object.
  # @param tweet [String] The tweet text.
  # @return [Hash] Hash containing the keys `:matches` (Array of Hash),
  #   `:title` (String), and `:is_otp` (Boolean).  
  #   The `:matches` array contains the perfect husbando/OTP as returned by
  #   YourWaifu::Base#sample.  
  #   The `:title` string is the title of the first match as returned by
  #   YourWaifu::Base#title.  
  #   The `:is_otp` boolean is true if the returned match is a OTP pairing.
  def self.pick(tweet)
    text = (tweet.is_a?(::Twitter::Tweet) ? tweet.text : tweet)
    pick_otp = !!text.match(/(?:^|\s)otp(?:\s|$)/i)  # matches if it contains the whole word 'otp'
    
    klasses = match_classes(text, pick_otp)
    
    {
      matches: klasses.map{ |klass| klass.new.sample },
      title:   klasses.first.new.title,
      is_otp:  pick_otp
    }
  end

  # Matches one or multiple classes to a given `text`.  If `pick_otp` is
  # given, two of the same classes will be returned.  If there was no
  # successful match, an array with `DEFAULT_CLASS` as the only item is
  # returned.
  # @return [Array] containing a subclass of YourWaifu::Base
  def self.match_classes(text, pick_otp = false)
    MATCHED_CLASSES.each do |regexp, klass|
      if !!text.match(regexp)
        return (klass.is_a?(Array) ? klass
                                   : [klass, (pick_otp ? klass : nil)].compact)
      end
    end
    [DEFAULT_CLASS, (pick_otp ? klass : nil)].compact
  end
end
