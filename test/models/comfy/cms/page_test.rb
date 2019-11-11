# frozen_string_literal: true

require_relative "../../../test_helper"

class CmsPagesTests < ActiveSupport::TestCase

  setup do
    @page   = comfy_cms_pages(:default)
  end

  # -- Tests -------------------------------------------------------------------

  def test_scope_chronologically
    chronologically = Comfy::Cms::Page.chronologically("publish_date")
    assert_includes chronologically, @page.children.first
    assert_includes chronologically, @page.children.last
    assert_not_includes chronologically, @page
    assert_equal chronologically.first, @page.children.last
    assert_equal chronologically.last, @page.children.first
  end

  def test_scope_for_year
    assert_equal 2, Comfy::Cms::Page.for_year("publish_date", 1981).count
    assert_equal 0, Comfy::Cms::Page.for_year("publish_date", 1982).count
  end

  def test_scope_for_month
    assert_equal 2, Comfy::Cms::Page.for_month("publish_date", 10).count
    assert_equal 0, Comfy::Cms::Page.for_month("publish_date", 11).count
  end

  def test_published_at
    assert_equal @page.children.first.published_at("publish_date"), "1981-10-04 12:34:56"
  end

end
