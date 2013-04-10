require 'test_helper'

class SegmentTest < ActiveSupport::TestCase
  
  test "should generate checksum" do
    segments(:checksum).generate_checksum!
    assert_equal "d41d8cd98f00b204e9800998ecf8427e", segments(:checksum).checksum
  end
  
  test "should not generate checksum for nonexistent file" do
    segments(:two).generate_checksum!
    assert_equal "", segments(:two).checksum
  end
  
end
