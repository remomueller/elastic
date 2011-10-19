require 'test_helper'

class DownloadersControllerTest < ActionController::TestCase
  setup do
    login(users(:admin))
    @downloader = downloaders(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:downloaders)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create downloader" do
    assert_difference('Downloader.count') do
      post :create, :downloader => { :files => '', :trackers => '', :name => 'Downloader 3', :folder => 'folder' },
                    :target_file_name => 'downloader3'
    end

    assert_redirected_to downloader_path(assigns(:downloader))
  end

  test "should show downloader" do
    get :show, :id => @downloader.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @downloader.to_param
    assert_response :success
  end

  test "should update downloader" do
    put :update, :id => @downloader.to_param, :downloader => @downloader.attributes
    assert_redirected_to downloader_path(assigns(:downloader))
  end

  test "should destroy downloader" do
    assert_difference('Downloader.count', -1) do
      delete :destroy, :id => @downloader.to_param
    end

    assert_redirected_to downloaders_path
  end
end
