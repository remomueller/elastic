class DownloadersController < ApplicationController
  before_filter :authenticate_user!, :except => ['download_file']
  before_filter :check_system_admin, :except => ['download_file']
  
  def download_file
    # Not working in sqlite for some reason...
    # @downloader = Downloader.find_by_id_and_download_token(params[:id], params[:download_token])
    @downloader = Downloader.find_by_id(params[:id])
    if @downloader and @downloader.download_token == params[:download_token] and @downloader.files.to_s.split(/[\r\n]/).include?(params[:file_path])
      file_path = File.join(Rails.root, 'tmp', 'symbolic', @downloader.folder, params[:file_path])
      logger.debug "Path: " + file_path
      if File.exists?(file_path)
        if params[:checksum] == '1'
          segment = Segment.find_by_files(File.join(file_path))
          if segment
            render :text => segment.checksum
          else
            render :text => 'NOTHING'
          end
        else
          send_file file_path, :disposition =>'attachment'
        end
      else
        error = "The file is no longer available"
        logger.debug error
        render :text => error, :status => 404, :layout => false
      end
    else
      error = "No longer authorized to download this file"
      logger.debug error
      render :text => error, :status => 404
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
      format.json { render json: @downloaders }
    end
  end
  
  # def index
  #   @downloaders = Downloader.all
  # 
  #   respond_to do |format|
  #     format.html # index.html.erb
  #     format.xml  { render :xml => @downloaders }
  #   end
  # end

  def show
    @downloader = Downloader.find(params[:id])

    @downloader.generate_simple_executable! if @downloader.simple_executable_file_url.blank?

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @downloader.to_xml(:methods => [:file_count, :simple_executable_file_url], :except => [:simple_executable_file]) }
    end
  end

  def new
    @downloader = current_user.downloaders.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @downloader }
    end
  end

  def edit
    @downloader = current_user.downloaders.find_by_id(params[:id])
    redirect_to root_path unless @downloader
  end

  def create
    params[:downloader][:files] = Downloader.filter_files(params[:downloader][:files], params[:downloader][:folder])[:base]
    params[:downloader][:name] = params[:downloader][:files].to_s.split(/[\r\n]/).first if params[:downloader][:name].blank?
    params[:target_file_name] = params[:downloader][:name] if params[:target_file_name].blank?
    
    params[:downloader][:download_token] = Digest::SHA1.hexdigest(Time.now.usec.to_s)
    
    @downloader = current_user.downloaders.find_by_files_and_folder(params[:downloader][:files], params[:downloader][:folder])
    
    if @downloader
      @downloader.generate_simple_executable! if @downloader.simple_executable_file_url.blank?
      
      respond_to do |format|
        format.html { redirect_to(@downloader, :notice => 'Equivalent downloader retrieved.') }
        format.xml  { render :xml => @downloader.to_xml(:methods => [:file_count, :simple_executable_file_url], :except => [:simple_executable_file]) }
      end
    else
    
      @downloader = current_user.downloaders.new(params[:downloader])

      respond_to do |format|
        if @downloader.save
          @downloader.generate_simple_executable!
          format.html { redirect_to(@downloader, :notice => 'Downloader was successfully created.') }
          format.xml  { render :xml => @downloader.to_xml(:methods => [:file_count, :simple_executable_file_url], :except => [:simple_executable_file]), :status => :created, :location => @downloader }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @downloader.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  def update
    params[:downloader][:files] = Downloader.filter_files(params[:downloader][:files], params[:downloader][:folder])[:base]
    
    @downloader = Downloader.find_by_id(params[:id])
    
    same_files = (params[:downloader][:files] == @downloader.files and params[:downloader][:folder] == @downloader.folder) if @downloader
    
    respond_to do |format|
      if @downloader.update_attributes(params[:downloader])
        @downloader.generate_simple_executable! unless same_files
        format.html { redirect_to(@downloader, :notice => 'Downloader was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @downloader.errors, :status => :unprocessable_entity }
      end
    end
    
  end

  def destroy
    @downloader = Downloader.find(params[:id])
    @downloader.destroy
    
    respond_to do |format|
      format.html { redirect_to(downloaders_path) }
      format.xml  { head :ok }
    end
  end
end
