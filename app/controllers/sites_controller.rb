class SitesController < ApplicationController
  before_action :authenticate_user!, :except => [ :about ]
end
