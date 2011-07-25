class SitesController < ApplicationController
  before_filter :authenticate_user!, :except => [ :about, :announce, :scrape ]
  
  def announce
    
    # puts $tracker.torrent_directory.inspect if $tracker
    # 
    # puts "TRACKER: " + $tracker.inspect
    
    # prepare params
    
    params[:ip] ||= request.env['REMOTE_ADDR']           # use params[:ip] ||= request.ip for sinatra

    logger.info "request.env['REMOTE_ADDR']: #{request.env['REMOTE_ADDR']}"
    logger.info "request.env['HTTP_X_FORWARDED_FOR']: #{request.env['HTTP_X_FORWARDED_FOR']}"

    params[:ip] = request.env['HTTP_X_FORWARDED_FOR'] unless request.env['HTTP_X_FORWARDED_FOR'].blank?

    # puts $tracker.inspect
    # puts $tracker.announce(params).bencode

    params[:peer_id] = params[:peer_id].force_encoding("UTF-8")

    result = $tracker.announce(params).bencode
    # puts $tracker.peer_info_class.find_peers(params)

    # logger.debug "RESULT: #{$tracker.announce(params)}"

    render :text => result
    # render :text => @tracker.announce(params).to_bencoding
  end
  
  def scrape
    
    render :text => $tracker.scrape(params[:info_hash]).bencode
    
  end
  
end
