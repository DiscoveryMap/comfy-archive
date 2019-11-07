require 'cgi'

class Comfy::Archive::IndexController < Comfy::Cms::ContentController

  include Comfy::Paginate

  before_action :load_index,
                :authenticate,
                :authorize,
                only: :index

  def index
    unless @cms_index && @cms_index.page == @cms_page
      show
    else
      scope = @cms_index.children(true).chronologically(@cms_index.datetime_fragment)
      if params[:year]
        @year = params[:year]
        scope = scope.for_year(@cms_index.datetime_fragment, @year)
        if params[:month]
          @month = params[:month]
          scope = scope.for_month(@cms_index.datetime_fragment, @month)
        end
      elsif params[:category]
        @category = CGI.unescape(params[:category])
        scope = scope.for_category(@category).distinct(false)
      end

      @archive_pages = comfy_paginate(scope, per_page: ComfyArchive.config.posts_per_page)
      render layout: app_layout
    end
  end

  protected

  def load_index
    load_cms_page
    if @cms_page
      unless @cms_index = Comfy::Archive::Index.find_by(page: @cms_page)
        @cms_index = Comfy::Archive::Index.find_by(page: @cms_page.parent)
      end
    end
  end

end
