#!/bin/bash
# Script to insert data from courses.csv and students.csv into students database

# PSQL variable for database interaction
PSQL="psql -X --username=kmb --dbname=students --no-align --tuples-only -c"

# Truncate tables
echo $($PSQL "TRUNCATE students, majors, courses, majors_courses")

# Reset sequences
$PSQL "SELECT setval('students_student_id_seq', 1, false)"
$PSQL "SELECT setval('majors_major_id_seq', 1, false)"
$PSQL "SELECT setval('courses_course_id_seq', 1, false)"
$PSQL "SELECT setval('majors_courses_id_seq', 1, false)"

# Skip the first line (header) of courses.csv
cat courses.csv | while IFS="," read MAJOR COURSE
do
  if [[ $MAJOR != major ]]; then
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
# do
#   if [[ $MAJOR != major ]]; then
#     # get major_id
#     MAJOR_ID=$($PSQL "SELECT major_id FROM majors WHERE major='$MAJOR'")

#     # if not found
#     if [[ -z $MAJOR_ID ]]; then
#       # insert major
#       INSERT_MAJOR_RESULT=$($PSQL "INSERT INTO majors(major) VALUES('$MAJOR')")
      
#       if [[ $INSERT_MAJOR_RESULT == "INSERT 0 1" ]]; then
#         echo "Inserted into majors, $MAJOR"
#         # get new major_id
#         MAJOR_ID=$($PSQL "SELECT major_id FROM majors WHERE major='$MAJOR'")
#         echo $MAJOR_ID
#       fi
#     fi

#     # get course_id
#     COURSE_ID=$($PSQL "SELECT course_id from courses WHERE course='$COURSE'")
    
#     # if not found
#     if [[ -z $COURSE_ID ]]; then
#       # insert course
#       INSERT_COURSE_RESULT=$($PSQL "INSERT INTO courses(course) VALUES ('$COURSE')")
#       if [[ $INSERT_COURSE_RESULT == "INSERT 0 1" ]]; then
#         echo "Inserted into courses, $COURSE"
#       fi
#       # get new course_id
#       COURSE_ID=$($PSQL "SELECT course_id from courses WHERE course='$COURSE'")
#       # insert into majors_courses
#       INSERT_MAJOR_COURSES_RESULT=$($PSQL "INSERT INTO majors_courses(major_id, course_id) VALUES($MAJOR_ID, $COURSE_ID)")
#       if [[ $INSERT_MAJOR_COURSES_RESULT == "INSERT 0 1" ]]; then
#         echo "Inserted into majors_courses, $MAJOR : $COURSE"
#       fi
#     fi
#   fi
# done



# #!/bin/bash
# # Script to insert data from courses.csv and students.csv into students database

# # PSQL variable for database interaction
# PSQL="psql -X --username=kmb --dbname=students --no-align --tuples-only -c"

# # Skip the first line (header) of courses.csv
# tail -n +2 courses.csv | while IFS="," read MAJOR COURSE
# do
#   # Insert the major into the majors table
#   $PSQL "INSERT INTO majors(major) VALUES('$MAJOR');"
  
#   # Insert the course into the courses table
#   $PSQL "INSERT INTO courses(course) VALUES('$COURSE');"
  
#   # Print the major and course
#   echo "$MAJOR $COURSE"
# done