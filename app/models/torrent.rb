class Torrent < ActiveRecord::Base


  def self.generate_torrent(params)
    RubyTorrent::Generate.new('<name>.torrent',["/path/to/file"],["http://127.0.0.1:6969/announce"])
    
    

  end



end
