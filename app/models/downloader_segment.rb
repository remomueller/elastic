class DownloaderSegment < ActiveRecord::Base
  
  # Named Scopes
  scope :current, conditions: { deleted: false }
  
  # Model Relationships
  belongs_to :downloader
  belongs_to :segment
end
