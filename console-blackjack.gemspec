# frozen_string_literal: true

# gem build console-blackjack.gemspec
# gem push console-blackjack-1.1.7.gem

require 'rake'

Gem::Specification.new do |spec|
  spec.required_ruby_version = '>= 3.4'
  spec.name = 'console-blackjack'
  spec.version = '1.1.7'
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
    'source_code_uri' => 'https://github.com/gdonald/console-blackjack-ruby',
    'rubygems_mfa_required' => 'true'
  }
  spec.license = 'MIT'
  spec.post_install_message = "\nType `console-blackjack` to run!\n\n"
end
