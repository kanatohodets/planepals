// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
// import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import socket from './socket'

var planes = {};
// Now that you are connected, you can join channels with a topic:
let channel = socket.channel('plane:4ca1c2', {});
channel.on('plane', function(plane) {
    planes[plane.icao] = {
        'pos': [plane['long'], plane['lat']],
        'name': plane.icao
    };
    console.log('got a plane', plane)
});
channel.join()
    .receive('ok', resp => {console.log('Joined successfully', resp)})
    .receive('error', resp => {console.log('Unable to join', resp)})

        var url = new URL(window.location.href);
var limit = url.searchParams.get('limit');
if (limit == null) {
    limit = 100;
} else {
    limit = parseInt(limit);
}

/*
let firehose = socket.channel("plane:firehose", {});
firehose.on("plane", function(payload) {
    for (var i = 0; i < payload.planes.length; i++) {
        var plane = payload.planes[i];
        planes[plane.icao] = { "pos": [plane["long"], plane["lat"]], "name":
plane.icao, "country": plane.country }; if (i > limit) { break;
        }
    }
});

firehose.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })
  */

function getPlanes() {
    var features = [];
    Object.keys(planes).forEach(function(key, index) {
        var plane = planes[key];
        features.push({
            'type': 'Feature',
            'geometry': {
                'type': 'Point',
                'coordinates': [
                    plane.pos[0],
                    plane.pos[1],
                ],
            },
            'properties': {'name': plane.name, 'country': plane.country},
        });
    });
    return {
        'type': 'FeatureCollection', 'features': features,
    }
}

// Create a popup, but don't add it to the map yet.
var popup = new mapboxgl.Popup({closeButton: false, closeOnClick: false});

var paused = false;
map.on('load', function() {
    map.loadImage('images/plane.png', function(err, image) {
        if (err) throw err;
        map.addImage('plane', image);
    });
    // Add a source and layer displaying a point which will be animated in a
    // circle.
    map.addSource('point_source', {
        'type': 'geojson',
        'data': getPlanes(),
    });

    map.addLayer({
        'id': 'planes',
        'source': 'point_source',
        'type': 'symbol',
        'layout': {
            'icon-allow-overlap': true,
            'icon-image': 'plane',
            'icon-size': 0.5
        }
    });

    function animateMarker(timestamp) {
        // Update the data to a new position based on the animation timestamp.
        // The divisor in the expression `timestamp / 1000` controls the
        // animation speed.
        if (!paused) {
            map.getSource('point_source').setData(getPlanes(timestamp));
        }

        // Request the next frame of the animation.
        requestAnimationFrame(animateMarker);
    }

    // Start the animation.
    animateMarker(0);

    var button = document.getElementById('stop');
    button.addEventListener('click', function(e) {
        console.log(e);
        if (paused) {
            button.innerHTML = 'STOP';
        } else {
            button.innerHTML = 'GO';
        }
        paused = !paused;
    });

    // When a click event occurs on a feature in the places layer, open a popup
    // at the location of the feature, with description HTML from its
    // properties.
    map.on('click', 'planes', function(e) {
        console.log(e);
        map.flyTo({center: e.features[0].geometry.coordinates});
    });

    // Change the cursor to a pointer when the mouse is over the places layer.
    map.on('mouseenter', 'planes', function(e) {
        if (!paused) {
            return;
        }
        var name = e.features[0].properties.name;
        var country = e.features[0].properties.country;
        map.getCanvas().style.cursor = 'pointer';
        var coordinates = e.features[0].geometry.coordinates.slice();

        // Ensure that if the map is zoomed out such that multiple
        // copies of the feature are visible, the popup appears
        // over the copy being pointed to.
        while (Math.abs(e.lngLat.lng - coordinates[0]) > 180) {
            coordinates[0] += e.lngLat.lng > coordinates[0] ? 360 : -360;
        }

        /*
        var messages = [];
        let chat = socket.channel("plane:" + name, {});
        chat.on("chat", function(payload) {
            messages.push(payload);
            popup.setHTML(messages.join("<br>"));
        });

        chat.join()
          .receive("ok", resp => { popup.setHTML("now part of chat for plane " +
        name) }) .receive("error", resp => { console.log("Unable to join", resp)
        })
        */


        popup.setLngLat(coordinates)
            .setHTML('This is plane ' + name + ' from ' + country)
            .addTo(map);
    });

    // Change it back to a pointer when it leaves.
    map.on('mouseleave', 'planes', function() {
        map.getCanvas().style.cursor = '';
        popup.remove();
    });
});
