import random
import sys

# STEP 1: Starting Information
print('Welcome to rock paper scissors!')
moves: dict = {'rock': '🪨', 'paper': '📃', 'scissors': '✂️'}
validMoves: list[str] = list(moves.keys()) # takes the keys from the dictionary and creates a list

while True:
    userMove: str = input('Please enter a move(or enter "q" or "quit" to exit): ').lower()

    if userMove == 'quit' or userMove == 'q' or userMove == 'exit':
        break

    if userMove not in validMoves:
        print('Invalid move. Please enter a valid move.')
        continue

    aiMove: str = random.choice(list(moves.keys()))

    print(f'You chose {moves[userMove]}')
    print(f'Computer chose {moves[aiMove]}')
    print('---------')

    #check moves
    if userMove == aiMove:
        print('It is a tie!')
    elif userMove == 'rock' and aiMove == 'paper':
        print('You lose🚩!')
    elif userMove == 'scissors' and aiMove == 'rock':
        print('You lose🚩!')
    elif userMove == 'paper' and aiMove == 'scissors':
        print('You lose🚩!')
    else: print('You win🟢!')