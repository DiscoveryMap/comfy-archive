# frozen_string_literal: true

class ActionDispatch::Routing::Mapper

  def comfy_route_archive(options = {})
    scope module: :comfy, as: :comfy do
      namespace :archive, path: options[:path] do
        with_options constraints: { year: %r{\d{4}}, month: %r{\d{1,2}} } do |o|
          o.get "*cms_path/:year",          to: "index#index", as: :pages_of_year
          o.get "*cms_path/:year/:month",   to: "index#index", as: :pages_of_month
        end
        get "*cms_path/category/:category", to: "index#index", as: :pages_of_category
        get "(*cms_path)",                  to: "index#index", as: :render_page, action: "/:format"
      end
    end
  end

end
