class AddChecksumToSegments < ActiveRecord::Migration
  def change
    add_column :segments, :checksum, :string, :limit => 32, :null => false, :default => ''
  end
end
