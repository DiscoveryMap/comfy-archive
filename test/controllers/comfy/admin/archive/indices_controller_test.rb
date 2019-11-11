# frozen_string_literal: true

require_relative "../../../../test_helper"

class Comfy::Admin::Archive::IndicesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @site   = comfy_cms_sites(:default)
    @page   = comfy_cms_pages(:default)
    @index  = comfy_archive_indices(:default)
  end

  def test_get_index
    r :get, comfy_admin_archive_indices_path(@site)
    assert_response :success
    assert assigns(:indices)
    assert_template :index
  end

  def test_get_index_with_no_indices
    Comfy::Archive::Index.delete_all
    r :get, comfy_admin_archive_indices_path(@site)
    assert_response :redirect
    assert_redirected_to action: :new
  end

  def test_get_new
    r :get, new_comfy_admin_archive_index_path(@site)
    assert_response :success
    assert assigns(:index)
    assert_template :new
    assert_select "form[action='/admin/sites/#{@site.id}/archive-indices']"
  end

  def test_creation
    assert_difference -> { Comfy::Archive::Index.count } do
      r :post, comfy_admin_archive_indices_path(@site), params: { index: {
        label:              "Test Archive Index",
        page_id:            @page.children.first.id,
        datetime_fragment:  "publish_date"
      } }
      assert_response :redirect
      assert_redirected_to action: :edit, id: assigns(:index)
      assert_equal "Archive Index created", flash[:success]
    end
  end

  def test_creation_failure
    assert_no_difference -> { Comfy::Archive::Index.count } do
      r :post, comfy_admin_archive_indices_path(@site), params: { index: {} }
      assert_response :success
      assert_template :new
      assert assigns(:index)
      assert_equal "Failed to create Archive Index", flash[:danger]
    end
  end

  def test_get_edit
    r :get, edit_comfy_admin_archive_index_path(@site, @index)
    assert_response :success
    assert_template :edit
    assert assigns(:index)
    assert_select "form[action='/admin/sites/#{@site.id}/archive-indices/#{@index.id}']"
  end

  def test_get_edit_failure
    r :get, edit_comfy_admin_archive_index_path(@site, "invalid")
    assert_response :redirect
    assert_redirected_to action: :index
    assert_equal "Archive Index not found", flash[:danger]
  end

  def test_update
    r :put, comfy_admin_archive_index_path(@site, @index), params: { index: {
      label: "Updated Archive Index"
    } }
    assert_response :redirect
    assert_redirected_to action: :edit, id: assigns(:index)
    assert_equal "Archive Index updated", flash[:success]

    @index.reload
    assert_equal "Updated Archive Index", @index.label
  end

  def test_update_failure
    r :put, comfy_admin_archive_index_path(@site, @index), params: { index: {
      label: ""
    } }
    assert_response :success
    assert_template :edit
    assert_equal "Failed to update Archive Index", flash[:danger]

    @index.reload
    assert_not_equal "", @index.label
  end

  def test_destroy
    assert_difference -> { Comfy::Archive::Index.count }, -1 do
      r :delete, comfy_admin_archive_index_path(@site, @index)
      assert_response :redirect
      assert_redirected_to action: :index
      assert_equal "Archive Index removed", flash[:success]
    end
  end

end
