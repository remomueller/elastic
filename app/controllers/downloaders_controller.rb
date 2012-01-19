class DownloadersController < ApplicationController
  before_filter :authenticate_user!, :except => ['download_file']
  before_filter :check_system_admin, :except => ['download_file']
  
  def download_file
    @downloader = Downloader.find_by_id_and_download_token(params[:id], params[:download_token])
    
    file_path = File.join(Rails.root, 'tmp', 'symbolic', @downloader.folder, params[:file_path]) if @downloader
    @segment = @downloader.segments.find_by_file_path(file_path) if @downloader
    @downloader_segment = @segment.downloader_segments.find_by_downloader_id(@downloader.id) if @segment
    
    if @downloader and @segment and @downloader_segment
      if File.exists?(@segment.file_path)
        if params[:checksum] == '1'
          @downloader_segment.update_attribute :checksum_count, @downloader_segment.checksum_count + 1
          render text: (@segment.checksum.blank? ? @segment.generate_checksum! : @segment.checksum)
        else
          @downloader_segment.update_attribute :download_count, @downloader_segment.download_count + 1
          send_file @segment.file_path, disposition: 'attachment'
        end
      else
        error = "The file is no longer available"
        logger.debug error
        render text: error, status: 404, layout: false
      end
    else
      error = "No longer authorized to download this file"
      logger.debug error
      render text: error, status: 404
    end
  end

  def index
    # current_user.update_attribute :downloaders_per_page, params[:downloaders_per_page].to_i if params[:downloaders_per_page].to_i >= 10 and params[:downloaders_per_page].to_i <= 200
    @order = params[:order].blank? ? 'downloaders.name' : params[:order]
    downloader_scope = Downloader.current
    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| downloader_scope = downloader_scope.search(search_term) }
    downloader_scope = downloader_scope.order(@order)
    @downloaders = downloader_scope.page(params[:page]).per(20) #(current_user.downloaders_per_page)
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @downloaders, methods: [:file_count, :simple_executable_file_url], except: [:simple_executable_file] }
    end
  end

  def show
    @downloader = Downloader.find(params[:id])

    @downloader.generate_simple_executable! if @downloader.simple_executable_file_url.blank?

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @downloader.to_xml(:methods => [:file_count, :simple_executable_file_url], :except => [:simple_executable_file]) }
      format.json { render json: @downloader, methods: [:file_count, :simple_executable_file_url], except: [:simple_executable_file] }
    end
  end

  def new
    @downloader = current_user.downloaders.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @downloader }
      format.json { render json: @downloader }
    end
  end

  def edit
    @downloader = current_user.downloaders.find_by_id(params[:id])
    redirect_to root_path unless @downloader
  end

  def create
    # params[:downloader].delete(:trackers) # Was for backward compatibility with 0.3.0, removed in 0.5.0
    # TODO: perhaps select only certain keys from :downloader params
    
    new_files = Downloader.filter_files(params[:downloader][:files], params[:downloader][:folder])[:base]
    
    params[:downloader][:files_digest] = Digest::SHA1.hexdigest(new_files)
    params[:downloader].delete(:files)
    
    params[:downloader][:name] = new_files.split(/[\r\n]/).first if params[:downloader][:name].blank?
    params[:target_file_name] = params[:downloader][:name] if params[:target_file_name].blank?
    
    params[:downloader][:download_token] = Digest::SHA1.hexdigest(Time.now.usec.to_s)
    
    @downloader = current_user.downloaders.find_by_files_digest_and_folder_and_external_user_id(params[:downloader][:files_digest], params[:downloader][:folder], params[:downloader][:external_user_id])
    
    if @downloader
      @downloader.generate_simple_executable! if @downloader.simple_executable_file_url.blank?
      
      respond_to do |format|
        format.html { redirect_to(@downloader, :notice => 'Equivalent downloader retrieved.') }
        format.xml  { render :xml => @downloader.to_xml(:methods => [:file_count, :simple_executable_file_url], :except => [:simple_executable_file]) }
        format.json { render json: @downloader, methods: [:file_count, :simple_executable_file_url], except: [:simple_executable_file], status: :created, location: @downloader }
      end
    else
    
      @downloader = current_user.downloaders.new(params[:downloader])

      respond_to do |format|
        if @downloader.save
          @downloader.generate_segments!(new_files, params[:downloader][:folder])
          @downloader.generate_simple_executable!
          format.html { redirect_to(@downloader, :notice => 'Downloader was successfully created.') }
          format.xml  { render xml: @downloader.to_xml(:methods => [:file_count, :simple_executable_file_url], :except => [:simple_executable_file]), :status => :created, :location => @downloader }
          format.json { render json: @downloader, methods: [:file_count, :simple_executable_file_url], except: [:simple_executable_file], status: :created, location: @downloader }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @downloader.errors, :status => :unprocessable_entity }
          format.json { render json: @downloader.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def update
    new_files = Downloader.filter_files(params[:downloader][:files], params[:downloader][:folder])[:base]
    params[:downloader][:files_digest] = Digest::SHA1.hexdigest(new_files)
    params[:downloader].delete(:files)
    
    @downloader = Downloader.find_by_id(params[:id])
    
    same_files = (params[:downloader][:files_digest] == @downloader.files_digest and params[:downloader][:folder] == @downloader.folder) if @downloader
    
    respond_to do |format|
      if @downloader.update_attributes(params[:downloader])
        @downloader.generate_simple_executable! unless same_files
        format.html { redirect_to(@downloader, :notice => 'Downloader was successfully updated.') }
        format.xml  { head :ok }
        format.json  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @downloader.errors, :status => :unprocessable_entity }
        format.json { render json: @downloader.errors, status: :unprocessable_entity }
      end
    end
    
  end

  def destroy
    @downloader = Downloader.find(params[:id])
    @downloader.destroy
    
    respond_to do |format|
      format.html { redirect_to(downloaders_path) }
      format.xml  { head :ok }
      format.json  { head :ok }
    end
  end
end
