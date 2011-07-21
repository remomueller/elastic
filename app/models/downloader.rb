class Downloader < ActiveRecord::Base
  
  belongs_to :user
  
  mount_uploader :torrent_file, FileUploader
  mount_uploader :executable_file, FileUploader

  attr_accessor :torrent_file_url, :file_count
  
  
  def torrent_file_url
    (self.torrent_file and self.torrent_file.url) ? SITE_URL + self.torrent_file.url : ''
  end
  
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

  # Generate a downloader from the tracker if a file isn't provided.
  def generate_torrent!(target_file_name, piece_size = 256)
    updated_file_locations = Downloader.filter_files(self.files)[:path]
    
    logger.debug updated_file_locations.inspect
    
    target_file_name = File.basename(target_file_name, ".torrent")
    target_file_name += "_#{updated_file_locations.size}" + Time.now.strftime("_%Y%m%d_%H%M%S") + ".torrent"
    target_file_path = File.join('tmp', 'files', target_file_name)
    # executable_file_name = File.join('tmp', 'files', File.basename(target_file_name, ".torrent") + ".exe")    
    
    if updated_file_locations.size > 0
      RubyTorrent::Generate.new(target_file_path, updated_file_locations, self.trackers.split(/[\r\n]/), piece_size, self.comments)
    
      if File.exists?(target_file_path)
      
        self.generate_executable!(target_file_path)
      
        target_file = File.new(target_file_path)
      
        self.torrent_file = target_file
        self.save
        
        target_file.close

        # begin
          logger.debug "Deleting #{target_file_path}"
          File.delete(target_file_path) if File.exists?(target_file_path)
        # rescue => e
        #   logger.debug "Exception: #{e.inspect}"
        # end
      end
    end
    
  end
  
  
  # `-- <rails_root>
  #     |-- ...
  #     `-- tmp
  #         |-- cache
  #         |-- files
  #         |   |-- executable_file_path (.exe)   ex:   my_files.exe      <= The compiled script (contains both .rb and .torrent)
  #         |   |-- cp_script_file_path (.rb)     ex:   my_files.rb       <= The ruby script that downloads the torrent
  #         |   `-- target_file_path (.torrent)   ex:   my_files.torrent  <= The actual torrent
  #         |-- pids
  #         |-- sessions
  #         |-- sockets
  #         `-- symbolic
  
  
  def generate_executable!(target_file_path)
    if ENV['OS'] == "Windows_NT"
      begin
        logger.debug FileUtils.pwd
      
        # rtpeercursescomplete.rb should be copied next to the torrent file so OCRA correctly adds in the .torrent file.
      
        script_file = 'rtpeercursescomplete.rb'
        script_file_exe = File.basename(script_file, ".rb") + ".exe"
        script_file_path = File.join(File.dirname(File.dirname(`gem which rubytorrent-allspice`)), script_file)
      
        cp_script_file_path = File.join(File.dirname(target_file_path), File.basename(target_file_path, ".torrent") + ".rb")
        executable_file_path = File.join(File.dirname(cp_script_file_path), File.basename(cp_script_file_path, ".rb") + ".exe")
    
        FileUtils.cp(script_file_path, cp_script_file_path)
    
        FileUtils.cd(File.dirname(target_file_path))
        ocra_cmd = "ocra #{File.basename(cp_script_file_path)} #{File.basename(target_file_path)}"
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
        
        logger.debug "Deleting #{cp_script_file_path}"
        logger.debug "Deleting #{executable_file_path}"
        File.delete(cp_script_file_path) if File.exists?(cp_script_file_path)
        File.delete(executable_file_path) if File.exists?(executable_file_path)
      rescue => e
        logger.debug "Exception: #{e.inspect}"
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
