class CreateTorrents < ActiveRecord::Migration
  def self.up
    create_table :torrents do |t|
      t.integer :user_id
      t.string :name
      t.text :files
      t.text :trackers
      t.string :info_hash
      t.string :torrent_file
      t.text :comments
      t.boolean :deleted, :null => false, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :torrents
  end
end
