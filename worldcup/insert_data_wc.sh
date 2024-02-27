#! /bin/bash

PSQL="psql --username=kmb --dbname=worldcup -t --noalign -c"

#Truncate tables 
echo $($PSQL "TRUNCATE teams, games")

#Reset sequences

$PSQL "SELECT setval('games_game_id_seq',1,false)"
$PSQL "SELECT setval('teams_team_id_seq',1,false)"

# Skip the first line (header) of games.csv
# year,round,winner,opponent,winner_goals,opponent_goals

cat games.csv | while IFS=',' read year, round, winner, opponent, winner

# - When you run your `insert_data.sh` script, it should add each unique team to the `teams` table. There should be 24 rows
# Check if the winner or opponent name already exist as a team in the teams table and add them if they don't exist



do
  if [[ $YEAR != year ]]; then
    # get major_id
    MAJOR_ID=$($PSQL "SELECT major_id FROM majors WHERE major='$MAJOR'")

    # if not found
    if [[ -z $MAJOR_ID ]]; then
      # insert major
      INSERT_MAJOR_RESULT=$($PSQL "INSERT INTO majors(major) VALUES('$MAJOR')")
      
      if [[ $INSERT_MAJOR_RESULT == "INSERT 0 1" ]]; then
        echo "Inserted into majors, $MAJOR"
        # get new major_id
        MAJOR_ID=$($PSQL "SELECT major_id FROM majors WHERE major='$MAJOR'")
        echo $MAJOR_ID
      fi
    fi

    # get course_id
    COURSE_ID=$($PSQL "SELECT course_id from courses WHERE course='$COURSE'")
    
    # if not found
    if [[ -z $COURSE_ID ]]; then
      # insert course
      INSERT_COURSE_RESULT=$($PSQL "INSERT INTO courses(course) VALUES ('$COURSE')")
      if [[ $INSERT_COURSE_RESULT == "INSERT 0 1" ]]; then
        echo "Inserted into courses, $COURSE"
      fi
      # get new course_id
      COURSE_ID=$($PSQL "SELECT course_id from courses WHERE course='$COURSE'")
      # insert into majors_courses
      INSERT_MAJOR_COURSES_RESULT=$($PSQL "INSERT INTO majors_courses(major_id, course_id) VALUES($MAJOR_ID, $COURSE_ID)")
      if [[ $INSERT_MAJOR_COURSES_RESULT == "INSERT 0 1" ]]; then
        echo "Inserted into majors_courses, $MAJOR : $COURSE"
      fi
    fi
  fi
done


# Students
cat students.csv | while IFS="," read FIRST LAST MAJOR GPA; do
  if [[ $FIRST != "first_name" ]]; then
    # get major_id
    MAJOR_ID=$($PSQL "SELECT major_id FROM majors WHERE major='$MAJOR'")
    
    # if not found, set to null
    if [[ -z $MAJOR_ID ]]; then
      MAJOR_ID=null
    fi

    # if GPA is empty, set to null
    if [[ -z $GPA ]]; then
      GPA=null
    fi
    
    # insert student
    INSERT_STUDENT_RESULT=$($PSQL "INSERT INTO students(first_name, last_name, major_id, gpa) VALUES('$FIRST', '$LAST', $MAJOR_ID, $GPA::numeric(2,1))")
    
    # check if the insertion was successful
    if [[ $INSERT_STUDENT_RESULT == "INSERT 0 1" ]]; then
      echo "Inserted into students, $FIRST $LAST"
    elif [[ $INSERT_STUDENT_RESULT == *"ERROR"* ]]; then
      echo "Error inserting student: $FIRST $LAST"
      # Handle the error appropriately
    fi
  fi
done