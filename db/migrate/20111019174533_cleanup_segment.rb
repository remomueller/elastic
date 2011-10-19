class CleanupSegment < ActiveRecord::Migration
  def up
    remove_column :segments, :trackers
    remove_column :segments, :torrent_file
    remove_column :segments, :comments
    remove_column :segments, :torrent_creation_time
  end

  def down
    add_column :segments, :trackers, :text
    add_column :segments, :torrent_file, :string
    add_column :segments, :comments, :text
    add_column :segments, :torrent_creation_time, :integer
  end
end
