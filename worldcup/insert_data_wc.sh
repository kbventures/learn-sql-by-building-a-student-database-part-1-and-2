#! /bin/bash

# docker-compose up -d
# docker-compose exec student_postgresql psql -U kmb fcc-student-db-2
# docker-compose exec student_postgresql bash

PSQL="psql --username=kmb --dbname=worldcup -t --noalign -c"

#Truncate tables 
echo $($PSQL "TRUNCATE teams, games")

#Reset sequences

$PSQL "SELECT setval('games_game_id_seq',1,false)"
$PSQL "SELECT setval('teams_team_id_seq',1,false)"

# Skip the first line (header) of games.csv
# year,round,winner,opponent,winner_goals,opponent_goals

cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS; do
  if [[ $YEAR != "year" ]]; then
    # get team_id for winner and opponent
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # if winner or opponent not found
    if [[ -z $WINNER_ID ]]; then
      # insert winner name
      INSERT_WINNER_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      
      if [[ $INSERT_WINNER_TEAM == "INSERT 0 1" ]]; then
        echo "Inserted into teams, $WINNER"
        # get new team_id
        TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
        echo "New team ID: $TEAM_ID"
      fi
    fi

    if [[ -z $OPPONENT_ID ]]; then
      # insert opponent name
      INSERT_OPPONENT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      
      if [[ $INSERT_OPPONENT_TEAM == "INSERT 0 1" ]]; then
        echo "Inserted into teams, $OPPONENT"
        # get new team_id
        TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
        echo "New team ID: $TEAM_ID"
      fi
    fi
  fi
done