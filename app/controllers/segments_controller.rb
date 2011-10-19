class SegmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_system_admin
  
  def index
    @order = params[:order].blank? ? 'segments.name' : params[:order]
    segment_scope = Segment.current
    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| segment_scope = segment_scope.search(search_term) }
    segment_scope = segment_scope.order(@order)
    @segments = segment_scope.page(params[:page]).per(20)
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @segments }
    end
  end

  # GET /segments/1
  # GET /segments/1.json
  def show
    @segment = Segment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @segment }
    end
  end

  # GET /segments/new
  # GET /segments/new.json
  def new
    @segment = Segment.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @segment }
    end
  end

  # GET /segments/1/edit
  def edit
    @segment = Segment.find(params[:id])
  end

  # POST /segments
  # POST /segments.json
  def create
    @segment = Segment.new(params[:segment])

    respond_to do |format|
      if @segment.save
        format.html { redirect_to @segment, notice: 'Segment was successfully created.' }
        format.json { render json: @segment, status: :created, location: @segment }
      else
        format.html { render action: "new" }
        format.json { render json: @segment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /segments/1
  # PUT /segments/1.json
  def update
    @segment = Segment.find(params[:id])

    respond_to do |format|
      if @segment.update_attributes(params[:segment])
        format.html { redirect_to @segment, notice: 'Segment was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @segment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /segments/1
  # DELETE /segments/1.json
  def destroy
    @segment = Segment.find(params[:id])
    @segment.destroy

    respond_to do |format|
      format.html { redirect_to segments_url }
      format.json { head :ok }
    end
  end
end
