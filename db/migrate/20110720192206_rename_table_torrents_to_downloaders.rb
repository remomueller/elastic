class RenameTableTorrentsToDownloaders < ActiveRecord::Migration
   def self.up
     rename_table :torrents, :downloaders
   end

  def self.down
     rename_table :downloaders, :torrents
  end
end
