# frozen_string_literal: true

require_relative "../../../test_helper"

class ArchiveIndicesTest < ActiveSupport::TestCase

  setup do
    @site   = comfy_cms_sites(:default)
    @index  = comfy_archive_indices(:default)
    @page   = comfy_cms_pages(:default)
    @child  = comfy_cms_pages(:child)
  end

  def new_params(options = {})
    { label:              "Test Archive Index",
      page:               @page,
      datetime_fragment:  "publish_date"
    }.merge(options)
  end

  # -- Tests -------------------------------------------------------------------

  def test_fixtures_validity
    Comfy::Archive::Index.all.each do |index|
      assert index.valid?, index.errors.full_messages.to_s
    end
  end

  def test_validations
    index = Comfy::Archive::Index.new
    assert index.invalid?
    assert_errors_on index, :site, :label, :page, :datetime_fragment
  end

  def test_validation_of_page_uniqueness
    index = @site.archive_indices.new(
      label: "Test Archive Index",
      page: @page,
      datetime_fragment: "publish_date"
    )
    assert index.invalid?
    assert_errors_on index, [:page]
  end

  def test_creation
    assert_difference -> { Comfy::Archive::Index.count } do
      index = @site.archive_indices.create!(
        label: "Test Archive Index",
        page: @child,
        datetime_fragment: "publish_date"
      )
    end
  end

  def test_url
    assert_equal @index.url, @page.url
    assert_equal @index.url(relative: true), @page.url(relative: true)
  end

  def test_children
    assert_equal @index.children, @page.children
    assert_equal @index.children(true), @page.children.published

    assert_equal 2, @index.children.count
    assert_equal 1, @index.children(true).count
  end

  def test_categories
    assert_equal 1, @index.categories.count
    assert_equal 0, @index.categories(true).count
  end

end
