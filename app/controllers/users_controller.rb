class UsersController < ApplicationController
  before_filter :authenticate_user!, except: [:new, :create]
  before_filter :check_system_admin, except: [:new, :create, :index, :show, :settings, :update_settings]

  def settings
  end

  def update_settings
    notifications = {}
    email_settings = ['send_email']
    email_settings.each do |email_setting|
      notifications[email_setting] = (not params[:email].blank? and params[:email][email_setting] == '1')
    end
    current_user.update_attributes email_notifications: notifications
    redirect_to settings_path, notice: 'Email settings saved.'
  end

  def index
    current_user.update_column :users_per_page, params[:users_per_page].to_i if params[:users_per_page].to_i >= 10 and params[:users_per_page].to_i <= 200

    user_scope = User.current
    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| user_scope = user_scope.search(search_term) }

    @order = scrub_order(User, params[:order], 'users.current_sign_in_at DESC')
    user_scope = user_scope.order(@order)

    @count = user_scope.count
    @users = user_scope.page(params[:page]).per(current_user.users_per_page)
  end

  def show
    @user = User.current.find_by_id(params[:id])
    redirect_to users_path unless @user
  end

  # # GET /users/new
  # # GET /users/new.xml
  # def new
  #   @user = User.new
  #
  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.xml  { render :xml => @user }
  #   end
  # end

  def edit
    @user = User.current.find_by_id(params[:id])
    redirect_to users_path unless @user
  end

  # # POST /users
  # # POST /users.xml
  # def create
  #   @user = User.new(params[:user])
  #
  #   respond_to do |format|
  #     if @user.save
  #       format.html { redirect_to(@user, notice: 'User was successfully created.') }
  #       format.xml  { render :xml => @user, :status => :created, :location => @user }
  #     else
  #       format.html { render :action => "new" }
  #       format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end

  def update
    @user = User.find_by_id(params[:id])
    if @user and @user.update_attributes(post_params)
      original_status = @user.status
      @user.update_column :system_admin, params[:user][:system_admin]
      @user.update_column :status, params[:user][:status]
      UserMailer.status_activated(@user).deliver if Rails.env.production? and original_status != @user.status and @user.status = 'active'
      redirect_to(@user, notice: 'User was successfully updated.')
    elsif @user
      render action: "edit"
    else
      redirect_to users_path
    end
  end

  def destroy
    @user = User.find_by_id(params[:id])
    @user.destroy if @user
    redirect_to users_path, notice: 'User was successfully deleted.'
  end

  private

  def post_params
    params[:user] ||= {}

    params[:user].slice(
      :first_name, :last_name, :email
    )
  end

end
