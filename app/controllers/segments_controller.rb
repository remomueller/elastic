class SegmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_system_admin

  def index
    @order = params[:order].blank? ? 'segments.name' : params[:order]
    segment_scope = current_user.all_viewable_segments
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

  def show
    @segment = current_user.all_viewable_segments.find_by_id(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @segment }
    end
  end

  def new
    @segment = current_user.segments.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @segment }
    end
  end

  def edit
    @segment = current_user.all_segments.find_by_id(params[:id])
  end

  def create
    @segment = current_user.segments.new(post_params)

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

  def update
    @segment = current_user.all_segments.find_by_id(params[:id])

    respond_to do |format|
      if @segment.update_attributes(post_params)
        format.html { redirect_to @segment, notice: 'Segment was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @segment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @segment = current_user.all_segments.find_by_id(params[:id])
    @segment.destroy if @segment

    respond_to do |format|
      format.html { redirect_to segments_path }
      format.json { head :ok }
    end
  end

  private

  def post_params
    params[:segment] ||= {}

    params[:segment].slice(
      :name, :checksum, :file_path
    )
  end

end
