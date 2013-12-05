jQuery ->
  $('.datatable').dataTable({
    "sPaginationType": "bootstrap"
    "iDisplayLength": 50
  });
  $('.simulate').click ->
    console.log('Simulating... ')
    $.ajax
      url: $(this).data('url')
      dataType: 'text'
      type: 'post'
      context: this
      success: (data) ->
        console.log("done!")
        console.log("redirecting to "+$(this).data('timeline-url'))
        window.location.href = $(this).data('timeline-url')