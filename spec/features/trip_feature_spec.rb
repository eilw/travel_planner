require 'rails_helper'
require_relative './helpers/users'

feature 'Trip' do
  scenario 'A user can create a new trip' do
    login_user
    create_trip(name: 'A trip', description: 'Our trip to Italy')
    expect(page).to have_content('A trip')
    expect(page).to have_content('Our trip to Italy')
  end

  scenario 'A user can only see trips created by user' do
    build_stubbed(:trip, name: 'Another trip')
    login_user
    create_trip(name: 'A trip', description: 'Our trip to Italy')
    click_link('My trips')

    expect(page).to have_content('A trip: Our trip to Italy')
    expect(page).not_to have_content('Another trip')
  end

  scenario 'A user can invite other people to a trip using their emails' do
    login_user
    create_trip(name: 'A trip', description: 'Our trip to Italy')
    click_link('Trip invites')
    fill_in('trip_invite_builder_emails', with: 'invite@email.com, invite2@email.com')
    fill_in('trip_invite_builder_message', with: 'Trip invite message')
    click_button('Send invitations')

    expect(page).to have_content('Invitations')
    expect(page).to have_content('invite@email.com')
    expect(page).to have_content('invite2@email.com')
    expect(page).not_to have_content('Trip invite description')

    click_link('Back to trip')
    expect(page).to have_content('Trip invites: 2 invitations')
  end

  scenario 'A user gets errors if emails are invalid and duplicate emails are not processed' do
    login_user
    create_trip(name: 'A trip', description: 'Our trip to Italy')
    click_link('Trip invites')
    fill_in('trip_invite_builder_emails', with: 'inviteemail.com, invite2@email.com, invite2@email.com')
    fill_in('trip_invite_builder_message', with: 'Trip invite message')
    click_button('Send invitations')

    expect(page).to have_content('Email is invalid')
    expect(find_field('Emails').value).to eq 'inviteemail.com'

    click_link('Back to trip')
    expect(page).to have_content('Trip invites: 1 invitations')
  end

  scenario 'The status of the invited users to the trip is shown' do
    login_user
    create_trip(name: 'A trip', description: 'Our trip to Italy')
    click_link('Trip invites')
    fill_in('trip_invite_builder_emails', with: 'invite@email.com, invite2@email.com, invite3@email.com')
    fill_in('trip_invite_builder_message', with: 'Trip invite message')
    click_button('Send invitations')

    Trip::Invite.find_by(email: 'invite@email.com').update!(rvsp: true)
    Trip::Invite.find_by(email: 'invite2@email.com').update!(rvsp: false)
    visit current_path

    expect(page).to have_content('Accepted')
    expect(page).to have_content('Declined')
    expect(page).to have_content('Pending')
  end
end

def create_trip(name:, description:)
  click_link('Create a new trip')
  fill_in('trip_name', with: name)
  fill_in('trip_description', with: description)
  click_button('Create trip')
end
