# frozen_string_literal: true

require_relative "../../../test_helper"

class Comfy::Archive::IndexControllerTest < ActionDispatch::IntegrationTest

  def setup
    @site   = comfy_cms_sites(:default)
    @index  = comfy_archive_indices(:default)
    @category = comfy_cms_categories(:default)
  end

  def test_get_index
    get @index.url(relative: true)
    assert_response :success
    assert_template :index
    assert assigns(:cms_index)
    assert assigns(:archive_pages)
    assert_equal 1, assigns(:archive_pages).size
  end

  def test_get_index_with_unpublished
    comfy_cms_pages(:child).update_column(:is_published, false)
    get @index.url(relative: true)
    assert_response :success
    assert_equal 0, assigns(:archive_pages).size
  end

  def test_get_index_for_month_archive
    get comfy_archive_pages_of_month_path(@index.url(relative: true), 1981, 10)
    assert_response :success
    assert_equal 1, assigns(:archive_pages).size

    get comfy_archive_pages_of_month_path(@index.url(relative: true), 2012, 12)
    assert_response :success
    assert_equal 0, assigns(:archive_pages).size
  end

  def test_get_index_with_category
    @category.categorizations.create!(categorized: @index.children.first)

    get comfy_archive_pages_of_category_path(@index.url(relative: true), @category.label)

    assert_response :success
    assert assigns(:archive_pages)
    assert_equal 1, assigns(:archive_pages).count
    assert assigns(:archive_pages).first.categories.member? @category
  end

  def test_get_index_with_category_invalid
    get comfy_archive_pages_of_category_path(@index.url(relative: true), "invalid")
    assert_response :success
    assert assigns(:archive_pages)
    assert_equal 0, assigns(:archive_pages).count
  end

  def test_get_index_is_sorted
    new_page = @site.pages.create!(
      parent:       comfy_cms_pages(:default),
      layout:       comfy_cms_layouts(:default),
      label:        "Test Page",
      slug:         "test-page",
      full_path:    "/blog/test-page",
      position:     0,
      is_published: true
    )
    new_datetime = new_page.fragments.create!(
      identifier: "publish_date",
      tag:        "datetime",
      datetime:   @index.children.first.published_at(@index.datetime_fragment) + 1.day
    )

    get @index.url(relative: true)

    assert_response :success
    assert assigns(:archive_pages)
    assert_equal 2, assigns(:archive_pages).count
    assert_equal [new_page, @index.children.first], assigns(:archive_pages).to_a
  end

  def test_get_show
    @index.children.first.fragments.create!(
      identifier: "content",
      tag:        "text",
      content:    "page content"
    )

    expected = <<~HTML.strip
      <p>
      Published on: 1981-10-04 12:34:56 UTC
      </p>
      page content
    HTML

    get comfy_archive_render_page_path(@index.children.first.full_path)
    assert_response :success
    assert_equal expected, response.body
  end

  def test_get_show_unpublished
    #assert_exception_raised ComfortableMexicanSofa::MissingPage do
    assert_exception_raised ActionController::RoutingError, 'Page Not Found at: "blog/unpublished-child-page"' do
      get comfy_archive_render_page_path(@index.children.last.full_path)
    end
  end

end
