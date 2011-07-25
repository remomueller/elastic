# coding: UTF-8

require "net/http"
require "net/https"
require "rubytorrent-allspice"

exit if defined?(Ocra)

Thread.abort_on_exception = true # make debugging easier

def die(x); $stderr << "#{x}\n" && exit(-1); end

class Numeric
  def k; (self.to_f / 1024.0); end
  def f(format="0.0")
    sprintf("%#{format.to_s}f", self)
  end
end

proxy = ENV["http_proxy"]
port = ENV["port"] # Added 1.9.2

tmp_folder = File.dirname($0)
puts tmp_folder
puts Dir.entries(tmp_folder).inspect
torrents = Dir.glob(File.join(tmp_folder, "*.torrent"))

dest = ARGV.shift

torrents.each_with_index do |torrent, index|
  puts "Downloading #{File.basename(torrent)} | #{index + 1} of #{torrents.size}"


  if torrent == nil
    puts "File Receipt not found in executable."
    exit
  end


  puts "reading torrent..."
  begin
    mi = RubyTorrent::MetaInfo.from_location(torrent, proxy)
  rescue RubyTorrent::MetaInfoFormatError, RubyTorrent::BEncodingError => e
    puts "Exception: #{e.inspect}"
    die %{Error: can't parse metainfo file "#{torrent}"---maybe not a .torrent?}
  rescue RubyTorrent::TypedStructError => e
    $stderr << <<EOS
error parsing metainfo file, and it's likely something I should know about.
please email the torrent file to wmorgan-rubytorrent-bug@masanjin.net,
along with this backtrace: (this is RubyTorrent version #{RubyTorrent::VERSION})
EOS

    raise e
  rescue IOError, SystemCallError => e
    die %{Error: can't read file "#{torrent}": #{e.message}}
  end

  unless dest.nil?
    if FileTest.directory?(dest) && mi.info.single?
      dest = File.join(dest, mi.info.name)
    elsif FileTest.file?(dest) && mi.info.multiple?
      die %{Error: .torrent contains multiple files, but "#{dest}" is a single file (must be a directory)}
    end
  end
  print "checking file status: " ; $stdout.flush
  package = RubyTorrent::Package.new(mi, dest) do |piece|
    print(piece.complete? && piece.valid? ? "#" : ".")
    $stdout.flush
  end
  puts " done"

  puts "starting peer..."
  bt = RubyTorrent::BitTorrent.new(mi, package, :http_proxy => proxy, :port => port) #, :dlratelim => 20*1024, :ulratelim => 10*1024) # Added Ruby 1.9.2

  unless $DEBUG # these are duplicated by debugging information
    bt.on_event(self, :trying_peer) { |s, p| puts "trying peer #{p}" }
    bt.on_event(self, :forgetting_peer) { |s, p| puts "couldn't connect to peer #{p}" }
    bt.on_event(self, :removed_peer) { |s, p| puts "disconnected from peer #{p}" }
  end
  bt.on_event(self, :added_peer) { |s, p| puts "connected to peer #{p}" }
  bt.on_event(self, :received_block) { |s, b, peer| puts "<- got block #{b} from peer #{peer}, now #{package.pieces[b.pindex].percent_done.f}% done and #{package.pieces[b.pindex].percent_claimed.f}% claimed" }
  bt.on_event(self, :sent_block) { |s, b, peer| puts "-> sent block #{b} to peer #{peer}" }
  bt.on_event(self, :requested_block) { |s, b, peer| puts "-- requested block #{b} from #{peer}" }
  bt.on_event(self, :have_piece) { |s, p| puts "***** got complete and valid piece #{p}" }
  bt.on_event(self, :discarded_piece) { |s, p| puts "XXXXX checksum error on piece #{p}, discarded" }
  bt.on_event(self, :tracker_connected) { |s, url| puts "[tracker] connected to tracker #{url}" }
  bt.on_event(self, :tracker_lost) { |s, url| puts "[tracker] couldn't connect to tracker #{url}" }
  bt.on_event(self, :complete) do
    puts <<EOS
*********************
* download complete *
*********************
EOS
  end

  puts "listening on #{bt.ip} port #{bt.port}"

  thread = nil
  ## not sure if this works on windows, but it's just a nicety anyways.
  Signal.trap("INT") do
    Signal.trap("INT", "DEFAULT") # second ^C will really kill us
    thread.kill unless thread.nil?
    bt.shutdown_all
  end unless $DEBUG

  thread = Thread.new do
    not_completed = true
    while not_completed
      puts "-" * 78
      ps = bt.peer_info.sort_by { |h| h[:start_time] }.reverse.uniq
      puts <<EOS
Downloading: #{File.basename(torrent)} | #{index + 1} of #{torrents.size}
downloaded:  #{bt.dlamt.k.f}k @ #{bt.dlrate.k.f}kb/s, uploaded #{bt.ulamt.k.f}k @ #{bt.ulrate.k.f}kb/s
completed:   #{bt.pieces_completed} / #{bt.num_pieces} pieces = #{bt.bytes_completed.k.f}kb / #{bt.total_bytes.k.f}kb = #{bt.percent_completed.f}%
tracker:     #{bt.tracker || "not connected"}
connected to #{ps.length} / #{bt.num_possible_peers} possible peers:
EOS
      ps.each do |p|
        puts <<EOS
dl #{p[:dlamt].k.f(4.0)}kb @#{p[:dlrate].k.f(3.0)}kb/s, ul #{p[:ulamt].k.f(4.0)}kb @#{p[:ulrate].k.f(3.0)}kb/s, i: #{(p[:interested] ? 'y' : 'n')}/#{(p[:peer_interested] ? 'y' : 'n')} (#{p[:we_desire].f(4.0)}/#{p[:they_desire].f(4.0)}) c: #{(p[:choking] ? 'y' : 'n')}/#{(p[:peer_choking] ? 'y' : 'n')} p: #{p[:pending_send]}/#{p[:pending_recv]}#{(p[:snubbing] ? ', snub' : '')} #{p[:name]}
EOS
      end
      puts "-" * 78
      not_completed = (bt.pieces_completed != bt.num_pieces)
      sleep 10
    end
  end

  thread.join
  puts "Completed   #{File.basename(torrent)} |"
end

puts "Completed All #{torrents.size} File(s)!"