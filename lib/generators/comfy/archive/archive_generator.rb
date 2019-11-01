# frozen_string_literal: true

require "rails/generators/active_record"

module Comfy
  module Generators
    class ArchiveGenerator < Rails::Generators::Base

      include Rails::Generators::Migration
      include Thor::Actions

      source_root File.expand_path("../../../..", __dir__)

      def self.next_migration_number(dirname)
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end

      def generate_migration
        destination   = File.expand_path("db/migrate/01_create_archive.rb", destination_root)
        migration_dir = File.dirname(destination)
        destination   = self.class.migration_exists?(migration_dir, "create_archive")

        if destination
          puts "\e[0m\e[31mFound existing create_archive migration. Remove it if you want to regenerate.\e[0m"
        else
          migration_template "db/migrate/01_create_archive.rb", "db/migrate/create_archive.rb"
        end
      end

      def generate_initialization
        copy_file "config/initializers/comfy_archive.rb",
          "config/initializers/comfy_archive.rb"
      end

      def generate_routing
        route_string = <<-RUBY.strip_heredoc
          comfy_route :archive_admin
          comfy_route :archive
        RUBY
        route route_string
      end

      def generate_views
        directory "app/views/comfy/archive", "app/views/comfy/archive"
      end

      def show_readme
        readme "lib/generators/comfy/archive/README"
      end

    end
  end
end
