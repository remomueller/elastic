class AddExecutableFileToTorrents < ActiveRecord::Migration
  def self.up
    add_column :torrents, :executable_file, :string
  end

  def self.down
    remove_column :torrents, :executable_file
  end
end
