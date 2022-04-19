# frozen_string_literal: true

module ComfyArchive
  class Configuration

    # Number of posts per page. Default is 10
    attr_accessor :posts_per_page

    # Whether to require the 'category' keyword in archive category paths.
    # Default is true
    attr_accessor :require_category_path_keyword

    # Whether to redirect archive category paths containing the 'category'
    # keyword to paths without. Only functional if keyword is not required.
    # Default is false
    attr_accessor :redirect_category_path_keyword

    # Configuration defaults
    def initialize
      @posts_per_page                 = 10
      @require_category_path_keyword  = true
      @redirect_category_path_keyword = false
    end

  end
end
