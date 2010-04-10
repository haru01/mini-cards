function post() {
  if ($("#text").val()) {
    
    $.post("/cards", $("form").serialize(), function(data){
      $("#first_recent").after('<div class="card hoge"><p class="text">'+ data +'</p></div>')
    });
    $("#text").val("")
    $("#text").focus();
  }
}
