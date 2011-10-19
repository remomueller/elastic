class CleanupDownloader < ActiveRecord::Migration
  def up
    remove_column :downloaders, :trackers
    remove_column :downloaders, :info_hash
    remove_column :downloaders, :torrent_file
    remove_column :downloaders, :torrent_creation_time
    remove_column :downloaders, :executable_file
  end

  def down
    add_column :downloaders, :trackers, :text
    add_column :downloaders, :info_hash, :string
    add_column :downloaders, :torrent_file, :string
    add_column :downloaders, :torrent_creation_time, :integer, :null => false, :default => 0
    add_column :downloaders, :executable_file, :string
  end
end
