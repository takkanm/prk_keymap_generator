# frozen_string_literal: true

require_relative "lib/prk_keymap_generator/version"

Gem::Specification.new do |spec|
  spec.name          = "prk_keymap_generator"
  spec.version       = PrkKeymapGenerator::VERSION
  spec.authors       = ["Mitsutaka Mimura"]
  spec.email         = ["takkanm@gmail.com"]

  spec.summary       = "Generator prk_firmware keymap.rb from qmk"
  spec.description   = "Generator prk_firmware keymap.rb from qmk"
  spec.homepage      = "https://github.com/takkanm/prk_keymap_generator"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.4.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/takkanm/prk_keymap_generator"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
