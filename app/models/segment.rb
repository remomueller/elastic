class Segment < ActiveRecord::Base
  belongs_to :user
  
  mount_uploader :torrent_file, FileUploader
  
  def torrent_file_url
    (self.torrent_file and self.torrent_file.url) ? SITE_URL + self.torrent_file.url : ''
  end
  
  
  # Generate a downloader from the tracker if a file isn't provided.
  def generate_torrent!(target_file_name, piece_size = 256)
    
    target_file_name = File.basename(target_file_name, ".torrent")
    target_file_name += ".torrent"
    target_file_path = File.join('tmp', 'files', target_file_name)
    logger.debug "Target File Path: #{target_file_path}"
    # executable_file_name = File.join('tmp', 'files', File.basename(target_file_name, ".torrent") + ".exe")
    
    t = Time.now
    RubyTorrent::Generate.new(target_file_path, self.files.split(/[\r\n]/), self.trackers.split(/[\r\n]/), piece_size, self.comments.blank? ? 'No comments' : self.comments)
    self.update_attribute :torrent_creation_time, (Time.now - t).ceil
    
    if File.exists?(target_file_path)
    
      target_file = File.new(target_file_path)
    
      self.torrent_file = target_file
      self.save
      
      target_file.close
    
      # logger.debug "Deleting #{target_file_path}"
      # File.delete(target_file_path) if File.exists?(target_file_path)
    end
    
  end
  
end
