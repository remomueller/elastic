class UsersController < ApplicationController
  before_action :authenticate_user!, except: [ :new, :create ]
  before_action :check_system_admin, except: [ :new, :create, :index, :show, :settings, :update_settings ]
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]
  before_action :redirect_without_user, only: [ :show, :edit, :update, :destroy ]

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
    @order = scrub_order(User, params[:order], 'users.current_sign_in_at DESC')
    @users = User.current.search(params[:search]).order(@order).page(params[:page]).per(current_user.users_per_page)
  end

  def show
  end

  def edit
  end

  def update
    original_status = @user.status
    if @user.update(user_params)
      UserMailer.status_activated(@user).deliver if Rails.env.production? and original_status != @user.status and @user.status == 'active'
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path, notice: 'User was successfully deleted.'
  end

  private

    def set_user
      @user = User.current.find_by_id(params[:id])
    end

    def redirect_without_user
      empty_response_or_root_path(users_path) unless @user
    end

    def user_params
      params[:user] ||= {}

      params.require(:user).permit(
        :first_name, :last_name, :email, :password, :password_confirmation, :system_admin, :status
      )
    end

end
