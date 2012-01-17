class CreateSegments < ActiveRecord::Migration
  def change
    create_table :segments do |t|
      t.integer :user_id
      t.string  :name,                    :null => false, :default => ''
      t.text    :files,                   :null => false
      t.text    :trackers,                :null => false
      t.string  :torrent_file,            :null => false, :default => ''
      t.text    :comments,                :null => false
      t.integer :torrent_creation_time,   :null => false, :default => 0

      t.timestamps
    end
  end
end
