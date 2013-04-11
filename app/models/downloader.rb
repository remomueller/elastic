class Downloader < ActiveRecord::Base
  # attr_accessible :name, :comments, :download_token, :simple_executable_file, :folder, :external_user_id, :files_digest, :target_file_name

  # Concerns
  include Searchable

  # Named Scopes
  scope :current, -> { where deleted: false }

  # Model Validation
  validates_presence_of :name

  # Model Relationships
  belongs_to :user
  has_many :downloader_segments
  has_many :segments, through: :downloader_segments

  attr_reader :files

  mount_uploader :simple_executable_file, FileUploader

  def destroy
    update_column :deleted, true
  end

  def simple_executable_file_url
    (self.simple_executable_file and self.simple_executable_file.url) ? SITE_URL + self.simple_executable_file.url : ''
  end

  def file_count
    # self.files.to_s.split(/[\r\n]/).select{|i| not i.blank?}.size
    self.downloader_segments.size
  end

  def self.filter_files(params_files = '', params_folder = '')
    available_files = []
    updated_file_locations = []
    params_files.to_s.split(/[\r\n]/).each do |file|
      file_location = File.join(Rails.root, 'tmp', 'symbolic', params_folder, File.basename(file))
      if File.exists?(file_location) and not file.blank?
        updated_file_locations << file_location
        available_files << File.basename(file)
        # Rails.logger.debug "#{file_location} ADDED!"
      else
        # Rails.logger.debug "#{file_location} does NOT exist"
      end
    end

    return { base: available_files.compact.uniq.sort.join("\n"), path: updated_file_locations.compact.uniq.sort }
  end

  # def generate_checksums!
  #   updated_file_locations = Downloader.filter_files(self.files, self.folder)[:path]
  #   updated_file_locations.each do |file_location|
  #     logger.debug "Searching for CHECKSUM!: #{file_location}"
  #     # TODO find by file path
  #     segment = Segment.find_or_create_by_file_path(file_location)
  #   end
  # end

  # `-- <rails_root>
  #     |-- ...
  #     `-- tmp
  #         |-- cache
  #         |-- files
  #         |   |-- executable_file_path (.exe)   ex:   my_files.exe      <= The compiled script (contains both .rb)
  #         |   `-- script_file_path (.rb)        ex:   my_files.rb       <= The ruby script that downloads the target files
  #         |-- pids
  #         |-- sessions
  #         |-- sockets
  #         `-- symbolic


  def generate_simple_executable!
    # self.generate_checksums!

    if ENV['OS'] == "Windows_NT" or true
      # begin
        script_file_path = File.join('tmp', 'files', "simple_download_#{self.id}.rb")
        file_template = File.join('lib', 'templates', 'simple_download.rb.erb')

        file_in = File.new(file_template, "r")
        file_out = File.new(script_file_path, "w")
        template = ERB.new(file_in.sysread(File.size(file_in)))
        file_out.syswrite(template.result(binding))
        file_in.close()
        file_out.close()

        executable_file_path = File.join(File.dirname(script_file_path), File.basename(script_file_path, ".rb") + ".exe")

        FileUtils.cd(File.join('tmp', 'files'))

        ocra_cmd = "ocra #{File.basename(script_file_path)}"
        logger.debug ocra_cmd

        t = Time.now
        logger.debug "Waiting on ocra..."

        status, stdout, stderr = systemu ocra_cmd

        logger.debug "Status: #{status}\nStdout: #{stdout}\nStderr: #{stderr}"

        FileUtils.cd(Rails.root)

        if File.exists?(executable_file_path)
          exe_file = File.new(executable_file_path)
          self.simple_executable_file = exe_file
          self.save
          exe_file.close
        end

        logger.debug "Deleting #{executable_file_path}"
        File.delete(executable_file_path) if File.exists?(executable_file_path)
        logger.debug "Deleting #{script_file_path}"
        File.delete(script_file_path) if File.exists?(script_file_path)
      # rescue => e
      #   logger.debug "Exception: #{e.inspect}"
      # end
    end
  end

  def generate_segments!(new_files, new_folder)
    updated_file_locations = Downloader.filter_files(new_files, new_folder)[:path]
    updated_file_locations.each do |file_location|
      segment = Segment.where(file_path: file_location).first_or_create
      self.segments << segment unless self.segments.pluck('segments.id').include?(segment.id)
    end
  end
end
