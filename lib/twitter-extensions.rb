class NotImportantException < Exception ; end
class FilteredException < Exception ; end
class FilteredClientException < FilteredException ; end
class FilteredUserException < FilteredException ; end
class FilteredTweetException < FilteredException ; end

class Twitter::Tweet
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

class Twitter::REST::Client
  def get_current_user
    self.current_user
  rescue Exception => e
    puts "Exception: #{e.message}"
    # best hack:
    ostr = OpenStruct.new
    ostr.id = KEYS['twitter']["access_token"].split("-")[0]
    ostr
  end
end
