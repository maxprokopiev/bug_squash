require "rails_helper"

feature "Sign up" do
  scenario 'Customer successfully signs up' do
    visit "/"

    fill_in "Email", with: "my@email.com"
    fill_in "customer_password", with: "secret99"
    fill_in "customer_password_confirmation", with: "secret99"
    find('#customer_terms_and_conditions').set(true)
    click_on "Sign up"

    expect(page).to have_content("Logged in!")

    customer = Customer.last
    expect(customer.email).to eq "my@email.com"
  end
end
