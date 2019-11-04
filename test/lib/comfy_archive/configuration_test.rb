# frozen_string_literal: true

require_relative "../../test_helper"

class ConfigurationTest < ActiveSupport::TestCase

  def test_configuration
    assert config = ComfyArchive.configuration
    assert_equal  10, config.posts_per_page
  end

  def test_initialization_overrides
    ComfyArchive.config.posts_per_page = 5
    assert_equal 5, ComfyArchive.config.posts_per_page
  end

end
