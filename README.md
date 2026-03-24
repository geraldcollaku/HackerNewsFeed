# HackerNewsFeed

[![CI-macOS](https://github.com/geraldcollaku/HackerNewsFeed/actions/workflows/CI-macOS.yml/badge.svg)](https://github.com/geraldcollaku/HackerNewsFeed/actions/workflows/CI-macOS.yml)

A Swift iOS application that displays the latest Hacker News feed with offline support and intelligent caching.

---

## 📋 Feature Specifications

### Story: Customers Request to See Their News Feed

#### Narrative #1: Online Customer

```
As an online customer
I want the app to automatically load news from remote
So I can always enjoy the latest news
```

**Acceptance Criteria:**
```
Given the customer has connectivity
    When the customer requests to see the feed
    Then the app should display the latest feed from remote
    And replace the cache with the new feed
```

#### Narrative #2: Offline Customer

```
As an offline customer
I want the app to show the latest saved version of my feed
So I can always enjoy getting the news
```

**Acceptance Criteria:**
```
Given the customer doesn't have connectivity
    And there is a cached version of the feed
    And the cache is less than 7 days old
When the customer requests to see the feed
Then the app should display the cached feed

Given the customer doesn't have connectivity
    And there is a cached version of the feed
    And the cache is older than 7 days
When the customer requests to see the feed
Then the app should display an error message

Given the customer doesn't have connectivity
    And the cache is empty
When the customer requests to see the feed
Then the app should display an error message
```

---

## 🎯 Use Cases

### Load Feed From Remote

**Data:**
- URL

**Primary Course (Happy Path):**
1. Execute `Load News` command with the provided URL
2. System downloads data from the URL
3. System validates the downloaded data
4. System creates news feed
5. System delivers news feed

**Error Courses:**
- **Invalid Data:** System delivers invalid data error
- **No Connectivity:** System delivers no connectivity error

---

## 📊 Model Specifications

### Story ID

| Property | Type  |
|----------|-------|
| `id`     | `Int` |

### Payload Contract

```
GET /v0/newstories

200 Response

[
    46374488,
    46374487,
    46374481
]
```

---

### Load Story From Remote Use Case

#### Data
- ID

#### Primary Course
1. Execute `Load Story` command with the provided ID
2. System downloads data from the URL
3. System validates the downloaded data
4. System creates story model
5. System delivers story model

#### Cancellation Course
1. System doesn't deliver story nor error

#### Invalid Data - error course (sad path):
1. System delivers invalid data error

#### No Connectivity - error course (sad path):
1. System delivers no connectivity error

---

### Load Feed From Cache

**Max Age:** 7 days

#### Primary Course:
1. Execute "Load Feed Ids" command
2. System fetches feed data from cache
3. System validates cache is less than 7 days old
4. System creates feed ids from cached data
5. System delivers feed ids

#### Error Courses:
- **Retrieval Error:** System deletes cache and delivers error
- **Expired Cache:** System deletes cache and delivers no feed ids
- **Empty Cache:** System delivers no feed ids

### Validate Feed Cache

#### Primary Course:
1. Execute "Validate Cache" command
2. System fetches feed data from cache
3. System validates cache is less than 7 days old

#### Error Courses:
- **Retrieval Error:** System deletes cache
- **Expired Cache:** System deletes cache

### Cache Feed

**Data:**
- Feed Ids

#### Primary Course:
1. Execute `Save Feed Ids` command
2. System deletes old cache data
3. System encodes feed ids
4. System timestamps the new cache
5. System saves new cache data
6. System delivers success message

#### Error Courses:
- **Delete Error:** System delivers error
- **Saving Error:** System delivers error

---

### Load Feed from cache use case

#### Data
- ID

#### Primary Course (happy path):
1. Execute `Load Story` command with the data above
2. System fetches data from cache
3. System delivers data from cache

#### Cancel Course:
1. System doesn't deliver story nor error

#### Retrieval Error - error course (sad path):
1. System delivers retrieval error

#### Expired Cache - error course (sad path):
1. System delivers no story data

---

## ✅ Store Implementation Expectations

**Retrieve:**
- ✅ Empty cache returns empty
- ✅ Empty cache twice returns empty (no side-effects)
- ✅ Non-empty cache returns data
- ✅ Non-empty cache twice returns same data (no side-effects)
- ✅ Error returns error (if applicable, e.g., invalid data)
- ✅ Error twice returns same error (if applicable, e.g., invalid data)

**Insert:**
- ✅ To empty cache stores data
- ✅ To non-empty cache overrides previous data with new data
- ✅ Error handling (if applicable, e.g., no write permission)

**Delete:**
- ✅ Empty cache does nothing (cache stays empty and does not fail)
- ✅ Non-empty cache leaves cache empty
- ✅ Error handling (if applicable, e.g., no delete permission)

**Concurrency:**
- ✅ Side-effects must run serially to avoid race conditions
