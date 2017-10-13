@javascript @delayed-jobs
Feature: import metric answers from a csv file
  A user can create metric answers from a CSV file

  Background:
    Given I am signed in as Joe Admin
    And I go to card "feature answer import test"
    And I follow "Import ..."
#    And I maximize the browser
    And I uncheck all checkboxes
    And I scroll -1000 pixels

  Scenario: Show import table correctly
    And I should see a row with "1|Jedi+disturbances in the Force|Death Star|Death Star|Death Star|2017|yes|http://google.com/1|chch"
    And I should see a row with "11|Jedi+disturbances in the Force|Death Star|2000|no|http://google.com/10"

  Scenario: Import a simple metric value
    When I check checkbox for csv row 1
    And I scroll 1000 pixels down
    And I press "Import"
    Then I should see "Importing 1 metric answers ..."
    When Jobs are dispatched
    And I wait for ajax response
    Then I should see "Imported 1 metric answers"
    And I should see "Successful"
    And I should see "#1: Jedi+disturbances in the Force+Death Star+2017"
    Then I follow "Jedi+disturbances in the Force+Death Star+2017"
    And I should see "2017"
    And I should see "yes"
    And I should see a "comment" icon
    And I should see "chch"


  Scenario: Import simple metric values with same source
    When I check checkbox for csv row 1
    And I check checkbox for csv row 2
    And I press "Import"
    And I wait for ajax response
    And I go to card "Jedi+Sith Lord in Charge+Death Star+2015"
    Then I should see "2015"
    Then I should see "One country, two systems"
    Then I should see a "comment" icon
    Then I should see "just kidding"
    And I go to card "Jedi+Sith Lord in Charge+Death Star+2014"
    Then I should see "2014"
    And I should see "HKSAR?"
    And I should not see a "comment" icon

  Scenario: Import duplicated metric values with a same source
    When I check checkbox for csv row 3
    And I press "Import"
    And I wait for ajax response
    And I scroll -10000 pixels
    And I follow "Import ..."
    And I uncheck all checkboxes
    And I check checkbox for csv row 4
    And I press "Import"
    And I wait for ajax response
    Then I should see "Metric values exist and are not modified."
    And I should see "Joe User+researched+Apple_Inc+2009"

  Scenario: Import duplicated metric values with a different source
    When I check checkbox for csv row 3
    And I press "Import"
    And I wait for ajax response
    And I scroll -10000 pixels
    And I follow "Import ..."
    And I uncheck all checkboxes
    And I check checkbox for csv row 5
    And I press "Import"
    And I wait for ajax response
    Then I should see "Metric values exist with different source and are not modified."
    And I should see "Joe User+researched+Apple_Inc+2009"

  Scenario: Import metric values conflict with existing value
    When I check checkbox for csv row 3
    And I press "Import"
    And I wait for ajax response
    And I scroll -10000 pixels
    And I follow "Import ..."
    And I uncheck all checkboxes
    And I check checkbox for csv row 6
      And I wait for ajax response
    Then I should see "Problems with import answers"
    And I should see "JOE USER+RESEARCHED+APPLE_INC+2009+METRIC VALUE: value '10' exists"

  Scenario: Import a metric value with partial matching company
    When I check checkbox for csv row 7
    And I press "Import"
    And I wait for ajax response
    And I go to card "Joe User+researched+Apple_Inc+2008"
    Then I should see "2008"
    And I should see "11"
    And I should not see a "comment" icon

  Scenario: Import a metric value with no matching
    When I check checkbox for csv row 8
    And I press "Import"
    And I wait for ajax response
    And I go to card "Joe User+researched+A Missing Company+2008"
    Then I should see "2008"
    And I should see "11"
    And I should not see a "comment" icon

  Scenario: Import a metric value with corrected company name
    When I check checkbox for csv row 7
    And I fill in "Samsung" for csv row 7
    And I press "Import"
    And I wait for ajax response
    And I go to card "Joe User+researched+Samsung+2008"
    Then I should see "2008"
    And I should see "11"
    And I should not see a "comment" icon
    When I go to card "Samsung+aliases"
    And I should see "Apple"

  Scenario: Award badges
    And I check checkbox for csv row 9
    And I check checkbox for csv row 10
    And I check checkbox for csv row 11
    And I check checkbox for csv row 12
    And I check checkbox for csv row 13
    And I check checkbox for csv row 14
    And I check checkbox for csv row 15
    And I press "Import"
    And I wait for ajax response
    Then I should see "SPECTRE Researcher"
    And I should see "Samsung Researcher"
    And I should see "Inside Source"
    And I wait 5 seconds
    And I go to card "Joe Camel+metric values+badges earned"
    Then I should see "SPECTRE Company Awarded for adding 3 answers about SPECTRE"
    And I should see "Samsung Company Awarded for adding 3 answers about Samsung"
    And I go to card "Joe Camel+source+badges earned"
    And I should see "Inside Source"

