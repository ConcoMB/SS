jQuery ->
  $(".chart").each ->
    $(this).highcharts
      chart:
        type: $(this).data("type")

      title:
        text: $(this).data("title")

      yAxis:
        min: 0
        title:
          text: $(this).data("yAxis")

      tooltip:
        headerFormat: "<span style=\"font-size:10px\">{point.key}</span><table>"
        pointFormat: "<tr><td style=\"color:{series.color};padding:0\">{series.name}: </td>" + "<td style=\"padding:0\"><b>{point.y:.1f} mm</b></td></tr>"
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
      
  $.ajax(
    type: "GET",
    url: "/simulations/" + $("#sim").data("id") + "/results"
    dataType: "json"
    async: true
  ).done (data) ->
    $("#time").highcharts().series[0].setData(data.times)
    $("#ratios").highcharts().series[0].setData(data.ratios)
    
      
