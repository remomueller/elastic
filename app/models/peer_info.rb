class PeerInfo < ActiveRecord::Base
  include Torrent::PeerInfoModule
  attr_accessible :info_hash, :peer_id, :ip, :port, :event, :left, :downloaded, :uploaded
  act_as_peer_info

  # def get_or_create(params)
  #   logger.info "Get or Create...successful??"
  #   self.find_or_create(params)
  # end

  def self.create_peer(params)
    logger.info "CREATE PEER #{params.inspect}"
    self.new(params)
  end
  
  def self.get_peer(params)
    logger.info "GET PEER #{params.inspect}"
    # self.first(:peer_id => params[:peer_id], :info_hash => params[:info_hash])
    params['peer_id'] = params['peer_id'].force_encoding('UTF-8')
    params['info_hash'] = params['info_hash'].force_encoding('UTF-8')
    self.find_by_peer_id_and_info_hash(params['peer_id'], params['info_hash'])
  end
  
  def self.find_peers(params)
    # logger.info "FIND PEERS #{params.inspect}"
    # logger.debug "FindPeers: InfoHASH '#{params[:info_hash]}'"
    # logger.debug "FindPeers: InfoHASH '#{params['info_hash']}'"
    logger.debug "FindPeers Result = #{self.where(:info_hash => params[:info_hash])}.inspect"
    # self.where(:info_hash => params[:info_hash])
    self.all.select{|p| p.info_hash == params[:info_hash]}
  end
end
