class TorrentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_system_admin
  
  def index
    @torrents = Torrent.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @torrents }
    end
  end

  def show
    @torrent = Torrent.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @torrent.to_xml(:methods => [:torrent_file_url, :executable_file_url]) }
    end
  end

  def new
    @torrent = current_user.torrents.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @torrent }
    end
  end

  def edit
    @torrent = current_user.torrents.find_by_id(params[:id])
    redirect_to root_path unless @torrent
  end

  def create
    logger.debug params.inspect
    @torrent = current_user.torrents.new(params[:torrent])
    @torrent.generate_torrent!(params[:target_file_name])

    respond_to do |format|
      if @torrent.save
        format.html { redirect_to(@torrent, :notice => 'Torrent was successfully created.') }
        format.xml  { render :xml => @torrent.to_xml(:methods => [:torrent_file_url, :executable_file_url]), :status => :created, :location => @torrent }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @torrent.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @torrent = Torrent.find(params[:id])
    
    respond_to do |format|
      if @torrent.update_attributes(params[:torrent])
        @torrent.generate_torrent!(params[:target_file_name]) unless params[:target_file_name].blank?
        format.html { redirect_to(@torrent, :notice => 'Torrent was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @torrent.errors, :status => :unprocessable_entity }
      end
    end
    
  end

  def destroy
    @torrent = Torrent.find(params[:id])
    @torrent.destroy
    
    respond_to do |format|
      format.html { redirect_to(torrents_path) }
      format.xml  { head :ok }
    end
  end
end
