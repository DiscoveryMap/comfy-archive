# frozen_string_literal: true

class ActionDispatch::Routing::Mapper

  def comfy_route_archive(options = {})
    scope module: :comfy, as: :comfy do
      namespace :archive, path: options[:path] do
        get "(*cms_path)" => "index#index", as: "render_page", action: "/:format"
      end
    end
  end

end
