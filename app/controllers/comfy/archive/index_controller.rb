require 'cgi'

class Comfy::Archive::IndexController < Comfy::Cms::ContentController

  include Comfy::Paginate

  before_action :load_index,
                :authenticate,
                :authorize,
                only: :index

  def index
    if ! @cms_index || @cms_index.page != @cms_page
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
        load_category
        scope = scope.for_category(@category.label).distinct(false)
      end

      @archive_pages = comfy_paginate(scope, per_page: ComfyArchive.config.posts_per_page)
      if @cms_index.force_render_page
        show
      else
        render layout: app_layout
      end
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

  def load_category
    @category = ComfyArchive.config.parameterize_category ? find_cms_category_by_parameterized_label(params[:category]) : Comfy::Cms::Category.find_by(label: CGI.unescape(params[:category]))
    unless @category
      if ComfyArchive.config.strict_categories
        if find_cms_page_by_full_path("/404")
          render_page(:not_found)
        else
          message = "Page Not Found at: \"#{params[:cms_path]}/category/#{params[:category]}\""
          raise ActionController::RoutingError, message
        end
      else
        @category = Comfy::Cms::Category.new(label: ComfyArchive.config.parameterize_category ? params[:category].gsub('-', ' ').titleize : CGI.unescape(params[:category]))
      end
    end
  end

  def find_cms_category_by_parameterized_label(parameterized)
    @cms_index.categories.find { |c| c.label.parameterize == parameterized }
  end

end
