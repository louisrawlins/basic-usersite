require 'digest/sha1'

class User
  include DataMapper::Resource

  def self.default_repository_name
    :default
  end
  
  attr_accessor :password, :password_confirmation, :email_confirmation

  USERTYPES = ['member', 'power_user', 'admin']
  SUBSCRIPTIONS = ['month', 'year']

  property :id,                 Serial,   :writer => :protected, :key => true

  property :email,              String,   :required => true, :length => (5..40),
                                          :unique => true, :format => :email_address
  property :firstname,          String,   :required => true
  property :lastname,           String,   :required => true
  property :title,              String
  property :usertype,           String,   :required => true, :default => 'member',
                                          :format => lambda { |ut| USERTYPES.include?(ut) }
  property :address1,           String
  property :address2,           String
  property :city,               String
  property :state,              String
  property :zip,                String
  property :country,            String
  property :phone,              String
  property :mobile_phone,       String
  property :fax,                String
  property :active,             Boolean,  :default => true
  property :permissions,        Integer # ,  :default => 1
  property :locale,             String
  property :subscription,       String,   :format => lambda { |s| SUBSCRIPTIONS.include?(s) }
  property :subscribed_through, Date
  property :max_match,          Integer
  # property :currency,           String,   :length => 3
  # property :firmId,          Integer
  property :first_login,        Boolean,  :default => true

  property :hashed_password,    String,   :required => true, :writer => :protected
  property :salt,               String,   :required => true, :writer => :protected

  property :created_at,         DateTime
  property :updated_at,         DateTime
  property :last_login_at,      DateTime
  property :prev_login_at,      DateTime

  before :valid? do
    # before validation on create only
    if self.id.nil?
      if self.password.nil?
        #$stderr.puts "CREATE RANDOM PWD FOR #{self.email}..."
        char_range   = [('0'..'9'),('A'..'Z'),('a'..'z')].map {|range| range.to_a}.flatten
        rnd_password = (0...10).map { char_range[Kernel.rand(char_range.size)] }.join
        #$stderr.puts rnd_password
        self.password_confirmation = rnd_password
        self.password              = rnd_password
      
        self.created_at = Time.now
      end
    else
      # do not change password on update from admin!
      # only user can change it
      if @password.nil?
        @password = "donotset"
        @password_confirmation = "donotset"
      end
      # invalid when email_confirmation is absent
      if self.email_confirmation.nil?
        @email_confirmation = self.email
      end
    end
    
    
    true    
  end

  before :save do
    self.updated_at = Time.now
  end
  
  before :destroy do |u|
    u.user_companies.destroy
  end
  
  validates_presence_of     :password_confirmation
  validates_confirmation_of :password

  validates_presence_of     :email_confirmation
  validates_confirmation_of :email
  
  # Authenticate a user based upon a (username or e-mail) and password
  # Return the user record if successful, otherwise nil
  def self.authenticate(email, pass)
    current_user = first(:email => email, :active => true)
    return nil if current_user.nil? || User.encrypt(pass, current_user.salt) != current_user.hashed_password

    current_user.prev_login_at = current_user.last_login_at
    current_user.last_login_at = Time.now
    current_user.save or
      raise ( "Failed to update user: " +
              current_user.errors.full_messages.to_s )

    current_user
  end  

  # Set the user's password, producing a salt if necessary
  def password=(pass)
    @password = pass
    @password_confirmation = pass
    self.salt = (1..12).map{(rand(26)+65).chr}.join if !self.salt
    self.hashed_password = User.encrypt(@password, self.salt)
  end

  def username
    return @name unless @name.nil? or @name.empty?

    @name = [(self.firstname || ""), (self.lastname || "")].join(" ").strip
    @name = self.email if @name.empty?
    @name
  end

  def admin?
    self.usertype == 'admin' rescue false
  end

  def power_user?
    self.usertype == 'power_user' rescue false
  end
  
  def member?
    self.usertype == 'member' rescue false
  end

  def companies
    @companies_set ||= Company.all(isin: self.user_companies.all.collect { |uc| uc.company_id }) || []
  end

  def days_since_prev_login
    seconds = Time.now - ( self.prev_login_at || Time.now )
    return ( seconds / (60 * 60 * 24) ).to_i + 1
  end

  protected
  def self.encrypt(pass, salt)
    Digest::SHA1.hexdigest(pass + salt)
  end
end

