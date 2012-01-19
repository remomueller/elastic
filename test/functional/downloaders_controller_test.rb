require 'test_helper'

class DownloadersControllerTest < ActionController::TestCase
  setup do
    login(users(:admin))
    @downloader = downloaders(:one)
  end

  test "should download file" do
    get :download_file, id: downloaders(:two).to_param, download_token: 'abc2', file_path: 'test_file.txt'
    assert_not_nil assigns(:downloader)
    assert_not_nil assigns(:segment)
    assert_not_nil assigns(:downloader_segment)
    assert_equal 1, assigns(:downloader_segment).download_count
    assert_equal 'attachment; filename="test_file.txt"', @response.header['Content-Disposition']
    assert_response :success
  end

  test "should not download file and retrieve file checksum for missing segment" do
    get :download_file, id: downloaders(:three).to_param, download_token: 'abcmissing', file_path: 'missing.txt', checksum: '1'
    assert_not_nil assigns(:downloader)
    assert_nil assigns(:segment)
    assert_nil assigns(:downloader_segment)
    assert_equal 'abcmissing', assigns(:downloader).download_token
    assert_equal "No longer authorized to download this file", @response.body
    assert_response 404
  end

  test "should download file and retrieve file checksum" do
    get :download_file, id: downloaders(:two).to_param, download_token: 'abc2', file_path: 'test_file.txt', checksum: '1'
    assert_not_nil assigns(:downloader)
    assert_not_nil assigns(:segment)
    assert_not_nil assigns(:downloader_segment)
    assert_equal 1, assigns(:downloader_segment).checksum_count
    assert_equal 'abc2', assigns(:downloader).download_token
    assert_equal "a748f32489958e3c31f3ea568dfc0201", @response.body
    assert_response :success
  end

  test "should download file and retrieve file freshly generated checksum" do
    get :download_file, id: downloaders(:with_executable).to_param, download_token: 'fake', file_path: 'checksum.txt', checksum: '1'
    assert_not_nil assigns(:downloader)
    assert_not_nil assigns(:segment)
    assert_not_nil assigns(:downloader_segment)
    assert_equal 1, assigns(:downloader_segment).checksum_count
    assert_equal 'fake', assigns(:downloader).download_token
    assert_equal "d41d8cd98f00b204e9800998ecf8427e", @response.body
    assert_response :success
  end

  test "should not download file that does not exist" do
    get :download_file, id: @downloader.to_param, download_token: 'abc', file_path: 'file_deleted.txt'
    assert_not_nil assigns(:downloader)
    assert_not_nil assigns(:segment)
    assert_not_nil assigns(:downloader_segment)
    assert_equal 'abc', assigns(:downloader).download_token
    assert_equal Digest::SHA1.hexdigest(''), assigns(:downloader).files_digest
    assert_equal "The file is no longer available", @response.body
    assert_equal 404, @response.status
  end

  test "should not download file that has an expired token" do
    get :download_file, id: @downloader.to_param, download_token: 'expired_token', file_path: 'file_deleted.txt'
    assert_nil assigns(:downloader)
    assert_equal "No longer authorized to download this file", @response.body
    assert_equal 404, @response.status
  end

  test "should get index for valid user" do
    login(users(:valid))
    get :index
    assert_not_nil assigns(:downloaders)
    assert assigns(:downloaders).where(["user_id != ?", users(:valid).id]).size == 0
    assert_response :success
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
    
    assert_equal 0, assigns(:downloader).downloader_segments.size
    assert_equal 0, assigns(:downloader).segments.size

    assert_redirected_to downloader_path(assigns(:downloader))
  end

  test "should create downloader for xml message" do
    assert_difference('Downloader.count') do
      post :create, downloader: { files: "checksum.txt\nmissing.txt\ntest_file.txt", name: 'Download_3_Files', folder: 'test' }, target_file_name: 'downloader3', format: 'xml'
    end
    assert_not_nil assigns(:downloader)
    
    assert_equal 3, assigns(:downloader).downloader_segments.size
    assert_equal 3, assigns(:downloader).segments.size

    assert_equal assigns(:downloader).files_digest, @response.body.scan(/<files-digest>(.*?)<\/files-digest>/m).flatten.first
    assert_equal "3", @response.body.scan(/<file-count .*?>(.*?)<\/file-count>/m).flatten.first
    assert_equal users(:admin).to_param, @response.body.scan(/<user-id .*?>(.*?)<\/user-id>/m).flatten.first
    assert_equal assigns(:downloader).download_token, @response.body.scan(/<download-token>(.*?)<\/download-token>/m).flatten.first
    assert_equal assigns(:downloader).folder, @response.body.scan(/<folder>(.*?)<\/folder>/m).flatten.first
    assert_response :success
  end

  test "should create downloader for json message" do
    assert_difference('Downloader.count') do
      post :create, downloader: { files: "checksum.txt\nmissing.txt\ntest_file.txt", name: 'Download_3_Files', folder: 'test' }, target_file_name: 'downloader3', format: 'json'
    end
    assert_not_nil assigns(:downloader)
    
    assert_equal 3, assigns(:downloader).downloader_segments.size
    assert_equal 3, assigns(:downloader).segments.size

    assert_equal assigns(:downloader).files_digest, ActiveSupport::JSON.decode(@response.body)['files_digest']
    assert_equal 3, ActiveSupport::JSON.decode(@response.body)['file_count']
    assert_equal users(:admin).to_param.to_i, ActiveSupport::JSON.decode(@response.body)['user_id']
    assert_equal assigns(:downloader).download_token, ActiveSupport::JSON.decode(@response.body)['download_token']
    assert_equal assigns(:downloader).folder, ActiveSupport::JSON.decode(@response.body)['folder']
    assert_response :success
  end

  test "should create link for existing downloader" do
    assert_difference('Downloader.count', 0) do
      post :create, downloader: { files: 'test_file.txt', name: 'Downloader 3', folder: 'test' },
                    target_file_name: 'downloader3'
    end

    assert_not_nil assigns(:downloader)
    assert_equal 1, assigns(:downloader).downloader_segments.size
    assert_equal 1, assigns(:downloader).segments.size

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
    put :update, id: @downloader.to_param, downloader: { name: 'Updated Name', files: 'file_deleted.txt', folder: 'folder_one' }
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
