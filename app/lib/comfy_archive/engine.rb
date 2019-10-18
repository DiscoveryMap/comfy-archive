# frozen_string_literal: true

puts "Started loading ComfyArchive (engine.rb)"

#require "rubygems"
require "rails"
require "comfortable_mexican_sofa"
#require "comfy_archive"

module ComfyArchive

  module CmsSiteExtensions

    extend ActiveSupport::Concern
    included do
      has_many :archive_indices,
        class_name: "Archive::Index",
        dependent:  :destroy
    end

  end

  class Engine < ::Rails::Engine

    initializer "comfy_archive.configuration" do
      ComfortableMexicanSofa::ViewHooks.add(:navigation, "/comfy/admin/archive/partials/navigation")
      config.to_prepare do
        Comfy::Cms::Site.send :include, ComfyArchive::CmsSiteExtensions
      end
    end

  end

end

puts "Finished loading ComfyArchive (engine.rb)"
