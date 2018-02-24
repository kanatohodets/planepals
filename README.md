# PlanePals

An app for a small Elixir demo I did at $work.

It fetches flight tracking information from the OpenSky API, caches it, and
broadcasts to connected clients on a set of channels: the 'firehose' (with bulk
updates of the entire air fleet) and per-plane. The included client is
a javascript app which renders the planes on a world map using `mapboxgl.js`.

It also serves a simple JSON API: `/api/plane`. `/api/plane?icao=all` will get
the full list, while `/api/plane?icao=$some_specific_plane` will get just that
one plane.
