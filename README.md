
[![CI-macOS](https://github.com/geraldcollaku/HackerNewsFeed/actions/workflows/CI-macOS.yml/badge.svg)](https://github.com/geraldcollaku/HackerNewsFeed/actions/workflows/CI-macOS.yml)

## Hacker News Feature specs

### Story: Customers request to see their news feed 

### Narrative #1

```
As an online customer
I want the app to automatically load news from Remote
So I can always enjoy the latest news 
```

#### Scenarios (Acceptance criteria)
```
Given the customer has connectivity
    When the customer requests to see the feed
    Then the app should display the latest feed from remote
    And replace the cache with the new feed
```

### Narrative 2
```
As an offline customer
I want the app to show the latest saved version of my feed
So I can always enjoy getting the news

```

#### Scenarios (Acceptance Criterias)
```
Given the customer doesn't have connectivity
    And there a cached version of the feed
    And the cache is less than 7 days old
When the customer request to see the feed
Then the app should display the cached feed

Given the customer doesn't have connectivity
    And there a cached version of the feed
    And the cache is older than 7 days old or more
When the customer request to see the feed
Then the app should display an error message

Give the customer doesn't have connectivity
    And the cache is empty
When the customer request to see the feed
Then the app should display an error message

```
## Use cases

### Load feed from remote use case

#### Data:
- URL

#### Primary course (happy path):
1. Execute `Load News` command with above data.
2. System downloads data from the URL.
3. System validates the downloaded data.
4. System creates news feed.
5. System delivers news feed.

#### Invalid data - error course (sad path):
1. System delivers invalid data error.

#### No connectivity - error course (sad path):
1. System delivers no connectivity error.

---

## Model specs

### Story ID
| Property     | Type       |
|--------------|------------|
| `id`         | `Int`      |

### Payload contract

```
GET /v0/newstories

200 Response

[
    46374488,
    46374487,
    46374481
]

```

### Load Feed From Cache Use Case
- Max Age (7 days)

#### Primary course:
1. Execute "Load Feed Ids" command with above data.
2. System fetches feed data from cache.
3. System validates cache is less than 7 days old.
4. System creates feed ids from cached data.
5. System delivers feed ids.

#### Retrieval error course (sad path):
1. System deletes cache.
2. System delivers error.

#### Expired cache (sad path):
1. System deletes cache.
2. System delivers no feed ids.

#### Empty cache course (sad path):
1. System delivers no feed ids. 

### Validate Feed Cache Use Case

#### Primary course:
1. Execute "Validate Cache" command with above data.
2. System fetches feed data from cache.
3. System validates cache is less than 7 days old.

#### Retrieval error course (sad path):
1. System deletes cache.

#### Expired cache (sad path):
1. System deletes cache.

### Cache Feed Use Case

#### Data:
- Feed Ids

#### Primary course:
1. Execute `Save Feed Ids` command with above data.
2. System deletes old cache data.
3. System encodes feed ids.
4. System timestamps the new cache.
5. System saves new cache data
6. System delivers success message.

#### Delete error course (sad path):
1. System delivers error.

#### Saving error course (sad path):
1. System delivers error.

### Store implementation expectations
- Retrieve
    - Empty cache
    - Non-empty cache returns data
    - Non-empty cache twice returns same data (no side-effects)
    - Error(if applicable, e.g invalid data)
- Insert 
    - To empty cache
    - To a non-empty cache override previous data with new data
    - Error(if applicable, e.g no write permission)
- Delete
    - Empty cache do nothing (cache stays empty and does not fail)
    - Non-empty cache leaves cache empty
    - Error (if applicable, e.g no delete permission)
