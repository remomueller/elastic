class TorrentsController < ApplicationController
  # GET /torrents
  # GET /torrents.xml
  def index
    @torrents = Torrent.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @torrents }
    end
  end

  # GET /torrents/1
  # GET /torrents/1.xml
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

  # POST /torrents
  # POST /torrents.xml
  def create
    @torrent = Torrent.new(params[:torrent])

    if @torrent.save
      redirect_to(@torrent, :notice => 'Torrent was successfully created.')
    else
      render :action => "new"
    end
  end

  # PUT /torrents/1
  # PUT /torrents/1.xml
  def update
    @torrent = Torrent.find(params[:id])

    respond_to do |format|
      if @torrent.update_attributes(params[:torrent])
        format.html { redirect_to(@torrent, :notice => 'Torrent was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @torrent.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /torrents/1
  # DELETE /torrents/1.xml
  def destroy
    @torrent = Torrent.find(params[:id])
    @torrent.destroy

    respond_to do |format|
      format.html { redirect_to(torrents_url) }
      format.xml  { head :ok }
    end
  end
end
