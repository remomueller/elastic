class Segment < ActiveRecord::Base

  # Model Relationships
  belongs_to :user

  # Model Methods

  def generate_checksum!
    begin
      file_name = self.files.split(/[\r\n]/).first
      f = File.new(file_name)
      begin
        md5_checksum = Digest::MD5.hexdigest(f.read)
      rescue NoMemoryError => e
        logger.debug "\n[NOMEMORY] Failed to Allocate Memory: File Size #{f.size}"
      end
      self.update_attribute :checksum, md5_checksum
    rescue => e
      logger.debug "Error #{e.inspect}"
    ensure
      f.close if f and not f.closed?
      f = nil
    end
  end
  
end
