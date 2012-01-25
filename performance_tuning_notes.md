# Performance Tuning Notes

Benchmark using site with ~700 pages, ~120 sections, ~1200 section_nodes in development mode.

Overall, Rails 3 has similar performance characteristics to Rails 2. The changes to the sitemap have reduced the # of queries that larger sites will experience.

## Further Improvements

* Viewing a page (/some-page) is can still be ~100 queries and ~0.7s.
** Jumps up to ~250 when edit mode is on
* Sitemap is still the same # of queries (9) but is slower in Rails 3 (5s vs 2.5). Probably ActiveRecord loading.
* /content_library still ~1.2s and ~150 queries
