#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

cat games.csv | while IFS="," read YEAR ROUND WIN OPN WIN_GLS OPN_GLS
do
    if [[ $WIN != "winner" ]]
    then
        # get team_id from winner
        TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WIN'")

        # if not found
        if [[ -z $TEAM_ID ]]
        then
            # insert team
            INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WIN')")
            # echo $INSERT_TEAM_RESULT
            if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
            then
                echo "Inserted into teams, $WIN"
            fi

            # get new team_id
            TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WIN'")
        fi

        # get team_id from opponent
        TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPN'")

        # if not found
        if [[ -z $TEAM_ID ]]
        then
            # insert team
            INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPN')")
            # echo $INSERT_TEAM_RESULT
            if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
            then
                echo "Inserted into teams, $OPN"
            fi

            # get new team_id
            TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPN'")
        fi

        # get winner_id
        WIN_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WIN'")

        # get opponent_id
        OPN_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPN'")

        # insert into games
        INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WIN_ID, $OPN_ID, $WIN_GLS, $OPN_GLS)")
        if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
        then
            echo "Inserted into games, $YEAR $ROUND $WIN_ID : $OPN_ID : $WIN_GLS : $OPN_GLS"
        fi

    fi
done
