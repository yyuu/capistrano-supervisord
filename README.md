# capistrano-supervisord

a capistrano recipe to deploy [supervisord](http://supervisord.org/) based services.

## Installation

Add this line to your application's Gemfile:

    gem 'capistrano-supervisord'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-supervisord

## Usage

This recipe will setup [supervisord](http://supervisord.org) during `deploy:setup` task.

To setup supervisord for your application, add following in you `config/deploy.rb`.

    # in "config/deploy.rb"
    require 'capistrano-supervisord'

Following options are available to manage your supervisord.

 * `:supervisord_configure_cleanup_files` - files to remove on configuring supervisord.
 * `:supervisord_configure_files` - list of configuration files for supervisord.
 * `:supervisord_configure_path` - the root path of configuration files. use `/` by default.
 * `:supervisord_configure_source_path` - the path to the templates of configuration files.
 * `:supervisord_install_apt_packages` - package name of `supervisord`.
 * `:supervisord_install_method` - install method. install from `:apt` by default.
 * `:supervisord_service_method` - service running method. use `:sysvinit` by default.
 * `:supervisord_service_name` - service name of `supervisord`. use `supervisor` by default.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Author

- YAMASHITA Yuu (https://github.com/yyuu)
- Geisha Tokyo Entertainment Inc. (http://www.geishatokyo.com/)

## License

MIT
