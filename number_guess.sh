#!/bin/bash
# PSQL variable declaration to query database
PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

# Welcome message and username prompt
echo -e "\n~~~~~ Number guessing game ~~~~~\n"
echo -e "\nEnter your username:"
read USER_NAME

# Get stats for USER_NAME
USER_STATS=$($PSQL "SELECT user_id, name, COUNT(*) AS games_played, MIN(guesses) FROM users LEFT JOIN games USING(user_id) WHERE name='$USER_NAME' GROUP BY user_id;")

# Test if USER_STATS exists (or user existes)
if [[ $USER_STATS ]]
then
  # If USER_STATS print the stats and proceed
  echo $USER_STATS | while read USER_ID BAR USERNAME BAR GAMES_PLAYED BAR BEST_GAME
  do
    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.\n"
  done
else
  # If not USER_STATS create new user and proceed
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(name) VALUES('$USER_NAME')")
  echo -e "\nWelcome, $USER_NAME! It looks like this is your first time here.\n"
fi

# Variable init for guessing game
USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USER_NAME'") 
SECRET_NUMBER=$(( RANDOM % 1000 + 1))
NUMBER_OF_GUESSES=0

# Ask user for number and count +1 to guesses
echo -e "\nGuess the secret number between 1 and 1000:"
read USER_NUMBER
(( NUMBER_OF_GUESSES++ ))

# Function to check if user entered a number
CHECK_IS_NUMBER () {
  until [[ $USER_NUMBER =~ ^[0-9]+$ ]]
  do
    echo -e "\nThat is not an integer, guess again:"
    read USER_NUMBER
    (( NUMBER_OF_GUESSES++ ))
  done
}
CHECK_IS_NUMBER

# Run until the user get the secret number then proceed
until [[ $USER_NUMBER -eq $SECRET_NUMBER ]]
do
  if [[ $USER_NUMBER -gt $SECRET_NUMBER ]]
  then
    echo -e "\nIt's lower than that, guess again:"
    read USER_NUMBER
    (( NUMBER_OF_GUESSES++ ))
    CHECK_IS_NUMBER
  elif [[ $USER_NUMBER -lt $SECRET_NUMBER ]]
  then
    echo -e "\nIt's higher than that, guess again:"
    read USER_NUMBER
    (( NUMBER_OF_GUESSES++ ))
    CHECK_IS_NUMBER
  fi
done

# Once the user guesses the right number, insert the game stats into data base and print
ADD_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)")
echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
