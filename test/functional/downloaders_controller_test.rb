require 'test_helper'

class DownloadersControllerTest < ActionController::TestCase
  setup do
    login(users(:admin))
    @downloader = downloaders(:one)
  end

  test "should download file" do
    get :download_file, id: downloaders(:two).to_param, download_token: 'abc2', file_path: 'test_file.txt'
    assert_not_nil assigns(:downloader)
    assert_equal 'attachment; filename="test_file.txt"', @response.header['Content-Disposition']
    assert_response :success
  end

  test "should not download file and retrieve file checksum for missing segment" do
    get :download_file, id: downloaders(:three).to_param, download_token: 'abcmissing', file_path: 'missing.txt', checksum: '1'
    assert_not_nil assigns(:downloader)
    assert_equal 'abcmissing', assigns(:downloader).download_token
    assert_equal "NOTHING", @response.body
    assert_response :success
  end

  test "should download file and retrieve file checksum" do
    get :download_file, id: downloaders(:two).to_param, download_token: 'abc2', file_path: 'test_file.txt', checksum: '1'
    assert_not_nil assigns(:downloader)
    assert_equal 'abc2', assigns(:downloader).download_token
    assert_equal "a748f32489958e3c31f3ea568dfc0201", @response.body
    assert_response :success
  end

  test "should not download file that does not exist" do
    get :download_file, id: @downloader.to_param, download_token: 'abc', file_path: 'MyText'
    assert_not_nil assigns(:downloader)
    assert_equal 'abc', assigns(:downloader).download_token
    assert_equal 'MyText', assigns(:downloader).files
    assert_equal "The file is no longer available", @response.body
    assert_equal 404, @response.status
  end

  test "should not download file that has an expired token" do
    get :download_file, id: @downloader.to_param, download_token: 'expired_token', file_path: 'MyText'
    assert_not_nil assigns(:downloader)
    assert_equal "No longer authorized to download this file", @response.body
    assert_equal 404, @response.status
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
      post :create, downloader: { files: '', name: 'Downloader 3', folder: 'folder' },
                    target_file_name: 'downloader3'
    end
    assert_not_nil assigns(:downloader)

    assert_redirected_to downloader_path(assigns(:downloader))
  end

  test "should create downloader for xml message" do
    assert_difference('Downloader.count') do
      post :create, downloader: { files: "checksum.txt\nmissing.txt\ntest_file.txt", name: 'Download_3_Files', folder: 'test' }, target_file_name: 'downloader3', format: 'xml'
    end
    assert_not_nil assigns(:downloader)

    assert_equal "checksum.txt\nmissing.txt\ntest_file.txt", @response.body.scan(/<files>(.*?)<\/files>/m).flatten.first
    assert_equal "3", @response.body.scan(/<file-count .*?>(.*?)<\/file-count>/m).flatten.first
    assert_equal users(:admin).to_param, @response.body.scan(/<user-id .*?>(.*?)<\/user-id>/m).flatten.first
    assert_equal assigns(:downloader).download_token, @response.body.scan(/<download-token>(.*?)<\/download-token>/m).flatten.first
    assert_equal assigns(:downloader).folder, @response.body.scan(/<folder>(.*?)<\/folder>/m).flatten.first
    assert_response :success
  end

  test "should create link for existing downloader" do
    assert_difference('Downloader.count', 0) do
      post :create, downloader: { files: 'test_file.txt', name: 'Downloader 3', folder: 'test' },
                    target_file_name: 'downloader3'
    end

    assert_not_nil assigns(:downloader)

    assert_redirected_to downloader_path(assigns(:downloader))
  end
  
  test "should not create downloader with blank name and files" do
    assert_difference('Downloader.count', 0) do
      post :create, downloader: { files: '', name: '', folder: 'folder' },
                    target_file_name: 'downloader3'
    end
    assert_not_nil assigns(:downloader)
    assert_equal ["can't be blank"], assigns(:downloader).errors[:name]
    assert_equal 1, assigns(:downloader).errors.size
    assert_template 'new'
  end

  test "should show downloader" do
    get :show, id: @downloader.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @downloader.to_param
    assert_response :success
  end

  test "should update downloader" do
    put :update, id: @downloader.to_param, downloader: @downloader.attributes
    assert_redirected_to downloader_path(assigns(:downloader))
  end

  test "should not update downloader with blank name" do
    put :update, id: @downloader.to_param, downloader: { name: '', files: 'MyText', folder: 'folder_one' }
    assert_not_nil assigns(:downloader)
    assert_equal ["can't be blank"], assigns(:downloader).errors[:name]
    assert_equal 1, assigns(:downloader).errors.size
    assert_template 'edit'
  end

  test "should destroy downloader" do
    assert_difference('Downloader.count', -1) do
      delete :destroy, id: @downloader.to_param
    end

    assert_redirected_to downloaders_path
  end
end
