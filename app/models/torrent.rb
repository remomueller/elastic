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
    
    RubyTorrent::Generate.new(target_file_name, self.files.split(/[\r\n]/), self.trackers.split(/[\r\n]/), piece_size, self.comments)
    
    if File.exists?(target_file_name)
      
      
      if ENV['OS'] == "Windows_NT"
        begin
          logger.debug Dir.pwd
          
          script_file = 'rtpeercursescomplete.rb'
          script_file_exe = File.basename(script_file, ".rb") + ".exe"
          script_file_path = File.join(File.dirname(File.dirname(`gem which rubytorrent-allspice`)), script_file)
        
          ocra_cmd = "ocra #{script_file_path} #{target_file_name}"
          logger.debug ocra_cmd
          status = Open4::popen4(ocra_cmd) do |pid, stdin, stdout, stderr|
            logger.debug "PID #{pid}" 
          end
          
          logger.debug status
          
          cp_cmd = "cp #{script_file_exe} #{executable_file_name}"
          logger.debug cp_cmd
          status = Open4::popen4(cp_cmd) do |pid, stdin, stdout, stderr|
            logger.debug "PID #{pid}" 
          end
          
          logger.debug status

          logger.debug `cp #{script_file_exe} #{executable_file_name}`
        rescue => e
          logger.debug "Exception: #{e.inspect}"
        end
      else
        begin
          logger.debug Dir.pwd
          script_file = File.join(File.dirname(File.dirname(`gem which rubytorrent-allspice`)), 'rtpeercursescomplete.rb')
        
          logger.debug "script_file #{script_file}"
          
          logger.debug "cp #{target_file_name} #{executable_file_name}"
        
          logger.debug `cp #{target_file_name} #{executable_file_name}`
        rescue => e
          logger.debug "Exception: #{e.inspect}"
        end
      end
      
      self.torrent_file = File.open(target_file_name)
      self.executable_file = File.open(executable_file_name)
      self.save
      File.delete(target_file_name)
      File.delete(executable_file_name)
      
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
