{-
Student ID : 29458021
FIT 2102 Assignment 2
# Organization of file
* Simple functions are all listed before composite function to ensure that the reader is familiar with the building blocks of later functions
* Where possible, functions are grouped according to use cases/function
## Simple Table of Contents:
  1. Basic Functions
  2. Function to generate list of cards.
  3. Function to sort cards 
  4. Memory functions
  5. Breaking heart functions
  6. Master playCard Function
  7. Main strategy functions

# General Strategy
Generally, the goal in this game is to get the least number of point cards. However, if the opppotunity arises, the goal is then to shoot the moon.
Thus, to futher the first end, the strategy is to minimize the chances of getting point cards. 

First, at the start of the game, if we are not leading, we try to throw the largest card. This is because other are unlikely to be able to throw away 
point cards.

This is done by first ducking- that is to throw a card that is right below the highest card in the trick. Thus, other players cannot force us to take 
point card. This is slighly more useful in 4 player games

The next bit of strategy comes when there is a void, that is, the hand does not contain any of one suit. This is extemely advantages. Here, 
  * when the hearts are broken:
  the ai will try to throw the highest point card thus lowering the chance that it will take it later
  * when the hearts are not broken, the ai will try to throw the largest non point card. Again, lowering the chance that it will later be forced to play
  it and taking a trick

The final bit of strategy occurs when the player is leading. Here, the player will try to throw the lowest point cards so that the other player cannot 
force the ai to take a point card. However, if the player only has point cards, then the player will constantly throw the largest card. Thus this 
rather simple player is also capable of trying to shoot the moon.

IN Conclusion- the strategy consist of trying to minimize risk and but to capitalize on oppotunities if it presents itself.

# Use of memory
Memory is used to check if it its the first trick and furthermore to check if hearts have been broken.

# Coding/ FP Methodology
* Effort has been taken to reduce imperative code. Instead, when choices have to be made (like for heuristics), the functions filters out the invalid and the 
unoptimal cards, order them so that the optimal card are at the first index and uses simple head function to return the card choice.
* All sorting algorithms make use of set theory. Using union and complement and difference of set in order to sort the elements
* Set difference, complement.. are also used in place of filters when cards of multiple suits need to be filtered out
* When needed, card lists such as point cards and ordered list of cards are generated using functors and applicatives
* Memory is handled using a simple monad
* Where possible, a point free style is used, though effort has been made to ensure that it is not to the detriment of readability. Hence there are a few 
locations where the brackets are used instead
-}
module Player (
    playCard,
    makeBid
)
where

import Hearts.Types
import Cards
import Data.Maybe
import Data.List

{- 
Basic Functions
-}

-- Function to get the suit of the card
-- Input : the Card
-- Output the suit of the card

gSuit :: Card -> Suit
gSuit (Card suit _) = suit

-- Function to get lead Suit
-- Input : 
-- Output:
leadSuit :: [(Card, String)] -> Suit
leadSuit currentTrick = gSuit $ last $ removeIds currentTrick

-- Function to remove ids from a list of cards and strings
-- Input : List of cards and strings
-- Output: List of cards
-- Uses : Mainly to return a easily processable list from the trick list given to us. Thus, lead suit, largerst card and more can be easily obtained. 
-- Also used to strip the ids from the memory of the last trick before converting it to a string.
removeIds :: [(Card, String)] -> [Card]
removeIds trick = map (\x -> fst x) trick


-- Function to filter hand by suit
-- A very common pattern, hence why it is abstracted
bySuit :: [Card] -> Suit -> [Card]
bySuit cardList suit = filter (\x -> gSuit x == suit) cardList


-- Function to return Cards that are less than card
-- A very common pattern, hence why it is abstracted
lessThan :: [Card] -> Card -> [Card]
lessThan cardList card = filter (\x -> x < card) cardList

-- Function to find a particular card
-- Input : List of cards
-- Output: Maybe Card
-- Used mainly in lead, where the AI is unaware if it is the start of the game, hence, a maybe data is very useful here as it can express that ambiguity
-- in code
findCard :: [Card] -> Card -> Maybe Card
findCard hand card = find (== card) hand

-- function to get the max card of the same suit as current trick
getMaxFromTrick :: [(Card, String)] -> Card
getMaxFromTrick currentTrick = maximum(bySuit (removeIds currentTrick) (leadSuit currentTrick))

