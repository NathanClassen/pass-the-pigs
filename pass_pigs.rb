require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

require_relative "pigs"

configure do
  enable :sessions
end

def valid_name(name)
  name.strip.empty? ? false : true
end

def player_can_roll?(player)
  player.can_roll
end

def start_computer_turn
  if player_can_roll?(@current_player) && @current_player.will_wager?(game.high_score)
    redirect "/bot/roll"
  else
    redirect "/pass_play"
  end 
end

def game
  session[:game]
end

def format_for_routing(name)
  name.gsub(/ /, '%20')
end

def format_routed(name)
  name.gsub(/%20/, ' ')
end

def best_out_of_10
  if winners.count < 1
    erb :game_tied
  else
    name = format_for_routing(winners.first.name)
    redirect "/announce/#{name}"
  end
end

def winners
  game.players.select do |player|
    player.game_score == game.high_score
  end
end

def first_to_100
  name = format_for_routing(winners.first.name)
  redirect "/announce/#{name}"
end

def reset_game
  session[:game] = nil
end

get "/" do
  erb :home
end

post "/initialize_game" do
  session[:game] = Game.new(params[:game_type])
  ##session[:game].type = params[:game_type]
  redirect "/set_up"
end

get "/set_up" do
  @players = game.players
  erb :set_up
end

post "/name_entry" do
  new_name = params[:player_name]
  if valid_name(new_name)
    game.players << Player.new(new_name)
    redirect "/set_up"
  else
    session[:message] = "That's a lousy name for a champion!"
    redirect '/set_up'
  end
end

post "/bot_entry" do
  loop do
    bot = Computer.new
    if game.name_available?(bot.name)
      game.players << bot
      break
    end
  end
  redirect "/set_up"
end

get "/begin_game" do
  redirect "/round"
end

get "/round" do
  @current_player = game.current_player
  @game_type = game.type
  @current_player.class == Player ? (erb :toss_field) : start_computer_turn
end

get "/pass_play" do
  first_to_100 if game.high_score >= 100 && game.type == 'f_to_100'
  @passing_player = game.current_player
  @passing_player.lock_round_score
  game.next_player
  best_out_of_10 if game.round > 10 && game.type == 'b_O_O_10'
  redirect "/round"
end

post "/roll" do
  @current_player = game.current_player
  @results = @current_player.take_turn
  erb :toss_field
end

get "/bot/roll" do
  @current_player = game.current_player
  @results = @current_player.take_turn
  start_computer_turn
end

get "/announce/:winner" do
  name = format_routed(params[:winner])
  @winner = game.players.select { |p| p.name == name }.first
  erb :game_won
end

get "/another_game" do
  reset_game
  redirect "/"
end

get "/quit_game" do
  reset_game
  erb :quit_game
end