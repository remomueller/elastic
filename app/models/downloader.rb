class Downloader < ActiveRecord::Base
  
  belongs_to :user
  
  # mount_uploader :torrent_file, FileUploader
  mount_uploader :executable_file, FileUploader
  
  # def torrent_file_url
  #   (self.torrent_file and self.torrent_file.url) ? SITE_URL + self.torrent_file.url : ''
  # end
  
  def executable_file_url
    (self.executable_file and self.executable_file.url) ? SITE_URL + self.executable_file.url : ''
  end
  
  def file_count
    self.files.to_s.split(/[\r\n]/).select{|i| not i.blank?}.size
  end

  def self.filter_files(params_files = '')
    available_files = []
    updated_file_locations = []
    params_files.split(/[\r\n]/).each do |file|
      file_location = File.join(Rails.root, 'tmp', 'symbolic', "source_#{4}", File.basename(file))
      if File.exists?(file_location) and not file.blank?
        updated_file_locations << file_location
        available_files << File.basename(file)
        # Rails.logger.debug "#{file_location} ADDED!"
      else
        # Rails.logger.debug "#{file_location} does NOT exist"
      end
    end
    
    return {:base => available_files.compact.uniq.sort.join("\n"), :path => updated_file_locations.compact.uniq.sort}
  end

  def generate_torrents!(target_file_name, piece_size = 256)
    updated_file_locations = Downloader.filter_files(self.files)[:path]
    updated_file_locations.each do |file_location|
      segment = Segment.find_or_create_by_files(file_location)
      segment.update_attributes :trackers => self.trackers, :comments => self.comments      
      segment.generate_torrent!(file_location, piece_size) if segment.torrent_file.blank?
    end
    
    self.generate_executable!
  end

  # # Generate a downloader from the tracker if a file isn't provided.
  # def generate_torrent!(target_file_name, piece_size = 256)
  #   updated_file_locations = Downloader.filter_files(self.files)[:path]
  #   
  #   logger.debug updated_file_locations.inspect
  #   
  #   target_file_name = File.basename(target_file_name, ".torrent")
  #   target_file_name += "_#{updated_file_locations.size}" + Time.now.strftime("_%Y%m%d_%H%M%S") + ".torrent"
  #   target_file_path = File.join('tmp', 'files', target_file_name)
  #   # executable_file_name = File.join('tmp', 'files', File.basename(target_file_name, ".torrent") + ".exe")
  #   
  #   if updated_file_locations.size > 0
  #     t = Time.now
  #     RubyTorrent::Generate.new(target_file_path, updated_file_locations, self.trackers.split(/[\r\n]/), piece_size, self.comments)
  #     self.update_attribute :torrent_creation_time, (Time.now - t).ceil
  #     
  #     if File.exists?(target_file_path)
  #     
  #       self.generate_executable!(target_file_path)
  #     
  #       target_file = File.new(target_file_path)
  #     
  #       self.torrent_file = target_file
  #       self.save
  #       
  #       target_file.close
  # 
  #       # begin
  #         logger.debug "Deleting #{target_file_path}"
  #         File.delete(target_file_path) if File.exists?(target_file_path)
  #       # rescue => e
  #       #   logger.debug "Exception: #{e.inspect}"
  #       # end
  #     end
  #   end
  #   
  # end
  
  
  # `-- <rails_root>
  #     |-- ...
  #     `-- tmp
  #         |-- cache
  #         |-- files
  #         |   |-- executable_file_path (.exe)   ex:   my_files.exe      <= The compiled script (contains both .rb and .torrent)
  #         |   |-- script_file_path (.rb)        ex:   my_files.rb       <= The ruby script that downloads the torrent
  #         |   `-- target_file_path (.torrent)   ex:   my_files.torrent  <= The actual torrent
  #         |-- pids
  #         |-- sessions
  #         |-- sockets
  #         `-- symbolic
  
  
  def generate_executable!
    if ENV['OS'] == "Windows_NT"
      # begin
        logger.debug FileUtils.pwd
      
        
        script_file_path = File.join('tmp', 'files', 'file_downloader.rb')
        executable_file_path = File.join(File.dirname(script_file_path), File.basename(script_file_path, ".rb") + ".exe")
    
        
    
        FileUtils.cd('tmp', 'files')
        
        segment_files = []
        self.files.split(/[\r\n]/).each do |file|
          segment_files << File.basename(file) + ".torrent"
        end
        
        
        ocra_cmd = "ocra #{File.basename(script_file_path)} #{segment_files.join(' ')}"
        logger.debug ocra_cmd
        
        t = Time.now
        logger.debug "Waiting on ocra..."
        status, stdout, stderr = 
          systemu ocra_cmd do |cid|
            logger.debug "   #{Time.now - t}"
            sleep 1
          end
        logger.debug "Status: #{status}\nStdout: #{stdout}\nStderr: #{stderr}"
        
        FileUtils.cd(Rails.root)
        
        exe_file = File.new(executable_file_path)
        self.executable_file = exe_file
        self.save
        exe_file.close
        
        logger.debug "Deleting #{executable_file_path}"
        File.delete(executable_file_path) if File.exists?(executable_file_path)
      # rescue => e
      #   logger.debug "Exception: #{e.inspect}"
      # end
    end
  end
end
