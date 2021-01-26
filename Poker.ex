defmodule Poker do

def deal(list) do
#Holding array(list) for initial cards
hnd_1 = [0,2]
hnd_2 = [1,3]
shrd_pl = [4,5,6,7,8]
#Filled array with cards
hnd_flld_1 = give_out(list,hnd_1)
hnd_flld_2 = give_out(list,hnd_2)
shrd_pl_flld = give_out(list,shrd_pl)
#combines 2 hand cards with 5 river cards
hand_1 = hnd_flld_1 ++ shrd_pl_flld
hand_2 = hnd_flld_2 ++ shrd_pl_flld
#Changed into strings
#The winning hand is picked based on points
win = compare_hands(hand_1,hand_2)
#The hand is made printable
str_win = String.split(win, " ")
winner_hand = Enum.reverse(str_win)
winner_hand
end

#Gives out the hands
defp give_out(list,i), do: Enum.map(i, &(Enum.at(list, &1)))
#Gets the points of the hand
defp get_points(hand), do: elem(hand_results(hand),0)
#Gets the cards of the hand
defp get_cards(hand), do: elem(hand_results(hand),1)
#Compares the values of hands
defp format_cards(hand), do: hand_to_string(change_hand(get_cards(hand)))
#Get the winning hand
defp compare_hands(hand1, hand2) do
  points = get_points(hand1) - get_points(hand2)
    cond do
      points > 0  -> format_cards(Enum.sort(hand1))
      points == 0 -> compare_suits(get_cards(hand1), get_cards(hand2))
      points < 0  -> format_cards(Enum.sort(hand2))
    end
end
#Used to tranform each card into suit specific
def get_suit(card) do
  cond do
    card <= 13 -> "C"
    card <= 26 -> "D"
    card <= 39 -> "H"
    card <= 52 -> "S"
  end
end

#Used to get the proper value and make into a string
def get_value(card) do
  cond do
    card <= 13 -> Integer.to_string(card)
    card <= 26 -> Integer.to_string(card-13)
    card <= 39 -> Integer.to_string(card-26)
    card <= 52 -> Integer.to_string(card-39)
  end
end

#Changes the hole hand
def change_hand(hand) do
  Enum.map(hand, fn x -> get_value(x)<>get_suit(x) end)
end

#Using atoms for quicker checking
def atom_hand(cards) do
  tranform = %{1 => {:A,:c}, 2 => {2,:c}, 3 => {3,:c}, 4 => {4,:c}, 5 => {5,:c},
  6 => {6,:c},7 => {7,:c},8 => {8,:c},9 => {9,:c},10 => {:T,:c},11 => {:J,:c},
  12 => {:Q,:c},13 => {:K,:c}, 14 =>{:A,:d}, 15=>{2,:d}, 16=>{3,:d}, 17=>{4,:d}, 18=>{5,:d},
  19=>{6,:d},20=>{7,:d},21=>{8,:d},22=>{9,:d},23=>{:T,:d},24=>{:J,:d},25=>{:Q,:d},26=>{:K,:d},
  27=> {:A,:h},28=>{2,:h}, 29=>{3,:h}, 30=>{4,:h},31=>{5,:h},32=>{6,:h},33=>{7,:h},
  34=>{8,:h},35=>{9,:h},36=>{:T,:h},37=>{:J,:h},38=>{:Q,:h},39=>{:K,:h},40 =>{:A,:s},
  41=>{2,:s},42=>{3,:s}, 43=>{4,:s}, 44=>{5,:s},45=>{6,:s},46=>{7,:s},47=>{8,:s},
  48=>{9,:h},49=>{:T,:h},50=>{:J,:s},51=>{:Q,:s},52=>{:K,:s}}
  Enum.map(cards, fn x -> tranform[x] end)
end

