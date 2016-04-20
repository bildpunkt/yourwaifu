# yourwaifu

A website that will give you a randomly picked person, which resembles your perfect waifu material.

## Usage

see the last point in the Installation section

**Tip:** Keep it running in a Screen/tmux session or otherwise it will just close again after you disconnect from your server/machine you host the site on.

## Setup

### Requirements

* Ruby, *should be a package simply called* `ruby` *for your \*nix system*.
* An Unix system (FreeBSD and OS X work fine)
* Bundler (install it with `gem install bundler`)

### Installation

* `bundle install`
* copy example nginx config (`nginx.conf.example`) to your nginx directory and change it according to your configuration
* edit `./config/unicorn.rb` to set the amount of unicorn workers
* run `bundle exec unicorn -E production -c ./config/unicorn.rb -l unix:./yourwaifu.sock`

## Contributing

Missing your waifu? Here are some simply ways to get those you want onto the list:

### Open an issue on GitHub

Visit the issue-page of this repository and open a new issue with the characters you want to have added, really simple!

### Add them yourself and make a Pull Request

The people that feel adventurous and have a bit of coding knowledge can try adding their wishes to the bot themself, just edit the `waifu.yml` file and add your waifu-entries, but people keep the format of the initial entries.

**Warning:** Cloning this repository to a Windows-based system might not work as the folder names utilize characters that are not usable in directory-names on Windows, please choose the first option of contributing then.

## Contributors

* [ch1zuru](https://github.com/ch1zuru) for the idea
* [nilsding](http://github.com/nilsding) for help with coding
* [SakisaKawaii](http://twitter.com/SakisaKawaii) for help with the request listing
* Everyone who contributes to the list!

## License

yourwaifu(bot) is licensed under the [MIT License](http://opensource.org/licenses/MIT)
