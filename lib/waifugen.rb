class WaifuGenerator

  # gen_single generates a single waifu reply
  # list_type (string): name of the list you want to generate something from
  # list (hash): specify the list the entry should be picked from
  # user (string/object): the user the reply should be sent to
  def gen_single(list_type, list, user)
    e = list.sample
    t = "@#{user} your #{list_type} is #{e['name']} (#{e['series']})"
    c = "[#{list_type}] #{user}: #{e['name']} - #{e['series']}"
    f = "#{e['series']}/#{e['name']}.#{e['filetype']}"
    return {character: e,
            tweet: t,
            console: c,
            path: f}
  end

  # gen_double generates an otp reply of the same series
  # list_type (string): name of the list you want to generate something from
  # list (hash): specify the list the entry should be picked from
  # user (string/object): the user the reply should be sent to
  def gen_double(list_type, list, user)
    e1 = list.sample
    e2 = list.sample
    t = "@#{user} your OTP is #{e1['name']} x #{e2['name']} (#{e1['series']})"
    c = "[#{list_name} OTP] #{user}: #{e1['name']} x #{e2['name']}"
    return {character_1: e1,
            character_2: e2,
            tweet: t,
            console: c}
  end

  # gen_multi generates an otp reply with multiple series
  # list_type (string): name of the list you want to generate something from
  # list_1 (hash): specify the first list the entry should be picked from
  # list_2 (hash): specify the second list the entry should be picked from
  # user (string/object): the user the reply should be sent to  
  def gen_multi(list_type, list_1, list_2, user)
    e1 = list_1.sample
    e2 = list_2.sample
    t = "@#{user} your OTP is #{e1['name']} x #{e2['name']} (#{e1['series']}|#{e2['series']})"
    c = "[#{list_name} OTP] #{user}: #{e1['name']} x #{e2['name']}"
    return {character_1: e1,
            character_2: e2,
            tweet: t,
            console: c}
  end
end
