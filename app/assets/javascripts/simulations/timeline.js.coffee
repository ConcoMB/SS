jQuery ->
  calculateTimeout = (speed) ->
    return 1000/speed

  updateResults = (data) ->
    $('#packets-sent').html(data.state.packets.sent)
    $('#packets-arrived').html(data.state.packets.arrived)
    $('#segments-sent').html(data.state.segments.sent)
    $('#segments-arrived').html(data.state.segments.arrived)
    $('#segments-lost').html(data.state.segments.lost)
    $("#times").highcharts().series[0].setData(data.times)
    if window.lastArrived < data.state.packets.arrived || window.lastSent < data.state.packets.sent
      bufferChart.highcharts().series[0].addPoint(data.state.bufferSize)
      window.lastArrived = data.state.packets.arrived
      window.lastSent = data.state.packets.sent

  requestResults = ->
    #console.log('updating...')
    target = $('#results')
    $.ajax
      url: target.data('url')+'?time='+time()
      dataType: 'json'
      success: (data) ->
        progress = data.state.packets.sent / Number(target.data('total-packets'))
        progress_arrived = data.state.packets.arrived / Number(target.data('total-packets'))

        #console.log('progress:' + progress)
        $('#progress').css({width: progress * 100 + '%'})
        $('#progress-arrived').css({width: progress_arrived * 100 + '%'})

        if progress >= 1
          timer.stop()
          ticker.stop()
          $('#show-results').removeClass('hide')
          $('#envelope').hide()
          $('#stop').hide()
          $('#running').hide()
        updateResults(data)

  tick = ->
    $('#time').html(time()+1)

  time = ->
    Number($('#time').text())

  slider = $('#speed-slider').slider
    min: 1
    max: 500
    change: ->
      value = $('#speed-slider').slider('value')
      $('#speed').html(value)
      ticker.reset(calculateTimeout(value))
  timer = $.timer(200, requestResults, false)
  ticker = $.timer(calculateTimeout(slider.slider('value')), tick, false)

  $('#stop').click ->
    timer.stop()
    ticker.stop()
    $('#envelope').hide()

  window.lastArrived = 0
  window.lastSent = 0
  bufferChart = $('#bufferChart').highcharts
      chart:
        type: 'line'
        width: 500
        height: 300

      title:
        text: 'Buffer Size'

      yAxis:
        min: 0
        title:
          text: $(this).data("yAxis")

      tooltip:
        headerFormat: "<span style=\"font-size:10px\">{point.key}</span><table>"
        pointFormat: "<tr><td style=\"color:{series.color};padding:0\">{series.name}: </td>" + "<td style=\"padding:0\"><b>{point.y:.3f} </b></td></tr>"
        footerFormat: "</table>"
        shared: true
        useHTML: true

      plotOptions:
        column:
          pointPadding: 0.2
          borderWidth: 0

      series: [
        data: []
      ]
  $("#times").each ->
    $(this).highcharts
      chart:
        width: 450
        height: 300
        type: $(this).data("type")

      title:
        text: $(this).data("title")

      yAxis:
        min: 0
        title:
          text: $(this).data("yAxis")

      tooltip:
        headerFormat: "<span style=\"font-size:10px\">{point.key}</span><table>"
        pointFormat: "<tr><td style=\"color:{series.color};padding:0\">{series.name}: </td>" + "<td style=\"padding:0\"><b>{point.y:.3f} </b></td></tr>"
        footerFormat: "</table>"
        shared: true
        useHTML: true

      plotOptions:
        column:
          pointPadding: 0.2
          borderWidth: 0

      series: [
        data: []
      ]
