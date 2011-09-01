Feature: Boosted Content
  In order to boost specific sites to the top of search results
  As an affiliate
  I want to manage boosted Content

  Scenario: Visiting Boosted Contents index page
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         |aff.gov           | aff@bar.gov             | John Bar            |
    And the following Boosted Content entries exist for the affiliate "aff.gov"
      | title                                                                                                      | url                               | description          | keywords | autogenerated | locale | status   | publish_start_on | publish_end_on |
      | Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis at tincidunt erat. Sed sit amet massa massa. | http://www.hello.gov/there.htm    | fire island          | lens     | true          | en     | active   | 08/30/2011       | 08/30/2012     |
      | fresnel lens                                                                                               | http://www.hello.gov/fresnels.htm | fresnels description |          |               | es     | inactive | 09/01/2011       |                |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Boosted content"
    Then I should see the browser page titled "Boosted Contents"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Boosted Contents
    And I should see "Boosted Contents" in the page header
    And I should see "Displaying all 2 boosted contents"
    And I should see 2 Boosted Content Entries
    And I should see "Add new boosted content"
    And I should see the following table rows:
      | Title                          | URL                        | Publish Start | Status   |
      | fresnel lens                   | www.hello.gov/fresnels.htm | 09/01/2011    | Inactive |
      | Lorem ipsum dolor sit amet,... | www.hello.gov/there.htm    | 08/30/2011    | Active   |
    When I follow "fresnel lens"
    Then I should see "fresnel lens"
    And I should see "http://www.hello.gov/fresnels.htm"
    And I should see "fresnels description"
    And I should see "Spanish"
    And I should see "Inactive"

    When there are 30 Boosted Content entries exist for the affiliate "aff.gov":
      | locale | status |
      | en     | active |
    And I go to the aff.gov's boosted contents page
    And I should see "Displaying boosted contents 1 - 20 of 32 in total"
    And I should see 20 Boosted Content Entries
    When I follow "Next"
    Then I should see "Displaying boosted contents 21 - 32 of 32 in total"
    And I should see "title 10"

  Scenario: Create a new Boosted Content entry
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Boosted content"
    Then I should see "aff site has no Boosted Content"
    When I follow "Add new boosted content"
    Then I should see the browser page titled "Add a new Boosted Content"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Add a new Boosted Content
    And I should see "Add a new Boosted Content" in the page header
    And the "Publish start date" field should contain today's date
    And I fill in "Title" with "Test"
    And I fill in "URL" with "http://www.test.gov"
    And I fill in "Description" with "Test Description"
    And I fill in "Keywords" with "unrelated, terms"
    And I select "English" from "Locale*"
    And I select "Active" from "Status*"
    And I press "Add"
    Then I should see "Boosted Content entry successfully added"
    And I should see the browser page titled "Boosted Content"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Boosted Content
    And I should see "Boosted Content" in the page header
    And I should see "Test"
    And I should see "http://www.test.gov"
    And I should see "Test Description"
    And I should see "English"
    And I should see "Active"
    And I should see "unrelated"
    And I should see "terms"
    When I follow "Add another Boosted Content"
    Then I should see the browser page titled "Add a new Boosted Content"
    When I follow "Cancel"
    Then I should see "Boosted Contents" in the page header

  Scenario: Validating Affiliate Boosted Content on create
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And the following Boosted Content entries exist for the affiliate "aff.gov"
      | title        | url                            | description | keywords | autogenerated | status |
      | fresnel lens | http://www.hello.gov/there.htm | fire island | lens     | true          | active |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Boosted content"
    And I follow "Add new boosted content"
    And I fill in the following:
      | Publish start date | 07/01/2012                              |
      | Publish end date   | 07/01/2011                              |
    And I press "Add"
    Then I should see "Title can't be blank"
    And I should see "URL can't be blank"
    And I should see "Description can't be blank"
    And I should see "Locale must be selected"
    And I should see "Status must be selected"
    And I should see "Publish end date can't be before publish start date"

    When I fill in "URL" with "http://www.hello.gov/there.htm"
    And I fill in "Publish start date" with ""
    And I press "Add"
    Then I should see "URL has already been boosted"
    And I should see "Publish start date can't be blank"

  Scenario: Edit a Boosted Content entry
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         |aff.gov           | aff@bar.gov             | John Bar            |
    And the following Boosted Content entries exist for the affiliate "aff.gov"
     | title            | url               | description       | keywords          |
     | a title          | http://a.url.gov  | A description     | unrelated, terms  |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Boosted content"
    And I follow "Edit"
    Then I should be on the edit affiliate boosted content page for "aff.gov"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Edit Boosted Content Entry
    And I fill in "Title" with "new title"
    And I fill in "Description" with "new description"
    And I fill in "Keywords" with "bananas, apples, oranges"
    And I press "Update"
    Then I should see "Boosted Content entry successfully updated"
    And I should see "new title"
    And I should not see "a title"
    And I should see "http://a.url.gov"
    And I should see "new description"
    And I should not see "a description"
    And I should see "bananas, apples, oranges"
    And I should not see "unrelated, terms"
    When I follow "Edit"
    And I follow "Cancel"
    Then I should see "Boosted Contents" in the page header

  Scenario: Validating Affiliate Boosted Content on update
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         |aff.gov           | aff@bar.gov             | John Bar            |
    And the following Boosted Content entries exist for the affiliate "aff.gov"
     | title            | url               | description       | keywords          |
     | a title          | http://a.url.gov  | A description     | unrelated, terms  |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Boosted content"
    And I follow "Edit"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Edit Boosted Content Entry
    And I fill in "Title" with ""
    And I fill in "URL" with ""
    And I fill in "Description" with ""
    And I fill in "Publish start date" with ""
    And I select "Select a locale" from "Locale*"
    And I select "Select a status" from "Status*"
    When I press "Update"
    Then I should see "Title can't be blank"
    And I should see "URL can't be blank"
    And I should see "Description can't be blank"
    And I should see "Locale must be selected"
    And I should see "Status must be selected"
    And I should see "Publish start date can't be blank"

  Scenario: Deleting a boosted content
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         |aff.gov           | aff@bar.gov             | John Bar            |
    And the following Boosted Content entries exist for the affiliate "aff.gov"
      | title          | url                | description   | keywords         |
      | a title        | http://a.url.gov/1 | A description | unrelated, terms |
      | another title  | http://a.url.gov/2 | A description | unrelated, terms |
      | one more title | http://a.url.gov/3 | A description | unrelated, terms |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Boosted content"
    Then I should see "Displaying all 3 boosted contents"
    And I should see "a title"
    And I should see "another title"
    And I should see "one more title"
    When I press "Delete" on the 2nd boosted content entry
    Then I should see "Boosted Content entry successfully deleted"
    And I should see "Displaying all 2 boosted contents"
    And I should see "a title"
    And I should see "one more title"

  Scenario: Deleting all boosted contents
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         |aff.gov           | aff@bar.gov             | John Bar            |
    And the following Boosted Content entries exist for the affiliate "aff.gov"
      | title          | url                | description   | keywords         |
      | a title        | http://a.url.gov/1 | A description | unrelated, terms |
      | another title  | http://a.url.gov/2 | A description | unrelated, terms |
      | one more title | http://a.url.gov/3 | A description | unrelated, terms |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Boosted content"
    Then I should see "a title"
    And I should see "another title"
    And I should see "one more title"
    When I press "Delete all"
    Then I should see "All Boosted Content entries successfully deleted"
    And I should see "aff site has no Boosted Content"
    And I should not see "Delete all" button

  Scenario: Site visitor sees relevant boosted results for given affiliate search
    Given the following Affiliates exist:
      | display_name     | name                  | contact_email         | contact_name        |
      | aff site         | aff.gov               | aff@bar.gov           | John Bar            |
      | bar site         | bar.gov               | aff@bar.gov           | John Bar            |
    And the following Boosted Content entries exist for the affiliate "aff.gov"
      | title               | url                     | description                               | keywords          |
      | Our Emergency Page  | http://www.aff.gov/911  | Updated information on the emergency      | unrelated, terms  |
      | FAQ Emergency Page  | http://www.aff.gov/faq  | More information on the emergency         |                   |
      | Our Tourism Page    | http://www.aff.gov/tou  | Tourism information                       |                   |
    And the following Boosted Content entries exist for the affiliate "bar.gov"
      | title               | url                     | description                               |                   |
      | Bar Emergency Page  | http://www.bar.gov/911  | This should not show up in results        |                   |
      | Pelosi misspelling  | http://www.bar.gov/pel  | Synonyms file test works                  |                   |
      | all about agencies  | http://www.bar.gov/pe2  | Stemming works                            |                   |
    When I go to aff.gov's search page
    And I fill in "query" with "emergency"
    And I submit the search form
    Then I should see "Recommended by aff site"
    And I should see "Our Emergency Page" within "#boosted"
    And I should see "FAQ Emergency Page" within "#boosted"
    And I should not see "Our Tourism Page" within "#boosted"
    And I should not see "Bar Emergency Page" within "#boosted"

    When I go to bar.gov's search page
    And I fill in "query" with "Peloci"
    And I submit the search form
    Then I should see "Synonyms file test works" within "#boosted"

    When I go to bar.gov's search page
    And I fill in "query" with "agency"
    And I submit the search form
    Then I should see "Stemming works" within "#boosted"

    When I go to aff.gov's search page
    And I fill in "query" with "unrelated"
    And I submit the search form
    Then I should see "Our Emergency Page" within "#boosted"

  Scenario: Spanish site visitor sees relevant boosted results for given affiliate search
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
      | bar site     | bar.gov | aff@bar.gov   | John Bar     |
    And the following Boosted Content entries exist for the affiliate "aff.gov"
      | title                                  | url                    | description                          | keywords         | locale |
      | Nuestra página de Emergencia           | http://www.aff.gov/911 | Updated information on the emergency | unrelated, terms | es     |
      | Preguntas frecuentes emergencia página | http://www.aff.gov/faq | More information on the emergency    |                  | es     |
      | Our Tourism Page                       | http://www.aff.gov/tou | Tourism information                  |                  | en     |
    And the following Boosted Content entries exist for the affiliate "bar.gov"
      | title                             | url                    | description                        | keywords | locale |
      | la página de prueba de Emergencia | http://www.bar.gov/911 | This should not show up in results |          | es     |
      | Pelosi falta de ortografía        | http://www.bar.gov/pel | Synonyms file test works           |          | es     |
    When I go to aff.gov's Spanish search page
    And I fill in "query" with "emergencia"
    And I press "Buscar"
    Then I should see "Recomendación de aff site"
    And I should see "Nuestra página de Emergencia" within "#boosted"
    And I should see "Preguntas frecuentes emergencia página" within "#boosted"
    And I should not see "Our Tourism Page" within "#boosted"
    And I should not see "la página de prueba de Emergencia" within "#boosted"

    When I go to bar.gov's Spanish search page
    And I fill in "query" with "Peloci"
    And I press "Buscar"
    Then I should see "Synonyms file test works" within "#boosted"

    When I go to aff.gov's Spanish search page
    And I fill in "query" with "unrelated"
    And I press "Buscar"
    Then I should see "Nuestra página de Emergencia" within "#boosted"

  Scenario: Uploading valid booster XML document as a logged in affiliate
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff <i>site</i>  | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Boosted content"
    And I follow "Bulk upload boosted contents"
    Then I should see the browser page titled "Bulk Upload Boosted Contents"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff <i>site</i> > Bulk Upload Boosted Contents
    And I should see "Bulk Upload Boosted Contents" in the page header
    And I attach the file "features/support/boosted_content.xml" to "xml_file"
    And I press "Upload"
    Then I should see "Successful Bulk Import for affiliate 'aff <i>site</i>'"
    Then I should see "2 Boosted Content entries successfully created."

    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Boosted content"
    Then I should see "This is a listing about Texas"
    And I should see "Some other listing about hurricanes"

    When I follow "Bulk upload boosted contents"
    And I attach the file "features/support/new_boosted_content.xml" to "xml_file"
    And I press "Upload"
    And I follow "Boosted content"
    Then I should see "New results about Texas"
    And I should see "New results about hurricanes"

  Scenario: Uploading invalid booster XML document as a logged in affiliate
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         |aff.gov           | aff@bar.gov           | John Bar            |
    And the following Boosted Content entries exist for the affiliate "aff.gov"
      | title               | url                     | description                               |
      | Our Emergency Page  | http://www.aff.gov/911  | Updated information on the emergency      |
      | FAQ Emergency Page  | http://www.aff.gov/faq  | More information on the emergency         |
      | Our Tourism Page    | http://www.aff.gov/tou  | Tourism information                       |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Boosted content"
    And I follow "Bulk upload boosted contents"
    And I attach the file "features/support/missing_title_boosted_content.xml" to "xml_file"
    And I press "Upload"
    Then I should see "Your XML document could not be processed. Please check the format and try again."

    When I go to aff.gov's search page
    And I fill in "query" with "tourism"
    And I submit the search form
    Then I should see "Our Tourism Page" within "#boosted"

  Scenario: Affiliate search user should see only active boosted contents within publish date range
    Given the following Affiliates exist:
      | display_name | name    | contact_email              | contact_name |
      | aff site     | aff.gov | affiliate_manager@site.gov | John Bar     |
    And the following Boosted Content entries exist for the affiliate "aff.gov"
      | title                                | url                         | description                      | status   | publish_start_on | publish_end_on |
      | expired boosted content              | http://www.aff.gov/expired  | expired description              | active   | prev_month       | yesterday      |
      | future1 boosted content              | http://www.aff.gov/future1  | future1 description              | active   | tomorrow         | next_month     |
      | future2 boosted content              | http://www.aff.gov/future2  | future2 description              | active   | tomorrow         |                |
      | current boosted content              | http://www.aff.gov/current  | current description              | active   | today            | next_month     |
      | current but inactive boosted content | http://www.aff.gov/inactive | current but inactive description | inactive | today            |                |
    When I go to aff.gov's search page
    And I fill in "query" with "boosted"
    And I press "Search"
    Then I should see "current boosted content"
    And I should not see "current but inactive"
    When I fill in "query" with "expired"
    And I press "Search"
    Then I should not see "expired boosted content"
    When I fill in "query" with "future1"
    And I press "Search"
    Then I should not see "future1 boosted content"
    When I fill in "query" with "future2"
    And I press "Search"
    Then I should not see "future2 boosted content"

  Scenario: Affiliate search user should see boosted contents with higher relevancy on title
    Given the following Affiliates exist:
      | display_name | name    | contact_email              | contact_name |
      | aff site     | aff.gov | affiliate_manager@site.gov | John Bar     |
    And the following Boosted Content entries exist for the affiliate "aff.gov"
      | title                     | url                         | description           | status | publish_start_on |
      | boosted content 1         | http://www.aff.gov/current1 | current description 1 | active | today            |
      | boosted content 2         | http://www.aff.gov/current2 | current description 2 | active | today            |
      | current boosted content 3 | http://www.aff.gov/current3 | description 3         | active | today            |
      | current boosted content 4 | http://www.aff.gov/current4 | description 4         | active | today            |
      | current boosted content 5 | http://www.aff.gov/current5 | description 5         | active | today            |
    When I go to aff.gov's search page
    And I fill in "query" with "current"
    And I press "Search"
    Then I should see "current boosted content 3" in the boosted contents section
    And I should see "current boosted content 4" in the boosted contents section
    And I should see "current boosted content 5" in the boosted contents section
    And I should not see "boosted content 1" in the boosted contents section
    And I should not see "boosted content 2" in the boosted contents section

  Scenario: Affiliate search user should see boosted contents with medium relevancy on description
    Given the following Affiliates exist:
      | display_name | name    | contact_email              | contact_name |
      | aff site     | aff.gov | affiliate_manager@site.gov | John Bar     |
    And the following Boosted Content entries exist for the affiliate "aff.gov"
      | title             | url                         | description           | keywords | status | publish_start_on |
      | boosted content 1 | http://www.aff.gov/current1 | description 1         | current  | active | today            |
      | boosted content 2 | http://www.aff.gov/current2 | description 2         | current  | active | today            |
      | boosted content 3 | http://www.aff.gov/current3 | current description 3 | boosted  | active | today            |
      | boosted content 4 | http://www.aff.gov/current4 | current description 4 | boosted  | active | today            |
      | boosted content 5 | http://www.aff.gov/current5 | current description 5 | boosted  | active | today            |
    When I go to aff.gov's search page
    And I fill in "query" with "current"
    And I press "Search"
    Then I should see "boosted content 3" in the boosted contents section
    And I should see "boosted content 4" in the boosted contents section
    And I should see "boosted content 5" in the boosted contents section
    And I should not see "boosted content 1" in the boosted contents section
    And I should not see "boosted content 2" in the boosted contents section
