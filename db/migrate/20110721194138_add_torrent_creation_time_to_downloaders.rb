class AddTorrentCreationTimeToDownloaders < ActiveRecord::Migration
  def self.up
    add_column :downloaders, :torrent_creation_time, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :downloaders, :torrent_creation_time
  end
end
