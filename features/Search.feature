Feature: Authorized client logs in

  Scenario: Client receives access token
    Given a client account with credentials
    When the client authenticates themselves with correct credentials
    Then the client receives an OAuth2 access token

Feature: Authorized client views workspace

  Scenario: Client views empty workspace
    Given Client receives access token
    And Client has no indices
    When Client requests to view their workspace with their access token
    Then Client receives a response that contains the following Elements:
      | Account identifier |
      | index-list         |
    And "index-list" is empty
    And a hyperlink indicating which URI to use to create an index

  Scenario: Client views non-empty workspace
    Given Client receives access token
    And Client creates index with their access token
    When Client requests to view their workspace with their access token
    Then Client receives a response that contains the following Elements:
      | Account identifier |
      | index-list         |
    And "index-list" contains all existing indices
    And a hyperlink indicating which URI to use to create an index

Feature: As an authorized API client, I want to create a search index

  Scenario: Unauthenticated Client cannot create search index
    Given an Unauthenticated Client
    When the client attempts to create a search index
    Then the client receives a response indicating that their request will not be processed

  Scenario: Client creates index without specifications with their access token
    When Authenticated Client attempts to create a search index
    Then the client receives a response indicating that their request is being processed
    And the response includes information where to find the new index

  Scenario: Client creates index with specifications with their access token
    When Authenticated Client attempts to create a search index with an ElasticSearch compliant specification including:
      | Settings for the index           |
      | Mappings for fields in the index |
      | Index aliases                    |
    Then the client receives a response indicating that their request is being processed
    And the response includes information where to find the new index

Feature: An an authenticated API Client, I attempt to fetch index information

  Scenario: Authenticated API Client attempts to fetch index information of non-owned index
    When Authenticated Client attempts to fetch information about an index that does not exist in their workspace
    And the index exists in another Client's workspace
    Then Authenticated Client receives a response indicating that the requested index does not exist

  Scenario: Authenticated API Client attempts to fetch index information of non-existent index
    When Authenticated Client attempts to fetch information about an index that does not exist
    Then Authenticated Client receives a response indicating that the requested index does not exist

  Scenario: Authenticated API Client attempts to fetch index information of owned index
    When Authenticated Client attempts to fetch information about an index that exists in their workspace
    Then Authenticated Client receives a response containing information about the index


Feature: An Authenticated API Client does anything else on an index

   Scenario: Authenticated API Client does X on owned index
     When Authenticated Client requests to do X on an owned index
     Then Authenticated Client receives a response from the search engine
     And the response is the live search engine's response to the request

  Scenario: Authenticated API Client requests to do X on non-owned index
    When Authenticated Client requests to do X on a non-owned index
    Then Authenticated Client receives a response from the search engine
    And Authenticated Client receives a response indicating that the specified index does not exist
    
    
Rule: Root operations are not allowed

  Scenario: Authenticated API Client requests a root operation (i.e. an operation starting with _, f.eks. _cat)
    When Authenticated API Client requests a root operation
    Then Authenticated Client recieves a Bad Request response
