# frozen_string_literal: true

ComfyArchive::Application.routes.draw do
  comfy_route :cms_admin
  comfy_route :archive_admin
  comfy_route :archive
  comfy_route :cms
end
