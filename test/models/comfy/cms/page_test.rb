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

end
