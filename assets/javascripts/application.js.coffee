#= require_tree ./vendor/plugins
#= require_tree ./lib/extensions

$ ->
  
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
    center    = new google.maps.LatLng(0,0)
    

    if google.loader.ClientLocation
      center = new google.maps.LatLng google.loader.ClientLocation.latitude, google.loader.ClientLocation.longitude
      zoom = 12

  
    map = new google.maps.Map document.getElementById('map'), 
      zoom: zoom
      center: center
      mapTypeId: google.maps.MapTypeId.TERRAIN

    marker = new google.maps.Marker
      map: map
      center: center
      draggable: true

    set = (data) ->
      center = new google.maps.LatLng data.lat, data.lng
      zoom ||= data.zoom
      marker.setPosition center
      map.setCenter center
      map.setZoom zoom
      $tips.slideDown()
      $results.slideUp()
      $lat_display.text(data.lat)
      $lng_display.text(data.lng)
      $address_display.text(data.address)
      $search_field.val(data.address)
      $link.val("#{location.origin}?lat=#{data.lat}&lng=#{data.lng}")
      $details.slideDown()

    fetch = (latLng) ->
      geocoder.geocode {'latLng': latLng }, (results, status) ->
        if status is google.maps.GeocoderStatus.OK
          if results[0]
            set 
              lat: results[0].geometry.location.lat()
              lng: results[0].geometry.location.lng()
              address: results[0].formatted_address


    $search_field.bind
      keyup : (event) ->
        if event.keyCode is 13
          $('a',results).eq(0).click()
          return false

    $search_field.autocomplete
      source: (request, response) ->
        geocoder.geocode {'address': request.term }, (results, status) ->
          response $.map results, (item) ->
            return {
              label:      item.formatted_address
              value:      item.formatted_address
              address:    item.formatted_address
              lat:        item.geometry.location.lat()
              lng:        item.geometry.location.lng()
            }

      search: (event, ui) ->
         $results.empty()

      open: (event, ui) ->
         $results.slideDown()        
         $tips.slideUp()
         
      close: (event, ui) ->
         $results.slideUp()        
         $tips.slideDown()

    .data('autocomplete')._renderItem = (ul, item) ->
      $anchor = $("<a href='#'>#{item.label}<i>]</i></a>").data('item.autocomplete', item)
      $('<li />').append($anchor).appendTo($results)

    
    $('a', $results).live 'click', ->
      data = $(this).data('item.autocomplete')
      data.zoom = 17
      set data


    google.maps.event.addListener marker, 'drag', ->
      fetch marker.getPosition()
    
    if @queryString['lat']? and @queryString['lng']
      fetch new google.maps.LatLng @queryString['lat'], @queryString['lng']



  google.load "maps", "3.x", other_params: "sensor=false", callback: initialize



  
  
  
  
  
  
  