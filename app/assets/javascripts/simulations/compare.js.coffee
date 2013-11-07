jQuery ->
  timeChart = $("#time-chart").highcharts
    chart:
      type: "bar"

    title:
      text: "Simulation Comparation"

    xAxis:
      categories: ["Cable", "Wireless", "Sattelite"]
      title:
        text: null

    yAxis:
      min: 0
      title:
        text: "Mean sent time"
        align: "high"

      labels:
        overflow: "justify"

    tooltip:
      valueSuffix: " miliseconds"

    plotOptions:
      bar:
        dataLabels:
          enabled: true

    legend:
      borderWidth: 1
      backgroundColor: "#FFFFFF"
      shadow: true

    credits:
      enabled: false

    series: [
      name: "Selective Repeat"
      data: []
    ,
      name: "Go Back N"
      data: []
    ,
      name: "Negative Acknowledgement"
      data: []
    ]

  ratioChart = $("#ratio-chart").highcharts
    chart:
      type: "bar"

    title:
      text: "Simulation Comparation"

    xAxis:
      categories: ["Cable", "Wireless", "Sattelite"]
      title:
        text: null

    yAxis:
      min: 0
      title:
        text: "Mean ratio"
        align: "high"

      labels:
        overflow: "justify"

    tooltip:
      valueSuffix: " %"

    plotOptions:
      bar:
        dataLabels:
          enabled: true

    legend:      
      borderWidth: 1
      backgroundColor: "#FFFFFF"
      shadow: true

    credits:
      enabled: false

    series: [
      name: "Selective Repeat"
      data: []
    ,
      name: "Go Back N"
      data: []
    ,
      name: "Negative Acknowledgement"
      data: []
    ]

  console.log($('#simulations').data('ids'))
  $.ajax(
    type: "GET",
    url: "/simulations/compare_data"
    dataType: "json"
    data: {simulation_ids:$('#simulations').data('ids')}
    async: true
  ).done (data) ->
    console.log(data)
    timeChart.highcharts().series[0].setData(data.time.selective_repeat)
    timeChart.highcharts().series[1].setData(data.time.go_back_n)
    timeChart.highcharts().series[2].setData(data.time.negative_acknowledgement)

    ratioChart.highcharts().series[0].setData(data.ratio.selective_repeat)
    ratioChart.highcharts().series[1].setData(data.ratio.go_back_n)
    ratioChart.highcharts().series[2].setData(data.ratio.negative_acknowledgement)