require "pry"
module Hand 
  def calculate_total
    card_faces = cards.map {|card| card.face}
    total = 0
    card_faces.each do |value|
      if value == "Ace"
        total += 11
      else
        total += (value.to_i == 0 ? 10 : value.to_i)
      end 
    end
    card_faces.select {|val| val == "Ace"}.count.times do
      break if total <= 21
      total -= 10  
    end
    total
  end
  
  def display_hand
    puts "#{name} has #{cards[0].clean_output} and #{cards[1].clean_output} for a total of #{calculate_total}."
  end 

  def display_add_card
    puts "#{name} has added #{cards.last.clean_output} for a total of #{calculate_total}."
  end

  def show_total
    puts "#{name}'s total is #{calculate_total}."
  end
  
  def add_card(new_card)
    puts "Dealing..."
    cards << new_card
    sleep 1
    puts "------------------------------"
    puts ""
  end
  
  def has_21?
    calculate_total == 21
  end
  
  def bust?
    calculate_total > 21 
  end
end

class Player 
  include Hand
  attr_accessor :bet, :pocket, :name, :cards, :double_down
  def initialize(name)
    @name = name
    @pocket = 1000
    @bet = 0
    @cards = []
    @double_down = false
  end 
    
  def place_bet
    show_pocket
    if pocket > 50
      puts "How much would you like to bet on this hand? (Please enter whole numbers. Minimum bet is 50.)"
      ans = gets.chomp.to_i
      until (ans >= 50) && (ans < pocket)
        puts "Enter a whole number, minimum of 50, maximum of #{pocket}."
        ans = gets.chomp.to_i
      end
      @bet += ans
      @pocket -= ans
      show_bet
      show_pocket
      puts "------------------------------"
      sleep 1
    else
      puts "Go home. Minimum bet is $50. You don't have enough to play."
      exit
    end
  end

  def show_bet
    puts "Your bet is $#{bet}."
  end
  
  def show_pocket
    puts "You currently have $#{pocket} in your pocket."
  end
  
  def surrender?
    puts "Would you like to surrender? (yes/no)"
    ans = gets.chomp.downcase
    case ans
    when "yes" 
      puts "You've surrendered. You lose half your bet."
      @pocket += (0.5 * bet)
      bet = 0
      show_pocket
      true
    when "no" 
      return false
    else 
      puts "I'll take that as a no."
      return false
    end
  end
  
  def double_down?
    if pocket > bet
      puts "Would you like to double down? (yes/no)"
      ans = gets.chomp.downcase
      case ans
      when "yes" 
        puts "You've doubled down."
        @pocket -= bet
        @bet += bet
        show_bet
        show_pocket
        @double_down = true
      when "no" 
        return false
      else 
        puts "I'll take that as a no."
        return false
      end
    else
      return false
    end
  end

def hit_or_stay(deck)
    while calculate_total < 21
      puts "Whaddya wanna do, pal? (hit/stay)"
      ans = gets.chomp.downcase   
      until ['hit', 'stay'].include?(ans)
        puts "You must choose. (hit/stay)"
        ans = gets.chomp.downcase
      end
      if ans == 'stay'
        puts "You chose to stay."
        break
      end
      add_card(deck.deal)
      total = calculate_total
      puts "You chose to hit."
      display_add_card
      break if double_down
    end
  end
  
  def push_msg
    @pocket += bet
    puts "Push!"
    puts "------------------------------"
    puts ""
    sleep 2
    show_pocket
  end
  
  def bust_msg
    puts "Bust!"
    puts "------------------------------"
    puts ""
    sleep 2
    show_pocket
  end

  def win_msg
    puts "#{name}, you won!"
    puts "------------------------------"
    puts ""
    sleep 2
    @pocket += (2 * bet)
    show_pocket
  end

  def blackjack_msg
    puts "#{name}, you have blackjack!"
    puts "------------------------------"
    puts ""
    sleep 2
    @pocket += (2.5 * bet)
    show_pocket
  end
end

