$(document).ready(function() {
  var readyTracker = new ReadyTracker();
  var pusher = new Pusher('39cc3ae7664f69e97e12', { encrypted: true });
  var user_id = $("#game_info").data("user_id");
  var num_players = $("#game_info").data("num_players");
  var channel = pusher.subscribe('waiting_for_players_channel_' + user_id);

  channel.bind('pusher:subscription_succeeded', function() {
    $.post('/subscribed', { user_id: user_id, num_players: num_players });
    readyTracker.setReadyOn();
  });
  channel.bind('send_to_game_event', function(data) {
    window.location = "../" + data["message"]
  });
});
