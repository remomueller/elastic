class Torrent < ActiveRecord::Base
  mount_uploader :torrent_file, FileUploader
  mount_uploader :executable_file, FileUploader

  # Generate a torrent from the tracker if a file isn't provided.
  def generate_torrent!(target_file_name, piece_size = 256)
    target_file_name = File.basename(target_file_name, ".torrent")
    target_file_name += "_" + Time.now.strftime("%Y%m%d_%H%M%S") + ".torrent"
    target_file_name = File.join('tmp', 'files', target_file_name)
    executable_file_name = File.join('tmp', 'files', File.basename(target_file_name, ".torrent") + ".exe")
    
    
    logger.debug self.inspect
    logger.debug target_file_name
    
    logger.debug self.files.split(/[\r\n]/)
    logger.debug self.trackers.split(/[\r\n]/)
    logger.debug piece_size
    logger.debug self.comments
    
    updated_file_locations = []
    self.files.split(/[\r\n]/).each do |file|
      file_location = File.join(Rails.root, 'tmp', 'symbolic', "source_#{4}", File.basename(file))
      if File.exists?(file_location)
        updated_file_locations << file_location
        Rails.logger.debug "#{file_location} ADDED!"
      else
        Rails.logger.debug "#{file_location} does NOT exist"
      end
    end
    
    if updated_file_locations.size > 0
      RubyTorrent::Generate.new(target_file_name, update_file_locations, self.trackers.split(/[\r\n]/), piece_size, self.comments)
    
      if File.exists?(target_file_name)
      
      
        if ENV['OS'] == "Windows_NT"
          begin
            logger.debug Dir.pwd
          
            script_file = 'rtpeercursescomplete.rb'
            script_file_exe = File.basename(script_file, ".rb") + ".exe"
            script_file_path = File.join(File.dirname(File.dirname(`gem which rubytorrent-allspice`)), script_file)
        
            ocra_cmd = "ocra #{script_file_path} #{target_file_name}"
            logger.debug ocra_cmd
            t = Time.now
            logger.debug "Waiting on ocra..."
            status, stdout, stderr = 
              systemu ocra_cmd do |cid|
                logger.debug "   #{Time.now - t}"
                sleep 1
              end
            logger.debug "Status: #{status}\nStdout: #{stdout}\nStderr: #{stderr}"
          
            FileUtils.mv(script_file_exe, executable_file_name)
          rescue => e
            logger.debug "Exception: #{e.inspect}"
          end
        end
      
        self.torrent_file = File.open(target_file_name)
        self.executable_file = File.open(executable_file_name)
        self.save

        begin
          FileUtils.chmod(0777, target_file_name)
          FileUtils.chmod(0777, executable_file_name)
          File.delete(target_file_name)
          File.delete(executable_file_name)
        rescue => e
          logger.debug "Exception: #{e.inspect}"
        end
      end
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
