class CreateDownloaderSegments < ActiveRecord::Migration
  def change
    create_table :downloader_segments do |t|
      t.integer :downloader_id
      t.integer :segment_id
      t.integer :checksum_count, null: false, default: 0
      t.integer :download_count, null: false, default: 0

      t.timestamps
    end
  end
end
