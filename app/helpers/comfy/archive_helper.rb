# frozen_string_literal: true

module Comfy
  module ArchiveHelper

    require 'cgi'

    def comfy_archive_link_to_month(year, month)
      unless !@cms_index || year.blank? || month.blank?
        date = [I18n.t("date.month_names")[month.to_i], year].join(' ')
        link_to date, comfy_archive_pages_of_month_path(@cms_index.url(relative: false), year: year, month: month)
      end
    end

    def comfy_archive_link_to_category(category)
      if category.is_a? Comfy::Cms::Category
        label = category.label
      elsif category.is_a? String
        label = category
      end
      unless !@cms_index || category.blank?
        encoded_label = ComfyArchive.config.parameterize_category ? label.parameterize : CGI.escape(label)
        link_to label, comfy_archive_pages_of_category_path(@cms_index.url(relative: false), encoded_label)
      end
    end

  end
end
