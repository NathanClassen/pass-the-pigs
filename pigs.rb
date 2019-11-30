module GameData
  COMBOS = { "jow" => 60, "snt" => 40, "trt" => 20,
           "rzr" => 20, "pnk" =>  1, "dot" =>  1 }
  SINGLE = { "jow" => 15, "snt" => 10, "trt" => 5,
           "rzr" => 5, "pnk" => 1, "dot" => 1}
  COMPUTER_NAMES = ["Maggie O'Briney", "Stephen Swineock", "Nicholas Ham'mer", "Sir Bacon", "Sven Oinkered", "Patti Pigmalion"]
end

class Game
  attr_accessor :players, :round, :current_player, :type
  def initialize(game_type)
    @players = []
    @player_index = 0
    @round = 1
    @type = game_type
  end

  def current_player
    @players[@player_index]
  end

  def high_score
    @players.map { |player| player.game_score }.max
  end

  def next_player
    update_index
  end

  def name_available?(new_name)
    names = @players.map { |p| p.name }
    !names.include?(new_name)
  end

  def update_index
    if @player_index == (@players.count - 1)
      @player_index = 0
      @round += 1
    else
      @player_index += 1
    end
  end
end

class Player
  attr_reader :name
  attr_accessor :game_score, :round_score, :can_roll

  def initialize(name)
    @name = name
    @game_score = 0
    @round_score = 0
    @roll_score = 0
    @can_roll = true
    @rolled_pigs = []
  end

  def pigs
    pigs = []
    35.times { pigs << "pnk" }
    30.times { pigs << "dot" }
    20.times { pigs << "rzr" }
    10.times { pigs << "trt" }
    4.times  { pigs << "snt" }
    1.times  { pigs << "jow" }
    pigs
  end

  def lock_round_score
    @game_score += @round_score if @round_score > 0
    @round_score = 0
    @can_roll = true
  end
  
  def roll
    @rolled_pigs = []
    2.times { @rolled_pigs << pigs.sample }
    @roll_score = 0
  end

  def take_turn
    roll
    score
    update_round_score
    @can_roll = can_roll_again?
    @rolled_pigs
  end

  def can_roll_again?
    @round_score > 0
  end

  def update_round_score
    if @roll_score > 0
      @round_score += @roll_score
    else
      @round_score = 0
    end
  end

  def score
    combos = GameData::COMBOS
    single = GameData::SINGLE
    if @rolled_pigs.uniq.count == 1
      @roll_score += combos[@rolled_pigs[0]]
    else
      @roll_score += single[@rolled_pigs[0]]
      @roll_score += single[@rolled_pigs[1]]
    end
    if @roll_score == 2
      @roll_score = 0
    end
  end
end

class Computer < Player
  def initialize
    @name = GameData::COMPUTER_NAMES.sample
    super(@name)
  end

  def will_wager?(high_score)
    if high_score > self.game_score + 70
      self.round_score < 30 ? true : false
    elsif high_score > self.game_score + 50
      self.round_score < 20 ? true : false
    elsif high_score > self.game_score + 40
      self.round_score < 15 ? true : false
    elsif high_score > self.game_score + 30
      self.round_score < 10 ? true : false
    elsif high_score > self.game_score + 20
      self.round_score < 8 ? true : false
    elsif high_score > self.game_score + 10
      self.round_score < 5 ? true : false 
    elsif self.round_score < 5
      true
    end
  end
end
