class Segment < ActiveRecord::Base

  # Named Scopes
  scope :current, conditions: { }

  # Model Validation
  validates_presence_of :file_path
  validates_uniqueness_of :file_path

  # Model Relationships
  belongs_to :user
  has_many :downloader_segments
  has_many :downloaders, through: :downloader_segments, conditions: { deleted: false }

  # Model Methods

  def generate_checksum!
    begin
      f = File.new(self.file_path)
      md5_checksum = Digest::MD5.hexdigest(f.read)
      self.update_attribute :checksum, md5_checksum
    rescue StandardError, NoMemoryError => e
      logger.debug "Error #{e.inspect}"
      logger.debug "\nFile Size: #{(f || '').size}"
    ensure
      f.close if f and not f.closed?
      f = nil
    end
    self.checksum
  end
  
end
