# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "comfy_archive/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "comfy_archive"
  s.version     = ComfyArchive::VERSION
  s.authors     = ["Morgan Aldridge"]
  s.email       = ["morgan@discoverymap.com"]
  s.homepage    = "http://github.com/discoverymap/comfy-archive"
  s.summary     = "Chronological Archives Engine for ComfortableMexicanSofa"
  s.description = "Chronological Archives Engine for ComfortableMexicanSofa"
  s.license     = "MIT"

  s.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|doc)/})
  end

  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 2.3.0"

  s.add_dependency "comfortable_mexican_sofa", ">= 2.0.14"
end
