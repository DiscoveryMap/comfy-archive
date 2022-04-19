# frozen_string_literal: true

require_relative "../../test_helper"

class ConfigurationTest < ActiveSupport::TestCase

  def test_configuration
    assert config = ComfyArchive.configuration
    assert_equal  10, config.posts_per_page
    assert        config.require_category_path_keyword
    assert_not    config.redirect_category_path_keyword
  end

  def test_initialization_overrides
    ComfyArchive.config.posts_per_page = 5
    assert_equal 5, ComfyArchive.config.posts_per_page

    ComfyArchive.config.require_category_path_keyword = false
    assert_not ComfyArchive.config.require_category_path_keyword

    ComfyArchive.config.redirect_category_path_keyword = true
    assert ComfyArchive.config.redirect_category_path_keyword
  end

end
