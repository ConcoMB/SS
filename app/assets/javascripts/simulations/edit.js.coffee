jQuery ->
  $('#technology').change ->
    $('#lossP').val($(@).val())
  .trigger("change")
  $('#demand').change ->
    $('#avg').val($(@).find(":selected").attr("avg"))
    $('#dev').val($(@).find(":selected").attr("dev"))
    $('#lambda').val($(@).find(":selected").attr("lambda"))
  .trigger("change")
