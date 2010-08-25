Feature: Analytics Homepage
  In order to anticipate trends and topics of high public interest
  As an Analyst
  I want to view analytics on usasearch query data. The analytics contains two sections: most popular queries,
    and biggest mover queries. Each of these is broken down into different timeframes (1 day, 7 day, and 30 day).

  Scenario: Viewing the homepage
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And there is analytics data from "20090909" thru "20090911"
    When I am on the analytics homepage
    Then I should see "Data for September 11, 2009"
    And I should see "Most Frequent Queries"
    And in "dqs1" I should see "aaaa"
    And in "dqs7" I should see "aaaa"
    And in "dqs30" I should see "aaaa"
    And I should see "Hot Topics for the Day"
    And in "qas0" I should see "aaaa"
    And in "qas1" I should see "aaah"
    And in "qas2" I should see "aaao"

  Scenario: No daily query stats available for any time period
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And there are no daily query stats
    When I am on the analytics homepage
    Then in "dqs1" I should see "Not enough historic data"
    And in "dqs7" I should see "Not enough historic data"
    And in "dqs30" I should see "Not enough historic data"

  Scenario: No query accelerations (biggest movers) available
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And there are no query accelerations stats
    When I am on the analytics homepage
    Then I should not see "Hot Topics for the Day"

  Scenario: Viewing queries with at least 4 queries per day that are part of query groups (i.e., semantic sets)
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And the following DailyQueryStats exist:
    | query                       | times   |  days_back  |
    | obama                       | 10000   |    1        |
    | health care bill            |  1000   |    1        |
    | health care reform          |   100   |    1        |
    | obama health care           |    10   |    1        |
    | president                   |     4   |    1        |
    | ignore me                   |     1   |    1        |
    And the following query groups exist:
    | group      | queries                                                 |
    | POTUS      | obama, president, obama health care, ignore me          |
    | hcreform   | health care bill, health care reform, obama health care |
    When I am on the analytics homepage
    Then in "dqs1" I should see "hcreform"
    And in "dqs1" I should see "1110"
    And in "dqs1" I should see "POTUS"
    And in "dqs1" I should see "10014"

  Scenario: Visiting the FAQ page
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And I am on the analytics homepage
    When I follow "FAQ"
    Then I should be on the FAQ page
    And I should see "Frequently Asked Questions about Analytics"
