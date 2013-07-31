#= require_tree ./vendor/plugins
#= require_tree ./lib/extensions

$ ->
  
  fxspeed = 250

  initialize = ->
    lat      = null
    lng      = null
    address  = null
    zoom     = 10

    $search_field     = $('#search_field').focus()
    $tips             = $('#tips')
    $details          = $('#location-details')
    $lat_display      = $('#lat')
    $lng_display      = $('#lng')
    $address_display  = $('#address')
    $results          = $('#results_items')
    $link             = $('#link')

    geocoder  = new google.maps.Geocoder()
    autoCompleteService = new google.maps.places.AutocompleteService()
    placesService = new google.maps.places.PlacesService $('<div/>')[0]

    if google.loader.ClientLocation?
      center = new google.maps.LatLng google.loader.ClientLocation.latitude, google.loader.ClientLocation.longitude
      zoom = 12
    else
      center = new google.maps.LatLng(0,0)
      zoom = 3


    map = new google.maps.Map document.getElementById('map'),
      zoom: zoom
      center: center
      mapTypeId: google.maps.MapTypeId.ROADMAP

    marker = new google.maps.Marker
      map: map
      center: center
      draggable: true

    set = (data) ->
      lat = data.lat
      lng = data.lng
      center = new google.maps.LatLng lat, lng
      zoom = parseInt(data.zoom) if data.zoom?
      address = data.address if data.address?
      update()

    fetch = (latLng) ->
      geocoder.geocode {'latLng': latLng }, (results, status) ->
        if status is google.maps.GeocoderStatus.OK
          if results[0]
            set
              lat: results[0].geometry.location.lat()
              lng: results[0].geometry.location.lng()
              address: results[0].formatted_address

    update = ->
      update_search_field()
      update_location_details()
      update_link()
      update_map()
      update_marker()      

    update_map = ->
      map.setCenter(center)
      map.setZoom(zoom)

    update_marker = ->
      marker.setPosition(center)

    update_search_field = ->
      $search_field.val(address)
      $results.slideUp fxspeed, ->
        $tips.slideDown(fxspeed)

    update_location_details = ->
      $lat_display.text(lat)
      $lng_display.text(lng)
      $address_display.text(address)
      $details.slideDown(fxspeed)

    update_link = ->
      $link.val("http://#{location.host}?lat=#{lat}&lng=#{lng}&zoom=#{zoom}")

    fetch_coords = (data, callback) ->
      placesService.getDetails
        reference: data.reference
      , (results, status) ->
        data.lat = results.geometry.location.jb
        data.lng = results.geometry.location.kb
        return callback data

    $search_field.bind
      keyup : (event) ->
        if event.keyCode is 13
          $('a',results).eq(0).click()
          return false

    $search_field.autocomplete
      source: (request, response) ->
        autoCompleteService.getPlacePredictions
          input: request.term
        , (results, status) ->
          response $.map results, (item) ->
            return {
              label: item.description
              value: item.description
              address: item.description
              reference: item.reference
            }

      search: (event, ui) ->
         $results.empty()

      open: (event, ui) ->
         $results.slideDown(fxspeed)
         $tips.slideUp(fxspeed)

      close: (event, ui) ->
         $results.slideUp(fxspeed)
         $tips.slideDown(fxspeed)

    .data('autocomplete')._renderItem = (ul, item) ->
      $anchor = $("<a href='#'>#{item.label}<i>]</i></a>").data('item.autocomplete', item)
      $('<li />').append($anchor).appendTo($results)


    $('a', $results).live 'click', ->
      data = $(this).data('item.autocomplete')
      data.zoom = 17
      fetch_coords data, set


    google.maps.event.addListener marker, 'dragend', ->
      fetch marker.getPosition()

    google.maps.event.addListener map, 'zoom_changed', ->
      zoom = map.getZoom()
      update_link()


    if @queryString['lat']? and @queryString['lng']
      if @queryString['zoom']
        zoom = parseInt @queryString['zoom']
      fetch new google.maps.LatLng @queryString['lat'], @queryString['lng']



  google.load "maps", "3.x", other_params: "sensor=false&libraries=places", callback: initialize










