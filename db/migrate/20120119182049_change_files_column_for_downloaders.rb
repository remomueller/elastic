class ChangeFilesColumnForDownloaders < ActiveRecord::Migration
  def up
    change_column :downloaders, :files, :string, limit: 40, default: "", null: false
  end

  def down
    change_column :downloaders, :files, :text
  end
end
