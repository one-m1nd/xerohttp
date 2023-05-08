# frozen_string_literal: true

require_relative "lib/xerohttp/version"

Gem::Specification.new do |spec|
  spec.name = "xerohttp"
  spec.version = XeroHTTP::VERSION
  spec.authors = ["Xero"]
  spec.email = ["vhector.1337@gmail.com"]

  spec.summary = "for fun HTTPrb wrapper"
  spec.homepage = "https://github.com/one-m1nd/xerohttp"
  spec.required_ruby_version = ">= 3"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/one-m1nd/xerohttp"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "http", "~> 5"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
