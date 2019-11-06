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
      scope :chronologically, ->(datetime_fragment) { joins(:fragments).where(comfy_cms_fragments: {identifier: datetime_fragment}).reorder(Arel.sql("`comfy_cms_fragments`.`datetime` DESC")) }
      scope :for_year, ->(datetime_fragment, year) {
        case ActiveRecord::Base.connection.adapter_name.downcase.to_sym
        when :mysql, :mysql2
          chronologically(datetime_fragment).where("YEAR(comfy_cms_fragments.datetime) = ?", year)
        when :sqlite
          chronologically(datetime_fragment).where("strftime('%Y', comfy_cms_fragments.datetime) = ?", year.to_s)
        else
          raise NotImplementedError, "Unknown adapter type '#{ActiveRecord::Base.connection.adapter_name}'"
        end
      }
      scope :for_month, ->(datetime_fragment, month) {
        case ActiveRecord::Base.connection.adapter_name.downcase.to_sym
        when :mysql, :mysql2
          chronologically(datetime_fragment).where("MONTH(comfy_cms_fragments.datetime) = ?", month)
        when :sqlite
          chronologically(datetime_fragment).where("strftime('%m', comfy_cms_fragments.datetime) = ?", month.to_s)
        else
          raise NotImplementedError, "Unknown adapter type '#{ActiveRecord::Base.connection.adapter_name}'"
        end
      }

      def published_at(datetime_fragment)
        self.fragments.where(identifier: datetime_fragment).first.datetime
      end
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
