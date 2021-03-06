class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :username, presence: true
  has_many :trip_participants, dependent: :delete_all
  has_many :trips, through: :trip_participants
  has_many :comments, dependent: :delete_all
  after_create :add_trips

  private

  def add_trips
    Trip::InviteManager.add_trips_to(self)
  end
end
