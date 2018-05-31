
After receiving the exercise instructions from the recruiter, I thought through the [requirements](./requirements.md) and put together a plan of attack. I created a GitHub repo and transferred the plan into [a series of issues](https://github.com/twelvelabs/web_analytics/projects/1). Issues and a Kanban board were probably overkill for a project so small, but I wanted to show to the employer that I knew how to break down tasks, manage a project, and communicate status (important skills for a remote employee).

In retrospect, I don't know how well I pulled that off. I usually would spend a whole day writing a project plan and tasking out issues. Since I wanted to get this finished ASAP, I had to go pretty terse. So it goes.

Anyway... first up:

### [Stub out Rails app](https://github.com/twelvelabs/web_analytics/issues/1)

I wanted to use `docker` and `docker-compose` so that it would be really easy for someone to spin this up locally w/out having to worry about conflicting dependencies and/or polluting their local environment. On one hand it's a bit of gold plating that ended up eating into my time, on the other I tend to use docker with all my work projects (even prototypes).

Once I had [docker setup](https://github.com/twelvelabs/web_analytics/commit/3dcccf54a479070ce2fb004003acfafa9c0d6553), I used the container to [spin up a rails app](https://github.com/twelvelabs/web_analytics/commit/477f588db68a0c67c9a8f5d2b87b3911147f7d43) and [add the gems](https://github.com/twelvelabs/web_analytics/commit/69b77323ffbafc01194582707c27985881070d25) I thought I would need. Using `sequel` rather than `activerecord` was a requirement, and since I didn't have any prior experience with it I decided to use `sequel-rails`, which takes care of some of the setup and integration. I also threw `oj` in there, which I've used before to speed up `JSON` generation in APIs.

Finally, I setup `minitest` the way I like it - using the spec syntax and reporter (I like how the output reads like documentation). Also setup `rubocop` because I have it integrated in my text editor so that files are linted on save if it's installed, and I'm hooked on using it.

By this point I had everything ready to start writing tests and developing, so lets...

### [Setup the dataset](https://github.com/twelvelabs/web_analytics/issues/2)

_[see #7 for all the commits]_

Seemed like the constraint of using `sequel` was intentional in order to take people out of their comfort zone, and that was totally my experience. Felt like I could have done this portion in half the time (if not more) had I been using AR. Thankfully the sequel docs were pretty good, and was able to plow through it.

Creating the migration and model was pretty straight forward. I knew that I'd likely be aggregating on `created_at`, `url`, and `referrer` in the controller, so I went ahead and setup a covering index for them. I do regret spending time on model validations. Seemed like they'd come in handy when creating the dataset, but ended up being unused.

For bulk inserting, I wrote a util that would first create a 1M row CSV file (if needed), then import it via `COPY INTO`. This should be much faster than just doing regular inserts. One tricky bit was that since the `hash` column needed to contain a MD5 hash that included the primary key, and I wanted to do the import in one pass, I needed to manually manage the `id` (vs. using the auto incrementing sequence). Apparently something I was doing caused the sequence to get out of sync, and I started getting `unique constraint` errors in the unit tests, so I have to manually reset the sequence after the import process. Yay!

### [Create API endpoints](https://github.com/twelvelabs/web_analytics/issues/3)

I managed to [hack together](https://github.com/twelvelabs/web_analytics/commit/9c61d624632a96b61a3ee9a1df2a455b4d69c66e) something approximating what was required, but wasn't terribly happy with it.

The `top_urls` endpoint was pretty easy:

```sql
SELECT date(created_at), url, COUNT(*) AS count
FROM pageviews
WHERE created_at BETWEEN 'YYYY-MM-DD' AND 'YYYY-MM-DD'
GROUP BY date(created_at), url
ORDER BY count DESC
```

The performance of the query increased relative to the size of the date range, but for a five day window it was _good enough™_. The `top_referrers` query was a bit more difficult. The requirement to show only the top 5 referrers for only the top 10 urls made it difficult to do in a single query. I still suspect that it's possible via window function shenanigans, but it's a bit beyond my SQL skills at the moment. Just getting the top 10 urls was trivial though, and getting the top 5 referrers for a single URL was crazy fast due to the covering index I setup. So, while I'm loathe to purposely resort to N+1 queries... it _is_ a prototype :grimacing:.

In all seriousness, if this were a real life work project, I'd probably be considering things like pre-calculating the counts as pageviews are stored in something like memcache or redis.

### [Benchmark API endpoints](https://github.com/twelvelabs/web_analytics/issues/4)

I wasn't too happy w/ how the controller looked, so I extracted the logic into a report class and wrote unit tests for it. I designed it so that it fetches and caches a day of pageview data at a time. While it's slightly less efficient than fetching the full date range, it seemed like it would allow for better cache reuse w/ longer TTLs. For example, I could see setting the TTL for today to `5.minutes` and all others to `2.weeks`. 

As one would expect, caching improved the response time of the API endpoints dramatically. I did a simple load test using `siege` (instructions in the README) and was pretty happy with the result.


### [Setup front end](https://github.com/twelvelabs/web_analytics/issues/5)

tktk

### [Create React components](https://github.com/twelvelabs/web_analytics/issues/6)

tktk

