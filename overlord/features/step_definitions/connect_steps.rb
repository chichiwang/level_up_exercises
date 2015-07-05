Given(/^user is not at the site$/) do
end

When(/^user navigates to the site$/) do
  visit('/')
end

Then(/^site connects to the bomb server$/) do
  page.find('.connection-status.connecting')
  expect(page).to have_content('establishing connection...', wait: 3)
end

Then(/^connection status is "([^"]*)"$/) do |status|
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^menu is displayed$/) do
  pending # Write code here that turns the phrase above into concrete actions
end
