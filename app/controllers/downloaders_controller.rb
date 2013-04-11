class DownloadersController < ApplicationController
  before_action :authenticate_user!, except: [ :download_file ]
  before_action :check_system_admin, except: [ :download_file, :index ]
  before_action :set_downloader, only: [ :show, :edit, :update, :destroy ]
  before_action :redirect_without_downloader, only: [ :show, :edit, :update, :destroy ]

  def download_file
    @downloader = Downloader.find_by_id_and_download_token(params[:id], params[:download_token])

    file_path = File.join(Rails.root, 'tmp', 'symbolic', @downloader.folder, params[:file_path]) if @downloader
    @segment = @downloader.segments.find_by_file_path(file_path) if @downloader
    @downloader_segment = @segment.downloader_segments.find_by_downloader_id(@downloader.id) if @segment

    if @downloader and @segment and @downloader_segment
      if File.exists?(@segment.file_path)
        if params[:checksum] == '1'
          @downloader_segment.update_attributes checksum_count: @downloader_segment.checksum_count + 1
          render text: (@segment.checksum.blank? ? @segment.generate_checksum! : @segment.checksum)
        else
          @downloader_segment.update_attributes download_count: @downloader_segment.download_count + 1
          send_file @segment.file_path, disposition: 'attachment'
        end
      else
        error = "The file is no longer available"
        Rails.logger.debug error
        render text: error, status: 404, layout: false
      end
    else
      error = "No longer authorized to download this file"
      Rails.logger.debug error
      render text: error, status: 404
    end
  end

  # GET /downloaders
  # GET /downloaders.json
  def index
    @order = scrub_order(Downloader, params[:order], 'downloaders.name')
    @downloaders = current_user.all_downloaders.search(params[:search]).order(@order).page(params[:page]).per(20)
  end

  # GET /downloaders/1
  # GET /downloaders/1.json
  def show
    @downloader.generate_simple_executable! if @downloader.simple_executable_file_url.blank?
  end

  # GET /downloaders/new
  def new
    @downloader = current_user.downloaders.new
  end

  # GET /downloaders/1/edit
  def edit
  end

  # POST /downloaders
  # POST /downloaders.json
  def create
    new_files = Downloader.filter_files(params[:downloader][:files], params[:downloader][:folder])[:base]
    params[:downloader][:files_digest] = Digest::SHA1.hexdigest(new_files)

    params[:downloader][:name] = new_files.split(/[\r\n]/).first if params[:downloader][:name].blank?
    params[:target_file_name] = params[:downloader][:name] if params[:target_file_name].blank?

    params[:downloader] = downloader_params


    params[:downloader][:download_token] = Digest::SHA1.hexdigest(Time.now.usec.to_s)

    @downloader = current_user.downloaders.find_by_files_digest_and_folder_and_external_user_id(params[:downloader][:files_digest], params[:downloader][:folder], params[:downloader][:external_user_id])

    if @downloader
      @downloader.generate_simple_executable! if @downloader.simple_executable_file_url.blank?

      respond_to do |format|
        format.html { redirect_to @downloader, notice: 'Equivalent downloader retrieved.' }
        format.json { render action: 'show', status: :created, location: @downloader }
      end
    else

      @downloader = current_user.downloaders.new(downloader_params)

      respond_to do |format|
        if @downloader.save
          @downloader.generate_segments!(new_files, params[:downloader][:folder])
          @downloader.generate_simple_executable!
          format.html { redirect_to @downloader, notice: 'Downloader was successfully created.' }
          format.json { render action: 'show', status: :created, location: @downloader }
        else
          format.html { render action: 'new' }
          format.json { render json: @downloader.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PUT /downloaders/1
  # PUT /downloaders/1.json
  def update
    new_files = Downloader.filter_files(params[:downloader][:files], params[:downloader][:folder])[:base]
    params[:downloader][:files_digest] = Digest::SHA1.hexdigest(new_files)
    params[:downloader] = downloader_params

    same_files = (params[:downloader][:files_digest] == @downloader.files_digest and params[:downloader][:folder] == @downloader.folder)

    respond_to do |format|
      if @downloader.update(params[:downloader])
        @downloader.generate_simple_executable! unless same_files
        format.html { redirect_to @downloader, notice: 'Downloader was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @downloader.errors, status: :unprocessable_entity }
      end
    end

  end

  # DELETE /downloaders/1
  # DELETE /downloaders/1.json
  def destroy
    @downloader.destroy

    respond_to do |format|
      format.html { redirect_to downloaders_path, notice: 'Downloader was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private

    def set_downloader
      @downloader = Downloader.current.find_by_id(params[:id])
    end

    def redirect_without_downloader
      empty_response_or_root_path unless @downloader
    end

    def downloader_params
      params.require(:downloader).permit(
        :name, :comments, :download_token, :simple_executable_file, :folder, :external_user_id, :files_digest, :target_file_name
      )
    end

end