{-
Function to generate list of cards.

Applicative are made used of to map Card constructors over multiple lists in order to generate the desired permutation of cards
-}

-- Function to generate all the point cards inclluding the Queen of Spade
allPointCards :: [Card]
allPointCards = (++) [Card Spade Queen] $ pure Card <*> [Heart] <*> [Two ..] 

-- Function to generate a list of all cards
allCards :: [Card]
allCards = pure Card <*> [Spade ..] <*> [Two ..]

-- Functions to generated an ascending list of cards by rank. 
-- getFullCard is needed as the cards need to first accept the rank before accepting the suit
getFullCard :: Rank -> Suit -> Card
getFullCard rank suit = Card suit rank

orderedByRank :: [Card]
orderedByRank = pure getFullCard <*> [Two ..] <*> reverse [Spade ..]

{-
Function to sort cards 

As stated above, all make use of set theory. Using union and complement and difference of set in order to sort the elements. Thus its is easy to 
understand and easy to prove

The intersection of a sorted set and an unsorted set will return a list of sorted values according to the sorted set, but only contains values
from the unsorted set.
-}

-- Simple way ordering card in ascending order from list
-- The intersection of a sorted set and an unsorted set will return a list of sorted values according to the sorted set, but only contains values
-- from the unsorted set.
-- output : Cards sorted according to suit then rank
smartOrderCards :: [Card] -> [Card]
smartOrderCards cardList = intersect allCards cardList


-- Function that uses set theory to card by rank in ascending order
-- rational: sacrifices a little performance for readability and provability
-- functions called 
-- input: list of cards
-- output: cards sorted in ascending order according to rank
reverseOrderCards :: [Card] -> [Card]
reverseOrderCards cardList = intersect orderedByRank cardList


-- Uses set theory to sort card by decending order according to rank 

orderCards :: [Card] -> [Card] 
orderCards cardList =  intersect (reverse orderedByRank) cardList

{-
Memory functions
Contains smaller helper functions and a master updated Memory function.
-}

-- Fuction to update the memory string with data from the recorded last trick
-- a functor is used here to map over the card list
updateMemoryAux :: [Card] -> String -> String
updateMemoryAux [] _ = ""
updateMemoryAux cardList lastMemory = lastMemory ++ " " ++ intercalate " " (show <$> cardList)

-- Function used to return the string ie the memory from the maybe data type
-- a Monad is used in because the different operations must be done to the data depending on whats in the Maybe
getMemoryString :: Maybe([(Card,String)], String) -> String
getMemoryString memory = do 
    case memory of
        Nothing -> ""
        (Just( _, lastMemory)) -> lastMemory

-- Function used to return the last tric from the maybe data type
-- a Monad is used in because the different operations must be done to the data depending on whats in the Maybe
getLastTrick :: Maybe([(Card,String)], String) -> [Card]
getLastTrick memory = do 
    case memory of
        Nothing -> []
        (Just( lastTrick, _)) -> (fst) <$> lastTrick

-- Function to convert memory into a processable list of cards 
convertMemory :: String -> [Card]
convertMemory "" = []
-- words is a function that takes a string with spaces and returns a list of strings That is mapped over using the functor
convertMemory stringMem = (\x -> read x :: Card) <$> (words stringMem)

--Master Updated Memory function that is used to update memory. Makes use of other functions above
updatedMemory :: Maybe([(Card,String)], String) -> String
updatedMemory memory = updateMemoryAux (getLastTrick memory) (getMemoryString memory)




{-
Breaking heart functions
Function that check if the hearts are breaking and introduce a new strategy if they are
-}

-- function that takes in the list of cards that have been played before. Checks if a point card has been played and return a list of cards, of which the head is the optimal card
choiceOfHearts :: [Card] -> [Card] -> [Card]
-- at the point where hearts are not broken, the function the returns the largest cards that are not hearts, starting with the queen of spades. Because this 
-- is only called when there is a void, there is a high chance that the card is going to be taken by the opponent
choiceOfHearts hand []   = filter (\x -> x == Card Spade Queen) hand ++ (orderCards $ (\\) hand allPointCards)
-- when the hearts are broken, this pattern will be matched. Here, the largest heart is returned to ensure that in the late game, one does not take 
-- any more hearts
choiceOfHearts hand  _   = orderCards $ intersect hand allPointCards

