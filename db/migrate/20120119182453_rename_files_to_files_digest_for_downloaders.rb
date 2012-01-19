class RenameFilesToFilesDigestForDownloaders < ActiveRecord::Migration
  def change
    rename_column :downloaders, :files, :files_digest
  end
end
