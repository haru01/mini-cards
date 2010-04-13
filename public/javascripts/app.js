function post() {
  if ($("#text").val()) {    
    $.post("/cards", $("form").serialize(), function(data){
      $("#first_recent").after('<div class="card">'+ data +'</div>')
    });
    $("#text").val("");
    $("#text").focus();
  }
}
