# frozen_string_literal: true

require_relative "comfy_archive/version"
require_relative "comfy_archive/engine"
require_relative "comfy_archive/configuration"
require_relative "comfy_archive/routing"

module ComfyArchive

  class << self

    # Modify Archive configuration
    # Example:
    #   ComfyArchive.configure do |config|
    #     config.posts_per_page = 5
    #   end
    def configure
      yield configuration
    end

    # Accessor for ComfyArchive::Configuration
    def configuration
      @configuration ||= ComfyArchive::Configuration.new
    end
    alias config configuration

  end

end
