class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, and :lockable
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable
         
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name

  after_create :notify_system_admins
  before_update :status_activated

  STATUS = ["active", "denied", "inactive", "pending"].collect{|i| [i,i]}
  serialize :email_notifications, Hash

  # Named Scopes
  scope :current, :conditions => { :deleted => false }
  scope :status, lambda { |*args|  { :conditions => ["users.status IN (?)", args.first] } }
  scope :system_admins, :conditions => { :system_admin => true }
  scope :search, lambda { |*args| {:conditions => [ 'LOWER(first_name) LIKE ? or LOWER(last_name) LIKE ? or LOWER(email) LIKE ?', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%' ] } }
  
  # Model Validation
  validates_presence_of     :first_name
  validates_presence_of     :last_name

  # Model Relationships
  has_many :authentications
  has_many :torrents, :conditions => {:deleted => false}

  # User Methods
  
  # Overriding Devise built-in active? method
  def active?
    super and self.status == 'active' and not self.deleted?
  end

  def destroy
    update_attribute :deleted, true
    update_attribute :status, 'inactive'
  end

  def email_on?(value)
    if self.email_notifications
      [nil, true].include?(self.email_notifications[value.to_s])
    else
      true
    end
  end

  def name
    "#{first_name} #{last_name}"
  end
  
  def rev_name
    "#{last_name}, #{first_name}"
  end
  
  def nickname
    "#{first_name} #{last_name.first}"
  end
  
  def apply_omniauth(omniauth)
    unless omniauth['user_info'].blank?
      self.email = omniauth['user_info']['email'] if email.blank?
      self.first_name = omniauth['user_info']['first_name'] if first_name.blank?
      self.last_name = omniauth['user_info']['last_name'] if last_name.blank?
    end
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
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
  
  def status_activated
    unless self.new_record? or self.changes.blank?
      if self.changes['status'] and self.changes['status'][1] == 'active'
        UserMailer.status_activated(self).deliver if Rails.env.production?
      end
    end
  end
end
