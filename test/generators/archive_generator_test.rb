# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../../lib/generators/comfy/archive/archive_generator"

class CmsGeneratorTest < Rails::Generators::TestCase

  tests Comfy::Generators::ArchiveGenerator

  def test_generator
    run_generator

    assert_migration "db/migrate/create_archive.rb"

    assert_file "config/initializers/comfy_archive.rb"

    assert_file "config/routes.rb", read_file("archive/routes.rb").strip

    assert_directory "app/views/comfy/archive"
  end

end
