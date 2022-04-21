# frozen_string_literal: true

require_relative "../test_helper"

class ArchiveHelperTest < ActionView::TestCase

  include Comfy::ArchiveHelper

  setup do
    # We're simulating instance variables that are present on the view/controller
    @cms_site = comfy_cms_sites(:default)
    @cms_index = comfy_archive_indices(:default)
    @category = comfy_cms_categories(:default)
    @year = 2022
    @month = 4
  end

  def test_comfy_archive_link_to_category
    assert_not ComfyArchive.config.parameterize_category
    assert_equal link_to(@category.label, comfy_archive_pages_of_category_path(@cms_index.url(relative: false), CGI.escape(@category.label))), comfy_archive_link_to_category(@category)
  end

  def test_comfy_archive_link_to_category_with_string
    assert_not ComfyArchive.config.parameterize_category
    assert_equal link_to(@category.label, comfy_archive_pages_of_category_path(@cms_index.url(relative: false), CGI.escape(@category.label))), comfy_archive_link_to_category(@category.label)
  end

  def test_comfy_archive_link_to_category_parameterized
    ComfyArchive.config.parameterize_category = true
    with_routing do |set|
      set.draw do
        comfy_route :archive_admin
        comfy_route :archive
      end
      assert ComfyArchive.config.parameterize_category
      assert_equal link_to(@category.label, comfy_archive_pages_of_category_path(@cms_index.url(relative: false), @category.label.parameterize)), comfy_archive_link_to_category(@category)
    end
  end

  def test_comfy_archive_link_to_category_parameterized_with_string
    ComfyArchive.config.parameterize_category = true
    with_routing do |set|
      set.draw do
        comfy_route :archive_admin
        comfy_route :archive
      end
      assert ComfyArchive.config.parameterize_category
      assert_equal link_to(@category.label, comfy_archive_pages_of_category_path(@cms_index.url(relative: false), @category.label.parameterize)), comfy_archive_link_to_category(@category.label)
    end
  end

  def test_comfy_archive_link_to_month
    date = [I18n.t("date.month_names")[@month.to_i], @year].join(' ')
    assert_equal link_to(date, comfy_archive_pages_of_month_path(@cms_index.url(relative: false), year: @year, month: @month)), comfy_archive_link_to_month(@year, @month)
  end

end
