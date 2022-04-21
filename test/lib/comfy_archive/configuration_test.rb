# frozen_string_literal: true

require_relative "../../test_helper"

class ConfigurationTest < ActiveSupport::TestCase

  def test_configuration
    assert config = ComfyArchive.configuration
    assert_equal  10, config.posts_per_page
    assert_not    config.parameterize_category
    assert        config.strict_categories
  end

  def test_initialization_overrides
    ComfyArchive.config.posts_per_page = 5
    assert_equal 5, ComfyArchive.config.posts_per_page

    ComfyArchive.config.parameterize_category = true
    assert ComfyArchive.config.parameterize_category

    ComfyArchive.config.strict_categories = false
    assert_not ComfyArchive.config.strict_categories
  end

end
