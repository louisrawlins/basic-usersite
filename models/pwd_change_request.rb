require 'active_support/time'

class PwdChangeRequest
  include DataMapper::Resource

  property :token, String, :key => true
  property :expires, DateTime
  belongs_to :user, :required => true

  def initialize(user)
    super( :token => SecureRandom.hex(16),
           :expires => Time.now.advance( :days => 1 ),
           :user => user )
  end
end
