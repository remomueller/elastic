class AddFolderToDownloaders < ActiveRecord::Migration
  def change
    add_column :downloaders, :folder, :string
  end
end
