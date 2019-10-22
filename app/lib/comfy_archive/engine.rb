# frozen_string_literal: true

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

  module CmsPageExtensions

    extend ActiveSupport::Concern
    included do
      scope :chronologically, ->(datetime_fragment) { joins(:fragments).where(comfy_cms_fragments: {identifier: datetime_fragment}).unscope(:order).order(Arel.sql("`comfy_cms_fragments`.`datetime` DESC")) }
      scope :for_year, ->(datetime_fragment, year) { chronologically(datetime_fragment).where("YEAR(comfy_cms_fragments.datetime) = ?", year) }
      scope :for_month, ->(datetime_fragment, month) { chronologically(datetime_fragment).where("MONTH(comfy_cms_fragments.datetime) = ?", month) }
    end

  end

  class Engine < ::Rails::Engine

    initializer "comfy_archive.configuration" do
      ComfortableMexicanSofa::ViewHooks.add(:navigation, "/comfy/admin/archive/partials/navigation")
      config.to_prepare do
        Comfy::Cms::Site.send :include, ComfyArchive::CmsSiteExtensions
        Comfy::Cms::Page.send :include, ComfyArchive::CmsPageExtensions
      end
    end

  end

end
