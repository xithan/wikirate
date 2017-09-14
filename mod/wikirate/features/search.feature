@javascript
Feature: search feature
  As user I can search and use paging to browse through search results

  Scenario: quick search
    Given I go to the homepage
    And I fill in "_keyword" with "Jedi"
    And I press enter to search
    Then I should see "darkness rating"
    When I click on "2"
    Then I should see "deadliness"
