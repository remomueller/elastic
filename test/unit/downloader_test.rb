require 'test_helper'

class DownloaderTest < ActiveSupport::TestCase
  
  test "should get correct file count" do
    assert_equal 1, downloaders(:one).file_count
    assert_equal 0, downloaders(:no_files).file_count
    assert_equal 2, downloaders(:two_files).file_count
  end
  
  test "should generate simple executable" do
    test_executable = File.join(Rails.root, 'tmp', 'files', "simple_download_#{downloaders(:with_executable).to_param}.exe")
    File.open(test_executable, 'w') {|f| f.write('test_executable') }
    downloaders(:with_executable).generate_simple_executable!
  end
  
end
