$tracker = Torrent::Tracker.new
$tracker.torrent_directory = PlainTorrentDirectory
$tracker.peer_info_class = PeerInfo # Torrent::MemoryPeerInfo # PeerInfo