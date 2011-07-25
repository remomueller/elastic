module Torrent
  module PeerInfoModule
    module InstanceMethods
      def save
        super
      end
    end
  end
  
  def announce(params)
    _params = params.clone
    _params[:info_hash] = _params[:info_hash].unpack('H*').first
    Rails.logger.debug "UNPACKING PEER ID!"
    Rails.logger.debug _params[:peer_id]
    _params[:peer_id] = _params[:peer_id].unpack('H*').first.encode('UTF-8')
    Rails.logger.debug _params[:peer_id]
    
    Rails.logger.debug "_PARAMS: #{_params.inspect}"

    return failure("Torrent not registered") unless torrent_directory.allowed_torrent?(_params)
    
    peer = peer_info_class.get_or_create(_params)

    case _params[:event]
    when 'stopped'
      peer.stop _params
    when 'completed'
      peer.complete _params
    when 'started'
      peer.start _params
    end
    raise "Error updating peer data" unless peer.save
   
    #peers = peer_info_class.find_peers(_params).map do |x|
    #  x.ip
    #end

    
    result = {}
    if _params[:compact].to_s=="0" then
      result = {'peers' => peer_info_class.find_peers(_params).map do |x| x.to_hash end}
    else
      result = {'peers' => peer_info_class.find_peers(_params).map do |x| x.pack end.join("").to_s}
    end
    
    Rails.logger.debug "RubyTracker Result: #{{'peers' => peer_info_class.find_peers(_params)}}"
    
    result
  end
end