#Making it into a string
def hand_to_string(small), do: Enum.reduce(small, fn(x, acc) -> x <> " " <> acc end)
#If the hands are identical used to pointify the suit
def suit_value({{_,a},  {_,b},  {_,c},  {_,d},  {_,e}}) do
   pts(a) + pts(b)+ pts(c) + pts(d) + pts(e)
 end
    #Used to get the winning hand if the outcome is the same for rank
    defp compare_suits(hand1, hand2) do
      points = suit_value(sort_hand(atom_hand(hand1))) - suit_value(sort_hand(atom_hand(hand2)))
      cond do
       points > 0  -> hand_to_string(change_hand(hand1))
       points == 0 -> hand_to_string(change_hand(hand1))
       points < 0  -> hand_to_string(change_hand(hand2))
     end
    end

    #Check the hand rank
    defp poker_rank(hand) do
      #Check if it's straight
      if straight(hand) do
        straight_v_flush(hand)
      else
        combo_hands(hand)
      end
    end
    #Four of a kind
    defp combo_hands({{a,_},  {a,_},  {a,_},  {a,_},  {b,_}}), do: pts(b) + 700
    #Full House
    defp combo_hands({{a,_},  {a,_},  {a,_},  {b,_},  {b,_}}), do: 1.5 * pts(a) + pts(b) + 600
    #Full House
    defp combo_hands({{a,_},  {a,_},  {b,_},  {b,_},  {b,_}}), do: 1.5 * pts(b) + pts(a) + 600
    #Flush
    defp combo_hands({{a,x}, {b,x}, {c,x}, {d,x}, {e,x}}), do: pts(a) + pts(b) + pts(c) + pts(d) + pts(e) + 500
    #Three of a kind
    defp combo_hands({{a,_},  {a,_},  {a,_},  {b,_},  {c,_}}), do: 1.5 * pts(a) + pts(b) + pts(c) + 300
    #Two pair
    defp combo_hands({{a,_},  {a,_},  {b,_},  {b,_},  {c,_}}), do: 1.5 * pts(a) + 1.5 * pts(b) + pts(c) + 200
    #One pair
    defp combo_hands({{a,_},  {a,_},  {b,_},  {c,_},  {d,_}}), do: 1.5 * pts(a) + pts(b) + pts(c) + pts(d) + 100
    #High Card
    defp combo_hands({{a,_},  {b,_},  {c,_},  {d,_},  {e,_}}), do: pts(a) + pts(b) + pts(c) + pts(d) + pts(e)
    #Straight and Flush
    defp straight_v_flush(hand) do
      {{a,_}, {b,_}, _, _, _} = hand
      i = if a == :A && b == 5 do
          5
        else
          a
        end
      if flush(hand) do
        pts(i) + 800
      else
      pts(i) + 400
      end
    end
    #Check if the hand is straigt
    def straight(hand) do
      {{a,_}, {b,_}, {c,_}, {d,_}, {e,_}} = hand
       (pts(a) == pts(b) + 1 || a == :A && b == 5) &&
        pts(b) == pts(c) + 1 &&
        pts(c) == pts(d) + 1 &&
        pts(d) == pts(e) + 1
    end
    #Checks if the hand is a flush
    defp flush(hand) do
      case hand do
        {{_,a},{_,a},{_,a},{_,a},{_,a}} -> true
        {_,_,_,_,_} -> false
      end
    end
#Gets the value of each card
defp pts(:A), do: 14
defp pts(:K), do: 13
defp pts(:Q), do: 12
defp pts(:J), do: 11
defp pts(:T), do: 10
defp pts(:s), do: 4
defp pts(:h), do: 3
defp pts(:d), do: 2
defp pts(:c), do: 1
defp pts(i) when is_integer(i) and i >= 2 and i <= 9, do: i
#Sort the hand
def sort_hand(list) do
list
|> Enum.sort_by(fn {face,_} -> pts(face) end)
|> Enum.reverse
|> List.to_tuple
end
#Use the functions to get the points of the hand
def hand_evaluator(cards) do
    cards
    |> atom_hand
    |> sort_hand
    |> poker_rank
  end
#Evaluate the hands and get the highest one
def hand_results(hand) do
    hand
      |> combinations(5)
      |> Stream.map(&{hand_evaluator(&1), &1})
      |> Enum.max
  end
#Get all the combinations of cards
def combinations(_, 0), do: [[]]
def combinations([], _), do: []
def combinations([x|xs], n) do
  (for y <- combinations(xs, n - 1), do: [x|y]) ++ combinations(xs, n)
  end
end
