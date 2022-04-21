# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"

require "simplecov"
require "coveralls"
SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start do
  add_filter "lib/generators"
  add_filter "lib/comfy_archive/engine.rb "
end
require_relative "../config/environment"

require "rails/test_help"
require "rails/generators"

Rails.backtrace_cleaner.remove_silencers!

class ActiveSupport::TestCase

  fixtures :all

  setup :reset_config

  def reset_config
    ComfyArchive.configure do |config|
      config.posts_per_page         = 10
      config.parameterize_category  = false
    end
  end

  # Example usage:
  #   assert_has_errors_on @record, :field_1, :field_2
  def assert_errors_on(record, *fields)
    unmatched = record.errors.keys - fields.flatten
    assert unmatched.blank?, "#{record.class} has errors on '#{unmatched.join(', ')}'"
    unmatched = fields.flatten - record.errors.keys
    assert unmatched.blank?, "#{record.class} doesn't have errors on '#{unmatched.join(', ')}'"
  end

  # Example usage:
  #   assert_exception_raised                                 do ... end
  #   assert_exception_raised ActiveRecord::RecordInvalid     do ... end
  #   assert_exception_raised Plugin::Error, 'error_message'  do ... end
  def assert_exception_raised(exception_class = nil, error_message = nil)
    exception_raised = nil
    yield
  rescue StandardError => exception_raised
    exception_raised
  ensure
    if exception_raised
      if exception_class
        assert_equal exception_class, exception_raised.class, exception_raised.to_s
      else
        assert true
      end
      assert_equal error_message, exception_raised.to_s if error_message
    else
      flunk "Exception was not raised"
    end
  end

end

class ActionDispatch::IntegrationTest

  setup :setup_host

  def setup_host
    host! "test.host"
  end

  # Attaching http_auth stuff with request. Example use:
  #   r :get, '/cms-admin/pages'
  def r(method, path, options = {})
    headers = options[:headers] || {}
    headers["HTTP_AUTHORIZATION"] = ActionController::HttpAuthentication::Basic.encode_credentials(
      ComfortableMexicanSofa::AccessControl::AdminAuthentication.username,
      ComfortableMexicanSofa::AccessControl::AdminAuthentication.password
    )
    options[:headers] = headers
    send(method, path, options)
  end

  # Allow drawing, calling new, and restoring routes to default state.
  #   See: https://stackoverflow.com/a/27083128
  def with_routing(&block)
    yield ComfyArchive::Application.routes
  ensure
    reset_config  # Note: without resetting the config, the reloaded routes will still have the same dynamic routes applied
    ComfyArchive::Application.routes_reloader.reload!
  end
end

class Rails::Generators::TestCase

  destination File.expand_path("../tmp", File.dirname(__FILE__))

  setup :prepare_destination,
        :prepare_files

  def prepare_files
    config_path = File.join(destination_root, "config")
    routes_path = File.join(config_path, "routes.rb")
    FileUtils.mkdir_p(config_path)
    FileUtils.touch(routes_path)
    File.open(routes_path, "w") do |f|
      f.write("Test::Application.routes.draw do\n\nend")
    end
  end

  def read_file(filename)
    File.read(
      File.join(
        File.expand_path("fixtures/generators", File.dirname(__FILE__)),
        filename
      )
    )
  end

end
