jQuery ->
  calculateTimeout = (speed) ->
    return 1000/speed

  updateResults = ->
    console.log('updating...')
    target = $('#results')
    $.ajax
      url: target.data('url')+'?time='+time()
      dataType: 'json'
      success: (data) ->
        progress = data.state.packets.arrived / Number(target.data('total-packets'))
        console.log('progress:' + progress)

  tick = ->
    $('#time').html(time()+1)

  time = ->
    Number($('#time').text())

  slider = $('#speed-slider').slider
    min: 1
    max: 1000
    change: ->
      value = $('#speed-slider').slider('value')
      $('#speed').html(value)
      ticker.reset(calculateTimeout(value))
  timer = $.timer(500, updateResults, false)
  ticker = $.timer(calculateTimeout(slider.slider('value')), tick, false)