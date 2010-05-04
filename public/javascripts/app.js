function post() {
  if ($("#text").val()) {    
    $.post("/cards", $("form").serialize(), function(data){
      $("#first_recent").after('<div class="card">'+ data +'</div>')
    });
    $("#text").val("");
    $("#text").focus();
  }
}

function card_save() {
  alert("call save");
}

function card_edit() {
  $("div.card>form>input").show();
  $("div.card>form>textarea").show();
  $("div.card>form>.text").hide();
}
