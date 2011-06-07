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
      format.xml  { render :xml => @torrent }
    end
  end

  def new
    @torrent = current_user.torrents.new
  end

  def edit
    @torrent = current_user.torrents.find_by_id(params[:id])
    redirect_to root_path unless @torrent
  end

  def create
    @torrent = current_user.torrents.new(params[:torrent])
    @torrent.generate_torrent!(params[:target_file_name])

    if @torrent.save
      redirect_to(@torrent, :notice => 'Torrent was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @torrent = Torrent.find(params[:id])

    if @torrent.update_attributes(params[:torrent])
      @torrent.generate_torrent!(params[:target_file_name]) unless params[:target_file_name].blank?
      redirect_to(@torrent, :notice => 'Torrent was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @torrent = Torrent.find(params[:id])
    @torrent.destroy
    redirect_to torrents_path
  end
end
