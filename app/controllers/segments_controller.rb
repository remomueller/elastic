class SegmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_system_admin
  before_action :set_segment, only: [ :show, :edit, :update, :destroy ]
  before_action :redirect_without_segment, only: [ :show, :edit, :update, :destroy ]

  # GET /segments
  # GET /segments.json
  def index
    @order = scrub_order(Segment, params[:order], 'segments.name')
    @segments = current_user.all_segments.search(params[:search]).order(@order).page(params[:page]).per(20)
  end

  # GET /segments/1
  # GET /segments/1.json
  def show
  end

  # GET /segments/new
  def new
    @segment = current_user.segments.new
  end

  # GET /segments/1/edit
  def edit
  end

  # POST /segments
  # POST /segments.json
  def create
    @segment = current_user.segments.new(segment_params)

    respond_to do |format|
      if @segment.save
        format.html { redirect_to @segment, notice: 'Segment was successfully created.' }
        format.json { render action: 'show', status: :created, location: @segment }
      else
        format.html { render action: 'new' }
        format.json { render json: @segment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /segments/1
  # PUT /segments/1.json
  def update
    respond_to do |format|
      if @segment.update(segment_params)
        format.html { redirect_to @segment, notice: 'Segment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @segment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /segments/1
  # DELETE /segments/1.json
  def destroy
    @segment.destroy

    respond_to do |format|
      format.html { redirect_to segments_path }
      format.json { head :no_content }
    end
  end

  private

    def set_segment
      @segment = current_user.all_segments.find_by_id(params[:id])
    end

    def redirect_without_segment
      empty_response_or_root_path unless @segment
    end

    def segment_params
      params.require(:segment).permit(
        :name, :checksum, :file_path
      )
    end

end
