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
