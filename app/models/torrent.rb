class Torrent < ActiveRecord::Base
  mount_uploader :torrent_file, FileUploader

  # Generate a torrent from the tracker if a file isn't provided.
  def generate_torrent!(target_file_name, piece_size = 256)
    target_file_name = File.basename(target_file_name, ".torrent")
    target_file_name += "_" + Time.now.strftime("%Y%m%d_%H%M%S") + ".torrent"
    target_file_name = File.join('tmp', 'files', target_file_name)
    
    RubyTorrent::Generate.new(target_file_name, self.files.split(/[\r\n]/), self.trackers.split(/[\r\n]/), piece_size, self.comments)
    
    if File.exists?(target_file_name)
      self.torrent_file = File.open(target_file_name)
      self.save
      File.delete(target_file_name)
    end
  end
  
  # def my_att
  #   5
  # end
  # 
  # def to_xml
  #   super(:except => 'id')
  # end

end
