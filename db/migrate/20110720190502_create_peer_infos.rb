class CreatePeerInfos < ActiveRecord::Migration
  def self.up
    create_table :peer_infos do |t|
      t.string :info_hash
      t.string :peer_id
      t.string :ip
      t.integer :port
      t.string :event
      t.integer :left
      t.integer :downloaded
      t.integer :uploaded

      t.timestamps
    end
  end

  def self.down
    drop_table :peer_infos
  end
end
