# frozen_string_literal: true

module ComfyArchive
  class Configuration

    # Number of posts per page. Default is 10
    attr_accessor :posts_per_page

    # Parameterize category label in paths. Default is false
    attr_accessor :parameterize_category

    # Generate 404 error or throw warning for invalid catgegories. Default is true
    attr_accessor :strict_categories

    # Configuration defaults
    def initialize
      @posts_per_page         = 10
      @parameterize_category  = false
      @strict_categories      = true
    end

  end
end
