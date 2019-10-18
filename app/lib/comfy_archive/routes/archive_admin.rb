# frozen_string_literal: true

class ActionDispatch::Routing::Mapper

  def comfy_route_archive_admin(options = {})
    options[:path] ||= "admin"
    path = [options[:path], "sites", ":site_id"].join("/")

    scope module: :comfy, as: :comfy do
      scope module: :admin do
        namespace :archive, as: :admin, path: path, except: [:show] do
          resources :indices, as: :archive_indices, path: "archive-indices" do
            get :form_fragments, on: :member
          end
        end
      end
    end
  end

end
