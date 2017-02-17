require 'rails_helper'
require_relative './helpers/users'

feature 'Trip' do
  scenario 'A user can create a new trip' do
    login_user
    click_link('Create a new trip')
    fill_in('trip_name', with: 'A trip')
    fill_in('trip_description', with: 'Our trip to Italy')
    click_button('Create trip')
    expect(page).to have_content('A trip')
    expect(page).to have_content('Our trip to Italy')
  end

  scenario 'A user can only see trips created by user' do
    build_stubbed(:trip, name: 'Another trip')
    login_user
    click_link('Create a new trip')
    fill_in('trip_name', with: 'A trip')
    fill_in('trip_description', with: 'Our trip to Italy')
    click_button('Create trip')
    click_link('My trips')

    expect(page).to have_content('A trip: Our trip to Italy')
    expect(page).not_to have_content('Another trip')
  end
end
