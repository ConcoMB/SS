jQuery ->
  calculateTimeout = (speed) ->
    return 1000/speed

  updateResults = (data) ->
    $('#packets-sent').html(data.state.packets.sent)
    $('#packets-arrived').html(data.state.packets.sent)
    $('#segments-sent').html(data.state.segments.sent)
    $('#segments-arrived').html(data.state.segments.arrived)
    $('#segments-lost').html(data.state.segments.lost)

  requestResults = ->
    console.log('updating...')
    target = $('#results')
    $.ajax
      url: target.data('url')+'?time='+time()
      dataType: 'json'
      success: (data) ->
        progress = data.state.packets.arrived / Number(target.data('total-packets'))
        console.log('progress:' + progress)
        $('#progress').css({width: progress*100+'%'})
        if progress >= 1
          timer.stop()
          ticker.stop()
          $('#show-results').removeClass('hide')
          $('#running').hide()
        updateResults(data)

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
  timer = $.timer(500, requestResults, false)
  ticker = $.timer(calculateTimeout(slider.slider('value')), tick, false)