-- =========================================================================
-- SYSTEM: Football Ticket Booking System Database Setup Template
-- =========================================================================

DROP TABLE IF EXISTS Bookings;
DROP TABLE IF EXISTS Matches;
DROP TABLE IF EXISTS Users;

-- =========================================================================
-- 1. CREATE USERS TABLE
-- =========================================================================

CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    role VARCHAR(50) NOT NULL
        CHECK (role IN ('Football Fan', 'Ticket Manager')),
    phone_number VARCHAR(30)
);

-- =========================================================================
-- 2. CREATE MATCHES TABLE
-- =========================================================================

CREATE TABLE Matches (
    match_id INTEGER PRIMARY KEY,
    fixture VARCHAR(300) NOT NULL,
    tournament_category VARCHAR(150) NOT NULL,
    base_ticket_price NUMERIC(10) NOT NULL
        CHECK (base_ticket_price > 0),
    match_status VARCHAR(50) NOT NULL
        CHECK (
            match_status IN (
                'Available',
                'Selling Fast',
                'Sold Out',
                'Postponed'
            )
        )
);

-- =========================================================================
-- 3. CREATE BOOKINGS TABLE
-- =========================================================================
CREATE TABLE Bookings (
    booking_id SERIAL PRIMARY KEY,

    user_id INTEGER NOT NULL REFERENCES Users(user_id),

    match_id INTEGER NOT NULL REFERENCES Matches(match_id),

    seat_number VARCHAR(50),

    payment_status VARCHAR(50)
        CHECK (
            payment_status IN (
                'Pending',
                'Confirmed',
                'Cancelled',
                'Refunded'
            )
        ),

    total_cost NUMERIC(10) NOT NULL
        CHECK (total_cost >= 0),

        UNIQUE (match_id, seat_number)
);


-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO USERS
-- =========================================================================
INSERT INTO Users(user_id, full_name, email, role, phone_number) VALUES
(1, 'Tanvir Rahman', 'tanvir@mail.com', 'Football Fan', '+8801711111111'),
(2, 'Asif Haque', 'asif@mail.com', 'Football Fan', '+8801722222222'),
(3, 'Sajjad Rahman', 'sajjad@mail.com', 'Ticket Manager', '+8801733333333'),
(4, 'Jannat Ara', 'jannat@mail.com', 'Football Fan', NULL);

-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO MATCHES
-- =========================================================================
INSERT INTO Matches (match_id, fixture, tournament_category, base_ticket_price, match_status) VALUES
(101, 'Real Madrid vs Barcelona', 'Champions League', 150.00, 'Available'),
(102, 'Man City vs Liverpool', 'Premier League', 120.00, 'Selling Fast'),
(103, 'Bayern Munich vs PSG', 'Champions League', 130.00, 'Available'),
(104, 'AC Milan vs Inter Milan', 'Serie A', 90.00, 'Sold Out'),
(105, 'Juventus vs Roma', 'Serie A', 80.00, 'Available');

-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO BOOKINGS
-- =========================================================================
INSERT INTO Bookings (booking_id, user_id, match_id, seat_number, payment_status, total_cost) VALUES
(501, 1, 101, 'A-12', 'Confirmed', 150.00),
(502, 1, 102, 'B-04', 'Confirmed', 120.00),
(503, 2, 101, 'A-13', 'Confirmed', 150.00),
(504, 2, 101, NULL, NULL, 150.00),
(505, 3, 102, 'C-20', 'Pending', 120.00);




-- Query 1: Retrieve all upcoming football matches belonging to the 'Champions League' where the match status is 'Available'.

SELECT match_id,fixture,base_ticket_price from Matches
WHERE tournament_category ='Champions League'
     and match_status ='Available'


-- Query 2: Search for all users whose full names start with 'Tanvir' or contain the phrase 'Haque' (case-insensitive).

SELECT user_id,full_name,email from Users
WHERE full_name ILIKE 'Tanvir%' 
     or full_name ILIKE '%Haque%'


-- Query 3: Retrieve all booking records where the payment status is missing (NULL), replacing the empty result with 'Action Required'.


select booking_id,user_id,match_id, COALESCE(payment_status,'Action Required') as systematic_status
FROM Bookings
WHERE payment_status is null;
  

-- Query 4: Retrieve match booking details along with the User's full name and the scheduled Match fixture teams;

select b.booking_id,u.full_name,m.fixture,b.total_cost 
from bookings as b 
INNER join Matches as m 
on m.match_id = b.match_id
INNER join Users as u  
on u.user_id = b.user_id  ;



-- Query 5: Display a comprehensive list of all users and their booking IDs, ensuring that fans who have never bought a ticket are still listed.


select u.user_id,u.full_name,b.booking_id 
from Users as u 
left join bookings as b 
on u.user_id = b.user_id  
left join Matches as m  
on m.match_id = b.match_id;


-- Query 6: Find all ticket bookings where the total cost is strictly higher than the average cost of all ticket bookings.


SELECT booking_id, match_id, total_cost
FROM bookings
WHERE total_cost > (
    SELECT AVG(total_cost)
    FROM bookings
);


-- Query 7: Retrieve the top 2 most expensive matches sorted by base ticket price, skipping the absolute highest premium match.

select match_id,fixture,base_ticket_price from Matches
ORDER BY base_ticket_price DESC
LIMIT 2 OFFSET 1