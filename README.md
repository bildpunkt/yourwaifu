# yourwaifu

A twitter bot that will respond to mentions with a randomly picked person, which resembles your perfect waifu material.

## Usage

`ruby waifu.rb`

**Tip:** Keep it running in a Screen/tmux session or otherwise it will just close again after you disconnect from your server/machine you host the bot on.

## Setup

### Requirements

* Ruby, *should be a package simply called* `ruby` *for your \*nix system*, or use RubyInstaller.
* Twitter `gem install twitter`
* **Optional:** Tumblr `gem install tumblr_client`

### Making it Work

#### Twitter

* Go to [Twitter Apps](https://apps.twitter.com/) and create a new application
* Generate your consumer/access token keys/secrets for Read and Write access
* Add your consumer/access token keys/secrets to `config.yml.example` and rename it to `config.yml`

#### Status Accounts

Optional accounts you can set up to inform your followers about status limit of the bot.

##### Twitter

* Repeat steps from above
* In your `config.yml` in `statustwitter`, set `enabled` to true

##### Tumblr

If you want to post updates to Tumblr when the bot is limited, do the following:

* In `config.yml` set `enabled` to true and add the name of your blog
* Go to [Tumblr](https://www.tumblr.com/oauth/apps) and create a new application
* Add your consumer/access token keys/secrets to the config file

After you added the keys, simply execute `ruby waifu.rb` and it should work!

## Contributing

Missing your waifu? Here are some simply ways to get those you want onto the list:

### Shizune, the request platform

With the creation of shizune, the web request platform for yourwaifu ([repository](https://github.com/yourwaifu/shizune) | [live instance](http://shizune.pii.moe)) you can easily request entries for the bot!

### Open an issue on GitHub

Visit the issue-page of this repository and open a new issue with the characters you want to have added, really simple!

### Add them yourself and make a Pull Request

The people that feel adventurous and have a bit of coding knowledge can try adding their wishes to the bot themself, just edit the `waifu.yml` file and add your waifu-entries, but people keep the format of the initial entries.

**Warning:** Cloning this repository to a Windows-based system might not work as the folder names utilize characters that are not usable in directory-names on Windows, please choose the first option of contributing then.

### Images

I have to add images to the bot by hand, because accessing imageboards over their (XML-based) APIs is a lot of work and I want to keep this bots code as simple as possible, so...
to help me adding images of specific series, you can simply search for images yourself (not too big, Twitter will scale them anyway) and rename them to the character names as stated in `waifu.yml` (case-sensitive), and convert them if they are not already in `.png` to that format. 
Afterwards, just zip the file, upload it to any filehoster and put the link in an issue so I can simply access it.

## Contributors

* [ch1zuru](https://github.com/ch1zuru) for the idea
* [nilsding](http://github.com/nilsding) for help with coding
* [SakisaKawaii](http://twitter.com/SakisaKawaii) for help with the request listing
* Everyone who contributes to the list!

## License

yourwaifu(bot) is licensed under the [MIT License](http://opensource.org/licenses/MIT)
