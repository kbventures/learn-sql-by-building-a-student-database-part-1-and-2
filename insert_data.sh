 #!/bin/bash

# Script to insert data from course.csv and students.csv into a students database

# Manually run sudo docker-compose up -d

# Use Docker Compose exec to run psql within the container
PSQL="docker-compose exec -T postgresql psql -U kmb -d fcc-student-db --no-align --tuples-only"

# Connect to the 'students' database within the psql session
$PSQL -c "\c students"

# Confirm that you are connected to the students database
echo "SELECT 'Connected to students database' AS status;" | $PSQL

# Rest of your script remains unchanged...
tail -n +2 courses.csv | while IFS="," read -r MAJOR COURSE
do
    # get major_id
    echo $MAJOR
    echo "SELECT major_id FROM majors WHERE major='$MAJOR';"
    MAJOR_ID=$($PSQL -c "SELECT major_id FROM majors WHERE major='$MAJOR';")
    echo $MAJOR_ID
    # if not found

    # insert major

    # get new major_id

    # get course_id

    # if not found

    # insert course

    # get new course_id

    # insert into majors_courses
done

# #!/bin/bash

# # Script to insert data from course.csv and students.csv into a students database

# # Set environment variables
# export PGPASSWORD="your_postgres_password"  # Replace with your actual PostgreSQL password
# export PGUSER="kmb"
# export PGDATABASE="fcc-student-db"

# # Connect to the 'students' database within the psql session
# psql -h localhost -p 5433 -U $PGUSER -d $PGDATABASE --no-align --tuples-only -c "\c students"

# # Confirm that you are connected to the students database
# echo "SELECT 'Connected to students database' AS status;" | psql -h localhost -p 5433 -U $PGUSER -d $PGDATABASE --no-align --tuples-only

# # Rest of your script remains unchanged...
# tail -n +2 courses.csv | while IFS="," read -r MAJOR COURSE
# do
#     # get major_id
#     echo $MAJOR
#     echo "SELECT major_id FROM majors WHERE major='$MAJOR';" | psql -h localhost -p 5433 -U $PGUSER -d $PGDATABASE --no-align --tuples-only
#     MAJOR_ID=$(echo "SELECT major_id FROM majors WHERE major='$MAJOR';" | psql -h localhost -p 5433 -U $PGUSER -d $PGDATABASE --no-align --tuples-only)
#     echo $MAJOR_ID
#     # if not found

#     # insert major

#     # get new major_id

#     # get course_id

#     # if not found

#     # insert course

#     # get new course_id

#     # insert into majors_courses
# done