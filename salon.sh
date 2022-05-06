#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"


MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi 
  SERVICES_AVAIL=$($PSQL "SELECT service_id, name FROM services;")
  echo "$SERVICES_AVAIL" | while read ID BAR NAME
  do
    echo -e "$ID) $NAME"
  done
  # read and check if the choosen option is a number
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # send to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # check if service is available
    SERVICE_ID=$($PSQL "SELECT service_id FROM services where service_id='$SERVICE_ID_SELECTED' ; " )
    if [[ -z $SERVICE_ID ]]
    then
      # send to main menu
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      MAKE_APPT $SERVICE_ID
    fi
  fi

}

MAKE_APPT(){
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  # look up customer name from database based on phone
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers where phone='$CUSTOMER_PHONE';" )
  if [[ -z $CUSTOMER_NAME ]] 
  then 
    # get customer name from cli
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    # insert customer with name/phone
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE' ); " )
  fi
  
  # get customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$PHONE_NUMBER'; " )

  # get appointment type
  APPOINTMENT_TYPE=$($PSQL "SELECT name FROM services where service_id='$1'; " )

  # clean values
  APPOINTMENT_TYPE=$(echo $APPOINTMENT_TYPE | sed -E 's/^ *| *$//')
  CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//')

  # get a time for the appointment
  echo -e "\nWhat time would you like your $APPOINTMENT_TYPE, $CUSTOMER_NAME?"
  read SERVICE_TIME
  
  # insert appointment to database
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments ( customer_id, service_id, time ) values ( $CUSTOMER_ID, $1, '$SERVICE_TIME' );" )
  
  # response of appointment
  echo -e "\nI have put you down for a $APPOINTMENT_TYPE at $SERVICE_TIME, $CUSTOMER_NAME."
} 





MAIN_MENU "Welcome to My Salon, how can I help you?"
