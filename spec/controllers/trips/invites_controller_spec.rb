require 'rails_helper'

describe Trips::InvitesController do
  let(:trip) { create(:trip) }
  let(:trip_invite) { Trip::Invite }
  let(:email) { "test@email.com" }
  let(:emails) { "test2@email.com, test3@email.com" }

  login_user

  describe '#create' do
    context 'when successful' do
      context 'when a single email' do
        before { post :create, params: { trip_id: trip.id, trip_invite_builder: { emails: email } } }

        it 'creates a trip invite' do
          expect(trip_invite.where(email: email).count).to eq(1)
        end

        it 'the trip invite is associated to the trip' do
          expect(trip.invites.where(email: email).count).to eq(1)
        end

        it 'redirects to new_trip_invite path' do
          expect(response).to redirect_to(new_trip_invite_path)
        end
      end

      context 'when multiple emails are added' do
        before { post :create, params: { trip_id: trip.id, trip_invite_builder: { emails: emails } } }

        it 'creates a trip invite for each email' do
          expect(trip_invite.count).to eq(2)
        end
      end
    end

    context 'when unsuccessful' do
      before { post :create, params: { trip_id: trip.id, trip_invite_builder: { emails: 'invalid' } } }

      it 'no invite is created' do
        expect(trip_invite.count).to eq(0)
      end

      it 'does not redirect' do
        expect(response).not_to redirect_to(new_trip_invite_path)
      end
    end
  end

  describe '#rvsp' do
    let!(:trip_invite) { create(:trip_invite) }

    context 'responds with rvsp true' do
      before { get :rvsp, params: { id: trip_invite.id, token: trip_invite.token, rvsp: 'true' } }

      it 'updates the rvsp for the trip invite' do
        expect(trip_invite.reload.rvsp).to eq(true)
      end

      it 'updates the responded_at timestamp' do
        expect(trip_invite.reload).to be_responded
      end

      it 'redirects to trip path' do
        expect(response).to redirect_to(trip_path(trip_invite.trip))
      end
    end

    context 'responds with rvsp false' do
      it 'redirects to root' do
        get :rvsp, params: { id: trip_invite.id, token: trip_invite.token, rvsp: 'false' }
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
