class RenameFilesToFilePathForSegments < ActiveRecord::Migration
  
  def up
    remove_column :segments, :files
    add_column :segments, :file_path, :string
  end
  
  def down
    remove_column :segments, :file_path
    add_column :segments, :files, :text
  end
  
end
