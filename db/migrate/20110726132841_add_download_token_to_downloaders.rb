class AddDownloadTokenToDownloaders < ActiveRecord::Migration
  def change
    add_column :downloaders, :download_token, :string
  end
end