-- Function to check if the hearts are broken
brokenHearts :: [Card] -> [Card]
brokenHearts playedCards = filter (\x -> gSuit x == Heart) playedCards

{-
# Master playCard Function
This is the function called by the game to run the AI. Uses Patten matching 

parameters
hand: cards the player can use
currentTrick:cards in the current trick
memory: memory of last trick and all cards played contained in maybe

-}

playCard :: PlayFunc
-- when leading lead function is called wihout memory. The memory is also updated here
playCard _ hand [] memory = (lead hand, updatedMemory memory)
-- when not leading, renege is called. The memory is also updated here
playCard _ hand currentTrick memory = (renege currentTrick hand memoryPlayedCards, updatedMemory memory)
  where
    -- the reason why convertMemory is called on updated memory and not memory is because memory does not contain the last trick
    memoryPlayedCards = convertMemory $ updatedMemory memory


{-
Main strategy functions
General techniques: 

Pattern matching is used to check if its it the first trick. If the memory is empty, then it will return an empty list and thus will cause the function return
the highest possible card.

Within the function, the way heurestics are expressed are in the form of catenated lists. The 'conditions' or the 'strategy are expressed as filter, sort
and search functions. When conditions / strategies are not met, the function then attempts to create the next list.

-}


renege :: [(Card, String)] -> [Card] -> [Card] -> Card
-- when its the first trick 
-- first try to pick the largest possible card as the other side is unlikely to have hearts
-- functions used: 
-- leadSuit: to get the lead suit from current trick              
-- bySuit: filters the cards based on a particular suit                         
renege currentTrick hand [] = head $ ( orderCards $ (bySuit hand $ leadSuit currentTrick )) ++ 
                                      -- pick the largest card that is not a point card
                                     ( orderCards $ (\\) hand allPointCards ) ++
                                      -- pick the Queen of spades, if she exists
                                     ( filter (\x -> x == Card Spade Queen ) hand ) ++
                                      -- pick the largest Point Card
                                     ( orderCards hand )

                            -- find the smallest card of the same suit that is the lead suit
renege currentTrick hand memory = head $ (reverseOrderCards $ lessThan (bySuit hand $ leadSuit currentTrick) $ getMaxFromTrick currentTrick) ++
                            -- find the smallest card of the same suit that is larger than the lead suit
                               (reverseOrderCards $ bySuit hand $ leadSuit currentTrick) ++   

                            -- when the above two lists are empty, is means that we have a void. Here, the function choice Of Heart introduces a special
                            -- strategy -- to try to pick the largest point card if hearts are broken, or if not the get rid of the highest non 
                            -- point card to reduce the chance of taking the trick
                               (choiceOfHearts hand $ brokenHearts memory)  ++
                            -- find smallest card that is not a point card
                                ((\\) hand allPointCards) ++
                            -- find the smallest card that is not a heart
                               ((\\) hand $ bySuit orderedByRank Heart) ++
                            -- find the ordered heart card
                              (smartOrderCards hand) 

-- if you are leading the trick, first calls pickCard with the parameter from *findCard*. When Two of clubs is in your hand, the function knows that its 
-- the first turn and then returns that card. For all other leadds, it tried to get rid of the smallest non point card, the queen of spade and then the 
-- largest point card in that order. This is to minimized the risk of getting point cards. The gambit with the queen of spades and the
-- other point cards is to attept to shoot the moon early if the oppotunity arises, and to prevent the opponent to shoot the moon later on
lead :: [Card] -> Card
lead hand = pickCard hand $ findCard hand $ Card Club Two

--[Card Spade Four, Card Heart Nine]
--(length $ intersect [Card Spade Four, Card Heart Nine] allPointCards) == 0
pickCard :: [Card] -> Maybe Card -> Card
                          -- gets the head from the list of ascending sorted by rank non point cards, if they exist
pickCard hand Nothing  = head $ (reverseOrderCards $ (\\) hand allPointCards) ++ 
                          -- gets Queen of spades if she exists 
                          (filter (\x -> x == Card Spade Queen) hand) ++
                          -- gets the largest heart card, if its exists
                         (reverse $ reverseOrderCards hand)
-- returns the two of clubs when it is the first trick
pickCard _ card = fromJust card




-- | Not used, do not remove.
makeBid :: BidFunc
makeBid = undefined

