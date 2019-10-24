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
      # render the index page here
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