class Dealer
  include Hand
  attr_accessor :cards, :name
  def initialize(name)
    @cards = []
    @name = name
  end
  
  def hit_or_stay(deck)
    while calculate_total < 17
    puts "Dealer hits."
    add_card(deck.deal)
    total = calculate_total
    display_add_card
    end 
  end

  def reveal_downcard
    puts "#{name}'s downcard is #{cards[0].clean_output}."
  end

  def show_upcard
    puts "#{name}'s upcard is #{cards[1].clean_output}."
  end
end

class Deck
  SUIT = ['Clubs', 'Hearts', 'Diamonds', 'Spades']
  FACE = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace']
  attr_accessor :cards
  def initialize(number_of_decks)
    @cards = []
    SUIT.each do |suit|
      FACE.each do |face|
        number_of_decks.times do 
          cards << Card.new(face, suit)
        end
      end
    end
    cards.shuffle!
  end
  
  def deal
    cards.pop
  end
end

class Card
  attr_reader :suit, :face
  
  def initialize (face, suit)
    @suit = suit
    @face = face
  end
  
  def clean_output
    "#{face} of #{suit}"
  end
  
  def to_s
    clean_output
  end
end

class Game
  attr_accessor :game_deck
  def initialize
    @dealer = Dealer.new("Dealer")
  end
  
  def welcome
    if @player == nil
      puts "Well, hello there! What's your name, kid?"
      ans = gets.chomp
      ans = "Player" if ans.empty? 
      @player = Player.new(ans)
    else
      puts ""
      puts "------------------------------"
      puts "Another round, I see."
    end
  end
  
  def greet
    puts "Alrighty, #{@player.name}, let's start a game of BlackJack."
    puts "------------------------------"
    sleep 1
  end
  
  def get_decks
    decks = 1
    puts "How many decks you want in the shoe, #{@player.name}? (1-8)"
    decks = gets.chomp.to_i
    until (1..8).include?(decks)
      puts "C'mon, man. Choose. How many decks? (1-8)"
      decks = gets.chomp.to_i
    end 
    puts "Okay, let's play!"
    decks
  end

  def deal_initial_hand
    2.times do 
      @dealer.add_card(@game_deck.deal)
      @player.add_card(@game_deck.deal)
    end
  end
  
  def player_turn
    if @player.has_21?
      @dealer.reveal_downcard
      if push?
        @player.push_msg
      else
        @player.blackjack_msg        
      end
      ask_play_again
    end        
    if @player.bust?
      @player.bust_msg
      ask_play_again
    end
    if @player.surrender?
      ask_play_again
    end
    @player.double_down?
    @player.hit_or_stay(@game_deck)
    if @player.bust?
      @player.bust_msg
      ask_play_again
    end
  end

  def dealer_turn
    @dealer.reveal_downcard
    if @dealer.has_21?
      puts "Dealer has blackjack!"
      @player.bust_msg
      ask_play_again
    end
    if @dealer.bust?
      @player.win_msg
      ask_play_again
    end
    @dealer.hit_or_stay(@game_deck)
    if @dealer.bust?
      @player.win_msg
      ask_play_again
    end
  end

  def push?
    @player.calculate_total == @dealer.calculate_total
  end

  def player_total_higher?
    @player.calculate_total > @dealer.calculate_total
  end

  def dealer_total_higher?
    @player.calculate_total < @dealer.calculate_total
  end

  def ask_play_again
    if @player.pocket > 50
      puts "Would you like to play again, #{@player.name}? (yes/no)"
      ans = gets.chomp.downcase
      if ans == "yes"
        @player.cards = []
        @player.bet = 0
        @dealer.cards = []
        play
      else
        exit
      end
    else 
      puts "Go home. Minimum bet is $50. You don't have enough to play."
      exit
    end
  end
  
  def compare_hands
    puts "------------------------------"
    puts ""
    sleep 2
    @player.show_total
    @dealer.show_total
    if push? 
      @player.push_msg
    elsif @dealer.has_21?
      @player.bust_msg
    elsif dealer_total_higher?
      @player.bust_msg
    elsif player_total_higher? 
      @player.win_msg
    end
  end
    
  def play
    welcome
    greet
    @player.place_bet
    @game_deck = Deck.new(get_decks)
    deal_initial_hand
    @player.display_hand
    @dealer.show_upcard
    player_turn
    dealer_turn
    compare_hands
    ask_play_again    
  end
end

Game.new.play