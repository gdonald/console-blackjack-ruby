# frozen_string_literal: true

require 'rake'

Gem::Specification.new do |spec|
  spec.required_ruby_version = '>= 2.7.4'
  spec.name = 'console-blackjack'
  spec.version = '1.0.8'
  spec.date = '2021-07-17'
  spec.summary = 'Console Blackjack'
  spec.description = 'Blackjack for your console, full version.'
  spec.author = 'Greg Donald'
  spec.email = 'gdonald@gmail.com'
  spec.bindir = 'bin'
  spec.executables << 'console-blackjack'
  spec.files = FileList['lib/**/*.rb',
                        'bin/*',
                        '[A-Z]*',
                        'spec/**/*.rb'].to_a
  spec.homepage = 'https://github.com/gdonald/console-blackjack-ruby'
  spec.metadata = {
    'source_code_uri' => 'https://github.com/gdonald/console-blackjack-ruby'
  }
  spec.license = 'MIT'
  spec.post_install_message = "\nType `console-blackjack` to run!\n\n"
end
