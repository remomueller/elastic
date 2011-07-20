class PlainTorrentDirectory
  include Torrent::Directory

  def self.allowed_torrent?(params)
    true
  end
end