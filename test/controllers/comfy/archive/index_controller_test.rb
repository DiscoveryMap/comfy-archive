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
    assert_template :index
    assert_equal 0, assigns(:archive_pages).size
  end

  def test_get_index_for_month_archive
    get comfy_archive_pages_of_month_path(@index.url(relative: true), 1981, 10)
    assert_response :success
    assert_template :index
    assert_equal "1981", assigns(:year)
    assert_equal "10", assigns(:month)
    assert_equal 1, assigns(:archive_pages).size

    get comfy_archive_pages_of_month_path(@index.url(relative: true), 2012, 12)
    assert_response :success
    assert_template :index
    assert_equal "2012", assigns(:year)
    assert_equal "12", assigns(:month)
    assert_equal 0, assigns(:archive_pages).size
  end

  def test_get_index_with_category
    @category.categorizations.create!(categorized: @index.children.first)

    get comfy_archive_pages_of_category_path(@index.url(relative: true), @category.label)

    assert_response :success
    assert_template :index
    assert_equal @category.label, assigns(:category)
    assert assigns(:archive_pages)
    assert_equal 1, assigns(:archive_pages).count
    assert assigns(:archive_pages).first.categories.member? @category
  end

  def test_get_index_with_category_invalid
    get comfy_archive_pages_of_category_path(@index.url(relative: true), "invalid")
    assert_response :success
    assert_template :index
    assert_equal "invalid", assigns(:category)
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

  def test_get_index_with_force_render_page
    @index.update_column(:force_render_page, true)
    @index.page.fragments.create!(
      identifier: "content",
      tag:        "text",
      content:    "page content"
    )

    expected = <<~HTML.strip
      <p>
      Published on: 
      </p>
      page content
    HTML

    get @index.url(relative: true)
    assert_response :success
    assert_template nil
    assert_equal expected, response.body
    assert assigns(:cms_index)
    assert assigns(:archive_pages)
    assert_equal 1, assigns(:archive_pages).size
  end

  def test_get_index_with_force_render_page_for_month_archive
    @index.update_column(:force_render_page, true)
    get comfy_archive_pages_of_month_path(@index.url(relative: true), 1981, 10)
    assert_template nil
    assert assigns(:cms_index)
    assert assigns(:year)
    assert assigns(:month)
    assert assigns(:archive_pages)
    assert_equal 1, assigns(:archive_pages).size
  end

  def test_get_index_with_force_render_page_with_category
    @index.update_column(:force_render_page, true)
    @category.categorizations.create!(categorized: @index.children.first)

    get comfy_archive_pages_of_category_path(@index.url(relative: true), @category.label)
    assert_template nil
    assert assigns(:cms_index)
    assert assigns(:category)
    assert assigns(:archive_pages)
    assert_equal 1, assigns(:archive_pages).count
    assert assigns(:archive_pages).first.categories.member? @category
  end

  def test_get_index_with_require_and_not_redirect_category_path_keyword_with_category
    assert ComfyArchive.config.require_category_path_keyword
    assert_not ComfyArchive.config.redirect_category_path_keyword
    @category.categorizations.create!(categorized: @index.children.first)

    assert_match "/category/", comfy_archive_pages_of_category_path(@index.url(relative: true), @category.label)
    get comfy_archive_pages_of_category_path(@index.url(relative: true), @category.label)

    assert_response :success
    assert_template :index
    assert_equal @category.label, assigns(:category)
    assert assigns(:archive_pages)
    assert_equal 1, assigns(:archive_pages).count
    assert assigns(:archive_pages).first.categories.member? @category
  end

  def test_get_index_with_require_and_not_redirect_category_path_keyword_with_invalid_category
    assert ComfyArchive.config.require_category_path_keyword
    assert_not ComfyArchive.config.redirect_category_path_keyword
    assert_match "/category/", comfy_archive_pages_of_category_path(@index.url(relative: true), @category.label)
    get comfy_archive_pages_of_category_path(@index.url(relative: true), "invalid")
    assert_response :success
    assert_template :index
    assert_equal "invalid", assigns(:category)
    assert assigns(:archive_pages)
    assert_equal 0, assigns(:archive_pages).count
  end

  def test_get_index_without_require_and_not_redirect_category_path_keyword_with_category
    ComfyArchive.config.require_category_path_keyword = false
    with_routing do |set|
      set.draw do
        comfy_route :archive_admin
        comfy_route :archive
      end
      assert_not ComfyArchive.config.require_category_path_keyword
      assert_not ComfyArchive.config.redirect_category_path_keyword
      @category.categorizations.create!(categorized: @index.children.first)

      # even though the 'category' keyword in the path is optional, the path helper will still include it
      assert_match "/category/", comfy_archive_pages_of_category_path(@index.url(relative: true), @category.label)
      get comfy_archive_pages_of_category_path(@index.url(relative: true), @category.label)

      assert_response :success
      assert_template :index
      assert_equal @category.label, assigns(:category)
      assert assigns(:archive_pages)
      assert_equal 1, assigns(:archive_pages).count
      assert assigns(:archive_pages).first.categories.member? @category

      # manually re-test without the 'category' keyword in the path
      get "#{@index.url(relative: true)}/#{@category.label}"

      assert_response :success
      assert_template :index
      assert_equal @category.label, assigns(:category)
      assert assigns(:archive_pages)
      assert_equal 1, assigns(:archive_pages).count
      assert assigns(:archive_pages).first.categories.member? @category
    end
  end

  def test_get_index_without_require_and_not_redirect_category_path_keyword_with_invalid_category
    ComfyArchive.config.require_category_path_keyword = false
    with_routing do |set|
      set.draw do
        comfy_route :archive_admin
        comfy_route :archive
      end
      assert_not ComfyArchive.config.require_category_path_keyword
      assert_not ComfyArchive.config.redirect_category_path_keyword

      # even though the 'category' keyword in the path is optional, the path helper will still include it
      assert_match "/category/", comfy_archive_pages_of_category_path(@index.url(relative: true), "invalid")
      get comfy_archive_pages_of_category_path(@index.url(relative: true), "invalid")

      assert_response :success
      assert_template :index
      assert_equal "invalid", assigns(:category)
      assert assigns(:archive_pages)
      assert_equal 0, assigns(:archive_pages).count

      # manually re-test without the 'category' keyword in the path
      get "#{@index.url(relative: true)}/invalid"

      assert_response :success
      assert_template :index
      assert_equal "invalid", assigns(:category)
      assert assigns(:archive_pages)
      assert_equal 0, assigns(:archive_pages).count
    end
  end

  def test_get_index_without_require_and_with_redirect_category_path_keyword_with_category
    ComfyArchive.config.require_category_path_keyword = false
    ComfyArchive.config.redirect_category_path_keyword = true
    with_routing do |set|
      set.draw do
        comfy_route :archive_admin
        comfy_route :archive
      end
      assert_not ComfyArchive.config.require_category_path_keyword
      assert ComfyArchive.config.redirect_category_path_keyword
      @category.categorizations.create!(categorized: @index.children.first)

      # without 'category' keyword, it should load normally
      assert_no_match "/category/", comfy_archive_pages_of_category_path(@index.url(relative: true), @category.label)
      assert_recognizes({ controller: "comfy/archive/index", action: "index", category: @category.label, cms_path: @index.url(relative: true).sub(/^\//, "") }, path: comfy_archive_pages_of_category_path(@index.url(relative: true), @category.label), method: :get)
      get comfy_archive_pages_of_category_path(@index.url(relative: true), @category.label)

      assert_response :success
      assert_template :index
      assert_equal @category.label, assigns(:category)
      assert assigns(:archive_pages)
      assert_equal 1, assigns(:archive_pages).count
      assert assigns(:archive_pages).first.categories.member? @category

      # with 'category' keyword, it should redirect
      get "#{@index.url(relative: true)}/category/#{@category.label}"

      assert_response :redirect
      assert_redirected_to comfy_archive_pages_of_category_url(@index.url(relative: true).sub(/^\//, ""), @category.label)
    end
  end

  def test_get_index_without_require_and_with_redirect_category_path_keyword_with_invalid_category
    ComfyArchive.config.require_category_path_keyword = false
    ComfyArchive.config.redirect_category_path_keyword = true
    with_routing do |set|
      set.draw do
        comfy_route :archive_admin
        comfy_route :archive
      end
      assert_not ComfyArchive.config.require_category_path_keyword
      assert ComfyArchive.config.redirect_category_path_keyword

      # without 'category' keyword, it should load normally
      assert_no_match "/category/", comfy_archive_pages_of_category_path(@index.url(relative: true), "invalid")
      assert_recognizes({ controller: "comfy/archive/index", action: "index", category: "invalid", cms_path: @index.url(relative: true).sub(/^\//, "") }, path: comfy_archive_pages_of_category_path(@index.url(relative: true), "invalid"), method: :get)
      get comfy_archive_pages_of_category_path(@index.url(relative: true), "invalid")

      assert_response :success
      assert_template :index
      assert_equal "invalid", assigns(:category)
      assert assigns(:archive_pages)
      assert_equal 0, assigns(:archive_pages).count

      # with 'category' keyword, it should redirect
      get "#{@index.url(relative: true)}/category/invalid"

      assert_response :redirect
      assert_redirected_to comfy_archive_pages_of_category_url(@index.url(relative: true).sub(/^\//, ""), "invalid")
    end
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
