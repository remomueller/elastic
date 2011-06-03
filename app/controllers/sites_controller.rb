class SitesController < ApplicationController
  before_filter :authenticate_user!, :except => [ :about ]
  
  def generate_torrent
    
  end
end
