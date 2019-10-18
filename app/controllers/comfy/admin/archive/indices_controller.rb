class Comfy::Admin::Archive::IndicesController < Comfy::Admin::Cms::BaseController

  before_action :build_index, only: %i[new create]
  before_action :load_index,  only: %i[edit update destroy]
  before_action :authorize

  def index
    return redirect_to action: :new if @site.archive_indices.count.zero?

    indices_scope = @site.archive_indices
    @indices = comfy_paginate(indices_scope)
  end

  def new
    render
  end

  def create
    @index.save!
    flash[:success] = t(".created")
    redirect_to action: :edit, id: @index

  rescue ActiveRecord::RecordInvalid
    flash.now[:danger] = t(".create_failure")
    render action: :new
  end

  def edit
    render
  end

  def update
    @index.update_attributes!(index_params)
    flash[:success] = t(".updated")
    redirect_to action: :edit, id: @index

  rescue ActiveRecord::RecordInvalid
    flash.now[:danger] = t(".update_failure")
    render action: :edit
  end

  def destroy
    @index.destroy
    flash[:success] = t(".deleted")
    redirect_to action: :index
  end

protected

  def load_index
    @index = @site.archive_indices.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:danger] = t(".not_found")
    redirect_to action: :index
  end

  def build_index
    @index = @site.archive_indices.new(index_params)
  end

  def index_params
    params.fetch(:index, {}).permit!
  end

end
