# hearts-card-game-AI
A simple AI that plays a [Hearts Card Game](https://en.wikipedia.org/wiki/Hearts_(card_game)) built using Haskell implementing various functional coding patterns.

## Instructions
AI code is located in [Player.hs](/staticgame/Player.hs). To test the game with 4 instances of the AI run:
```
stack test
```

To run a single instance of the game with results printed onto the terminal run:
```
stack run
```
## Explanation of Approach 
### General Strategy
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

### Use of memory
Memory is used to check if it its the first trick and furthermore to check if hearts have been broken.

### Coding/ FP Methodology
* Effort has been taken to reduce imperative code. Instead, when choices have to be made (like for heuristics), the functions filters out the invalid and the 
unoptimal cards, order them so that the optimal card are at the first index and uses simple head function to return the card choice.
* All sorting algorithms make use of set theory. Using union and complement and difference of set in order to sort the elements
* Set difference, complement.. are also used in place of filters when cards of multiple suits need to be filtered out
* When needed, card lists such as point cards and ordered list of cards are generated using functors and applicatives
* Memory is handled using a simple monad
* Where possible, a point free style is used, though effort has been made to ensure that it is not to the detriment of readability. Hence there are a few 
locations where the brackets are used instead

## Acknowledgement
This implementation of the game is done by [Prof. Tim Dwyer](https://ialab.it.monash.edu/~dwyer/) for purpose of the unit FIT2102 Programming Paradigms.
