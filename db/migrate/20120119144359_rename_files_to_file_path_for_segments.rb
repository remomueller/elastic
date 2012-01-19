class RenameFilesToFilePathForSegments < ActiveRecord::Migration
  
  def change
    rename_column :segments, :files, :file_path
  end
  
end
