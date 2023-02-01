-- Keep a log of any SQL queries you execute as you solve the mystery.

--Theft took place on July 28, 2021 on Humphrey Street

--see what evidence is available
.tables -- airports, atm_transactions, bakery_security_logs, bank_accounts, crime_scene_reports, flights, interviews, passengers, people, phone_calls

--look for crime in location and date
SELECT *
FROM crime_scene_reports
WHERE year = 2021
AND month = 7
AND day = 28
AND street = "Humphrey Street";
--id 295, Theft CS50 duck 10:15am Humphrey Street bakery. Interviews with three witnesses present

--see interviews on date
SELECT name, transcript
FROM interviews
WHERE year = 2021
AND month = 7
and day = 28;
--Ruth: within 10 mins of theft, thief get into car and drive away
--Eugene: ATM on Leggett Street thief withdrew money
--Raymond: thief called someone less than a min, plan to take earliest flight out Fiftyville TOMORROW

--Exits 10:15-10:25
--ATM Leggett Street, withdraw
--Thief calls accomplice for less than a minute
--Accomplice purchased tickets, earliest flight out Fiftyville next day

--see table description
.schema bakery_security_logs

--see people description
.schema people

--see which people with matching license plates with those who left within 10 minutes of theft
SELECT name
FROM people
WHERE license_plate
IN (SELECT license_plate
    FROM bakery_security_logs
    WHERE year = 2021
    AND month = 7
    AND day = 28
    AND hour = 10
    AND minute < 26
    AND activity = "exit");
--Vanessa, Barry, Iman, Sofia, Luca, Diana, Kelsey, Bruce

--see atm description
.schema atm_transactions

--see who withdrew money this day and left within 10 mins
SELECT name
FROM people
WHERE id
IN (SELECT person_id
    FROM bank_accounts
    WHERE account_number
    IN (SELECT account_number
        FROM atm_transactions
        WHERE year = 2021
        AND MONTH = 7
        AND DAY = 28
        AND atm_location = "Leggett Street"
        AND transaction_type = "withdraw"))

INTERSECT

SELECT name
FROM people
WHERE license_plate
IN (SELECT license_plate
    FROM bakery_security_logs
    WHERE year = 2021
    AND month = 7
    AND day = 28
    AND hour = 10
    AND minute < 26
    AND activity = "exit");
--Thief is Bruce, Iman, Diana, or Luca

--see calls description
.schema phone_calls

--list calls that lastedless than a minute that day
SELECT *
FROM phone_calls
WHERE year = 2021
AND month = 7
AND day = 28
AND duration < 60;

--See numbers of suspects
SELECT name, phone_number
FROM people
WHERE name = "Bruce"
OR name = "Iman"
OR name = "Diana"
OR name = "Luca";
--Bruce calls (375) 555-8161
--Diana calls (725) 555-3243

SELECT name, phone_number
FROM people
WHERE phone_number = "(375) 555-8161" --Robin's number
OR phone_number = "(725) 555-3243"; --Philip's number
--Thief: Diana, Accomplice: Philip or
--Thief: Bruce, Accomplice: Robin

--see earliest flights originating from Fiftyville next day
SELECT *
FROM flights
WHERE year = 2021
AND month = 7
AND day = 29
AND origin_airport_id = 8
ORDER BY day, hour, minute;
--destination airport id is 4, or LaGuardia Airport, New York City, flight id is 36

.schema passengers

--see passengers on the flight
SELECT name
FROM people
WHERE passport_number IN (SELECT passport_number
                          FROM passengers
                          WHERE flight_id = 36);
--Bruce is in the list of passengers, and none of the other suspects are
--Thief: Bruce
--Accomplice: Robin
--City: New York City
