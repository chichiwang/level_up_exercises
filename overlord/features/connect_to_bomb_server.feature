Feature: connect to bomb server

  As a user
  I want to connect to the bomb server
  So I can interact with the bomb interface

  Scenario:
    Given user is not at the site
    When user navigates to the site
    Then site connects to the bomb server
    And connection status is "connected"
    And menu is displayed