class ChangeFilesColumnForDownloaders < ActiveRecord::Migration
  def up
    remove_column :downloaders, :files
    add_column :downloaders, :files_digest, :string, limit: 40, default: "", null: false
  end

  def down
    add_column :downloaders, :files, :text
    remove_column :downloaders, :files_digest
  end
end
