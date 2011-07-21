class DownloadersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_system_admin
  
  def index
    @downloaders = Downloader.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @downloaders }
    end
  end

  def show
    @downloader = Downloader.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @downloader.to_xml(:methods => [:torrent_file_url, :executable_file_url], :except => [:torrent_file, :executable_file]) }
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
    params[:downloader][:files] = Downloader.filter_files(params[:downloader][:files])[:base]
    params[:downloader][:trackers] = "#{SITE_URL}/announce" if params[:downloader][:trackers].blank?
    params[:downloader][:name] = params[:downloader][:files].to_s.split(/[\r\n]/).first if params[:downloader][:name].blank?
    params[:target_file_name] = params[:downloader][:name] if params[:target_file_name].blank?
    
    logger.debug params.inspect
    
    @downloader = current_user.downloaders.find_by_files(params[:downloader][:files])
    
    if @downloader
      respond_to do |format|
        format.html { redirect_to(@downloader, :notice => 'Equivalent downloader retrieved.') }
        format.xml  { render :xml => @downloader.to_xml(:methods => [:torrent_file_url, :executable_file_url], :except => [:torrent_file, :executable_file]) }
      end
    else
    
      @downloader = current_user.downloaders.new(params[:downloader])
      @downloader.generate_torrent!(params[:target_file_name])

      respond_to do |format|
        if @downloader.save
          format.html { redirect_to(@downloader, :notice => 'Downloader was successfully created.') }
          format.xml  { render :xml => @downloader.to_xml(:methods => [:torrent_file_url, :executable_file_url], :except => [:torrent_file, :executable_file]), :status => :created, :location => @downloader }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @downloader.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  def update
    params[:downloader][:files] = Downloader.filter_files(params[:downloader][:files])[:base]
    params[:downloader][:trackers] = "#{SITE_URL}/announce" if params[:downloader][:trackers].blank?
    
    logger.debug params.inspect
    @downloader = Downloader.find_by_id(params[:id])
    
    same_files = (params[:downloader][:files] == @downloader.files) if @downloader
    
    respond_to do |format|
      if @downloader.update_attributes(params[:downloader])
        @downloader.generate_torrent!(params[:target_file_name]) unless params[:target_file_name].blank? or same_files
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
