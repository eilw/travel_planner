class Trip::Invite < ApplicationRecord
  has_secure_token

  belongs_to :trip

  validates :email, uniqueness: {
    scope: :trip_id,
    message: "has already been added to the trip"
  }
  validates :email, presence: true
  validates :email, format: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, on: :create

  after_update :update_responded_at, if: :rvsp_changed?
  after_create :send_invite
  after_create :add_participant
  before_destroy :remove_participant

  def responded?
    responded_at.present?
  end

  private

  def add_participant
    invite_manager.add_participant(invite: self, email: email)
  end

  def remove_participant
    invite_manager.remove_participant(trip: trip, email: email)
  end

  def update_responded_at
    touch :responded_at
  end

  def send_invite
    mailer.send_new_invitation(self, trip).deliver_now
  end

  def invite_manager
    Trip::InviteManager
  end

  def mailer
    TripMailer
  end
end
