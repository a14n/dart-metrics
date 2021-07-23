# 0.2.0 (2021-07-23)

- update for Dart 2.12 and nullsafety.

# 0.1.0 (2014-12-16)

## Breaking change

- `RegistryListener` has been removed. You should now use streams
`onMetricAdded` dans `onMetricRemoved` on `MetricRegistry`.
- optional named parameters is used at several places.

# 0.0.2 (2014-12-12)

Almost every core classes from the 3.1.0 Java version have been ported.

There's also a [graphite](http://graphite.wikidot.com/) reporter.

# 0.0.1 (2014-11-28)

The initial release that follows mainly the 3.1.0 Java version.

# Semantic Version Conventions

http://semver.org/

- *Stable*:  All even numbered minor versions are considered API stable:
  i.e.: v1.0.x, v1.2.x, and so on.
- *Development*: All odd numbered minor versions are considered API unstable:
  i.e.: v0.9.x, v1.1.x, and so on.
