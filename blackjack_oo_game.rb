# Object-Oriented BlackJack Game

class Card
  attr_accessor :suit, :value
  def initialize(s, v)
    @suit = s
    @value = v
  end 

  def actual_suit
    case suit 
      when 'C' then 'Clubs'
      when 'S' then 'Spades'
      when 'H' then 'Hearts'
      when 'D' then 'Diamnds'
    end 
  end  

  def print_card
    "#{value} of #{actual_suit}"
  end

  def to_s
    print_card
  end 
end 

class Deck
  attr_accessor :cards
  def initialize 
    @cards = []
    ['C', 'D' ,'H', 'S'].each do |suit|
      ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'Q', 'J', 'K', 'A'].each do |value|
        @cards << Card.new(suit, value)
      end 
    end 
    scramble
  end 

  def scramble
    cards.shuffle!
  end 

  def deal_card
    cards.pop
  end 
end 

module Hand 
   def show_flop
    show_hand
  end 

  def total 
    face_value = cards.map{|card| card.value}
    total = 0
    face_value.each do |val|
      if val == 'A'
        total += 11
      elsif val.to_i == 0
        total += 10
      else 
        total += val.to_i
      end 
    end
    # Correcting for Aces
    face_value.select{ |val| val == 'A'}.count.times do 
      break if total <= BlackJack::BLACKJACK_AMOUNT
      total -= 10
      end 
    total 
  end

  def add_card(new_card)
    cards << new_card
  end 

  def is_busted?
    total > BlackJack::BLACKJACK_AMOUNT
  end 
end 

class Player
  include Hand
  attr_accessor :name, :cards
  def initialize(n)
    @name = n
    @cards = []
  end

  def show_hand
    puts "* * * * #{name}'s hand * * * * "
    cards.each do |card|
      puts "=> #{card}"
    end 
    puts "Total is: #{total}"
  end 
end 

class Dealer
  include Hand
  attr_accessor :name, :cards
  def initialize
    @name = "Dealer"
    @cards = []
  end 

  def show_hand
    puts "* * * * Dealer's hand * * * * "
    puts "First card is hidden."
    puts "Second card: => #{cards[1]}"
  end 
end 

# Game Engine 

class BlackJack
  attr_accessor :deck, :player, :dealer
  BLACKJACK_AMOUNT = 21
  DEALER_STAY_MIN = 17

  def initialize
    @player = Player.new("player")
    @deck = Deck.new
    @dealer = Dealer.new
  end 

  def set_player_name
    puts "What is your name?"
    player.name = gets.chomp.capitalize
  end 

  def dealcards
    player.add_card(deck.deal_card)
    dealer.add_card(deck.deal_card)
    player.add_card(deck.deal_card)
    dealer.add_card(deck.deal_card)
  end 

  def show_slop
    player.show_hand
    dealer.show_hand
  end 

  def check_winner(party)
    if party.total == BLACKJACK_AMOUNT
      if party.is_a?(Player)
        puts "Congratulations! #{player.name} hit BlackJack. #{player.name} wins."
      else
        puts "Sorry, Dealer hit BlackJack. #{player.name} loses."
      end 
      play_again?
    elsif party.total > BLACKJACK_AMOUNT
      if party.is_a?(Player)
        puts "Sorry. #{player.name} busted. #{player.name} loses."
      else 
        puts "Congratulations. Dealer busted. #{player.name} wins."
      end 
       play_again?
    end 
  end
  
  def player_turn
    puts "It's #{player.name}'s turn."
    check_winner(player)
    while !player.is_busted?
      puts "Enter 1) to hit or 2) to stay."
      answer = gets.chomp
      if !['1', '2'].include?(answer)
        puts "Error: You must enter 1 or 2."
        next
      end 
      if answer == '2'
        puts "#{player.name} chose to stay at #{player.total}."
        break
      end 

      # hit
      new_card = deck.deal_card
      puts "Dealing card to #{player.name}: #{new_card}"
      player.add_card(new_card)
      puts "#{player.name}'s new total: #{player.total}"
      check_winner(player)
    end
  end 

  def dealer_turn
    puts "It's Dealer's turn."
    check_winner(dealer)
    while dealer.total < DEALER_STAY_MIN
      new_card = deck.deal_card
      puts "Dealing card to Dealer: #{new_card}"
      dealer.add_card(new_card)
      puts "Dealer's new total is: #{dealer.total}"
      check_winner(dealer)
    end 
    puts "Dealer stays at: #{dealer.total}"
  end 

  def who_won?
    if player.total > dealer.total
      puts "Congratulations. #{player.total} wins."
    elsif player.total < dealer.total
      puts "Sorry. Dealer wins."
    else 
      puts "It's a tie."
    end 
    play_again?
  end

  def play_again?
    puts "Would like to play again? 1) yes 2) no"
    response = gets.chomp
    if response == '1'
      puts "Starting new game ..."
      deck = Deck.new
      player.cards = []
      dealer.cards = []
      start
    else 
      puts "Thank you and Goodbye!"
      exit
    end
  end

  def start
    set_player_name
    dealcards
    show_slop
    player_turn 
    dealer_turn
    who_won?
    play_again?
  end 
end 

game = BlackJack.new
game.start