$(function() {
  $("#help").on("click", function() {
    $(".modal_layer, .modal").fadeIn(300);
  });

  $(".modal_layer").on("click", function() {
    $(".modal_layer, .modal").fadeOut(300);
  });

  /* add click events to the "game type" and "add player" buttons
     to make XMLHttpRequests to the respective routes

       for players, this will add the new player to the player array and update the player list
         OR
       if the route returns a bad code, it will display the flash message

       for the gametype buttons, this will make the requests to set the gametype and then dissolve most of the shown elements and replace them with the setup view elements. (organize all into respective divs for easy transitions)

  */

});