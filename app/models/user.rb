require 'concerns/RegistrationValidation'

class User < ActiveRecord::Base
  include RegistrationValidation
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # TODO: currently this will display both facebook and openid links to login;
  # if we want to take out facebook, we want to do it here.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook, :openid_connect]

  has_many :tickets
  has_many :memberships
  has_many :camps, through: :memberships
  has_many :created_camps, class_name: :Camp

  schema_validations whitelist: [:id, :created_at, :updated_at, :encrypted_password]

  # TODO: Ensure that this method works okay for Keycloak registrations as well;
  # I believe the email should come through just fine, but will require a little
  # testing to be sure.
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
    end
  end

end
