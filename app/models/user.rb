class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, and :lockable
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name,
                  :email_notifications

  # Callbacks
  after_create :notify_system_admins

  STATUS = ["active", "denied", "inactive", "pending"].collect{|i| [i,i]}
  serialize :email_notifications, Hash

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :status, lambda { |*args|  { conditions: ["users.status IN (?)", args.first] } }
  scope :system_admins, conditions: { system_admin: true }
  scope :search, lambda { |*args| { conditions: [ 'LOWER(first_name) LIKE ? or LOWER(last_name) LIKE ? or LOWER(email) LIKE ?', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%' ] } }

  # Model Validation
  validates_presence_of     :first_name
  validates_presence_of     :last_name

  # Model Relationships
  has_many :authentications
  has_many :downloaders, conditions: { deleted: false }
  has_many :segments, conditions: { } # Segments don't have a deleted flag

  # User Methods

  def all_downloaders
    if self.system_admin?
      Downloader.current
    else
      self.downloaders
    end
  end

  def all_segments
    if self.system_admin?
      Segment.current
    else
      self.segments
    end
  end

  def all_viewable_segments
    self.all_segments
  end

  # Overriding Devise built-in active_for_authentication? method
  def active_for_authentication?
    super and self.status == 'active' and not self.deleted?
  end

  def destroy
    update_column :deleted, true
    update_column :status, 'inactive'
    update_column :updated_at, Time.now
  end

  def email_on?(value)
    [nil, true].include?(self.email_notifications[value.to_s])
  end

  def name
    "#{first_name} #{last_name}"
  end

  def reverse_name
    "#{last_name}, #{first_name}"
  end

  def nickname
    "#{first_name} #{last_name.first}"
  end

  def apply_omniauth(omniauth)
    unless omniauth['info'].blank?
      self.email = omniauth['info']['email'] if email.blank?
      self.first_name = omniauth['info']['first_name'] if first_name.blank?
      self.last_name = omniauth['info']['last_name'] if last_name.blank?
    end
    authentications.build( provider: omniauth['provider'], uid: omniauth['uid'] )
  end

  def password_required?
    (authentications.empty? || !password.blank?) && super
  end

  private

  def notify_system_admins
    User.current.system_admins.each do |system_admin|
      UserMailer.notify_system_admin(system_admin, self).deliver if Rails.env.production?
    end
  end
end
