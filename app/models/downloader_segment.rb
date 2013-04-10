class DownloaderSegment < ActiveRecord::Base
  # attr_accessible :downloader_id, :segment_id, :checksum_count, :download_count

  # Named Scopes
  scope :current, -> { where deleted: false }

  # Model Relationships
  belongs_to :downloader
  belongs_to :segment
end
