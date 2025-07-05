-- =============================
-- 🚗 RIDE BOOKINGS BASE TABLE
-- =============================
SELECT * FROM ride_bookings;


-- ========================================
-- 📊 1. OPERATIONAL EFFICIENCY INSIGHTS
-- ========================================

-- 1.1 Average VTAT and CTAT by Vehicle Type
CREATE VIEW average_VTAT_and_CTAT AS
SELECT vehicle_type, 
       ROUND(AVG(avg_vtat), 2) AS average_vtat,
       ROUND(AVG(avg_ctat), 2) AS average_ctat
FROM ride_bookings
GROUP BY vehicle_type;
SELECT * FROM average_VTAT_and_CTAT;

-- 1.2 Highest Ride Completion Rate by Pickup Location
CREATE VIEW highest_ride_completion AS
SELECT pickup_location, COUNT(*) AS successful_bookings
FROM ride_bookings
WHERE booking_status = 'Success'
GROUP BY pickup_location
ORDER BY successful_bookings DESC
LIMIT 5;
SELECT * FROM highest_ride_completion;

-- 1.3 Incomplete Bookings Percentage
CREATE VIEW percentageOfIncompleteBookings AS
SELECT ROUND(100 * COUNT(*) FILTER (WHERE incomplete_rides = TRUE) / COUNT(*), 2) 
       AS incomplete_booking_percentage
FROM ride_bookings;
SELECT * FROM percentageOfIncompleteBookings;

-- 1.4 Top Reasons for Incomplete Bookings
CREATE VIEW top_reasons_for_incomplete_bookings AS
SELECT incomplete_rides_reason, COUNT(*) AS incomplete_bookings
FROM ride_bookings
WHERE booking_status = 'Incomplete'
GROUP BY incomplete_rides_reason
ORDER BY incomplete_bookings DESC;
SELECT * FROM top_reasons_for_incomplete_bookings;

-- 1.5 Routes with Highest Cancellation Rates
CREATE VIEW routes_with_higher_cancellation_rates AS
SELECT pickup_location, drop_location,
       COUNT(*) AS total_rides,
       COUNT(*) FILTER (WHERE cancelled_rides_by_driver = 'true' OR cancelled_by_customer = 'true') AS cancelled,
       ROUND(100.0 * COUNT(*) FILTER (WHERE cancelled_rides_by_driver = 'true' OR cancelled_by_customer = 'true') / COUNT(*), 2) AS cancel_rate
FROM ride_bookings
GROUP BY pickup_location, drop_location
ORDER BY cancel_rate DESC
LIMIT 10;
SELECT * FROM routes_with_higher_cancellation_rates;


-- ========================================
-- 💰 2. FINANCIAL INSIGHTS
-- ========================================

-- 2.1 Total Revenue by Vehicle Type
CREATE VIEW vehicle_revenue_summary AS
SELECT vehicle_type, 
       SUM(booking_value) AS total_booking
FROM ride_bookings
WHERE booking_status = 'Success'
GROUP BY vehicle_type
ORDER BY total_booking DESC;
SELECT * FROM vehicle_revenue_summary;

-- 2.2 Average Booking Value per Vehicle
CREATE VIEW avg_booking_value_per_vehicle AS
SELECT vehicle_type,
       ROUND(AVG(booking_value), 2) AS avg_booking_value
FROM ride_bookings
WHERE booking_status = 'Success'
GROUP BY vehicle_type
ORDER BY avg_booking_value DESC;
SELECT * FROM avg_booking_value_per_vehicle;

-- 2.3 Estimated Revenue Loss Due to Cancellations
CREATE VIEW estimated_revenue_loss_view AS
WITH success_stats AS (
    SELECT ROUND(AVG(booking_value), 2) AS avg_success_value
    FROM ride_bookings
    WHERE booking_status = 'Success'
),
cancel_counts AS (
    SELECT 
        COUNT(*) FILTER (WHERE cancelled_by_customer = 'true') AS customer_cancelled,
        COUNT(*) FILTER (WHERE cancelled_rides_by_driver = 'true') AS driver_cancelled
    FROM ride_bookings
)
SELECT 
    s.avg_success_value,
    c.customer_cancelled,
    c.driver_cancelled,
    ROUND(c.customer_cancelled * s.avg_success_value, 2) AS estimated_loss_from_customers,
    ROUND(c.driver_cancelled * s.avg_success_value, 2) AS estimated_loss_from_drivers,
    ROUND((c.customer_cancelled + c.driver_cancelled) * s.avg_success_value, 2) AS total_estimated_revenue_loss
FROM success_stats s, cancel_counts c;
SELECT * FROM estimated_revenue_loss_view;

-- 2.4 Revenue Per Kilometer per Route
CREATE VIEW revenue_per_km_per_route AS
SELECT pickup_location, drop_location,
       ROUND(SUM(booking_value) / NULLIF(SUM(ride_distance), 0), 2) AS revenue_per_km
FROM ride_bookings
WHERE booking_status = 'Success'
GROUP BY pickup_location, drop_location
ORDER BY revenue_per_km DESC
LIMIT 10;
SELECT * FROM revenue_per_km_per_route;

-- 2.5 Revenue Per Kilometer per Vehicle Type
CREATE VIEW revenue_per_km_per_vehicle AS
SELECT vehicle_type,
       ROUND(SUM(booking_value) / NULLIF(SUM(ride_distance), 0), 2) AS revenue_per_km
FROM ride_bookings
WHERE booking_status = 'Success'
GROUP BY vehicle_type
ORDER BY revenue_per_km DESC
LIMIT 10;
SELECT * FROM revenue_per_km_per_vehicle;

-- 2.6 Average Booking Value by Payment Method
CREATE VIEW Average_Booking_Value_by_Payment_Method AS
SELECT payment_method,
       ROUND(AVG(booking_value), 2) AS avg_booking_value
FROM ride_bookings
WHERE booking_status = 'Success'
GROUP BY payment_method
ORDER BY avg_booking_value DESC;
SELECT * FROM Average_Booking_Value_by_Payment_Method;


-- ========================================
-- 😊 3. CUSTOMER BEHAVIOR & SATISFACTION
-- ========================================

-- 3.1 Ride Request Volume by Day and Time Slot
CREATE VIEW highest_ride_requests AS
SELECT 
  TO_CHAR(date, 'Day') AS day_of_week,
  CASE
    WHEN EXTRACT(HOUR FROM time) BETWEEN 0 AND 5 THEN 'Late Night'
    WHEN EXTRACT(HOUR FROM time) BETWEEN 6 AND 11 THEN 'Morning'
    WHEN EXTRACT(HOUR FROM time) BETWEEN 12 AND 17 THEN 'Afternoon'
    WHEN EXTRACT(HOUR FROM time) BETWEEN 18 AND 23 THEN 'Evening'
  END AS time_slot,
  COUNT(*) AS total_requests
FROM ride_bookings
GROUP BY day_of_week, time_slot
ORDER BY total_requests DESC
LIMIT 10;
SELECT * FROM highest_ride_requests;

-- 3.2 Ride Completion Rate by Time Slot
CREATE VIEW completion_rate AS
SELECT 
  TO_CHAR(date, 'Day') AS day_of_week,
  CASE
    WHEN EXTRACT(HOUR FROM time) BETWEEN 0 AND 5 THEN 'Late Night'
    WHEN EXTRACT(HOUR FROM time) BETWEEN 6 AND 11 THEN 'Morning'
    WHEN EXTRACT(HOUR FROM time) BETWEEN 12 AND 17 THEN 'Afternoon'
    WHEN EXTRACT(HOUR FROM time) BETWEEN 18 AND 23 THEN 'Evening'
  END AS time_slot,
  ROUND(100 * COUNT(*) FILTER (WHERE booking_status = 'Success') / COUNT(*), 2) AS completion_rate
FROM ride_bookings
GROUP BY day_of_week, time_slot
ORDER BY completion_rate DESC;
SELECT * FROM completion_rate;

-- 3.3 Most Frequent Pickup-Drop Routes
CREATE VIEW most_frequent_route AS
SELECT pickup_location, drop_location, COUNT(*) AS route_count
FROM ride_bookings
GROUP BY pickup_location, drop_location
ORDER BY route_count DESC
LIMIT 15;
SELECT * FROM most_frequent_route;

-- 3.4 Highest Revenue Zones per Ride
CREATE VIEW highest_revenue AS
SELECT pickup_location, drop_location, 
       ROUND(SUM(booking_value)/COUNT(*), 2) AS revenue
FROM ride_bookings
WHERE booking_status = 'Success' AND booking_value IS NOT NULL
GROUP BY pickup_location, drop_location
ORDER BY revenue DESC
LIMIT 15;
SELECT * FROM highest_revenue;

-- 3.5 Zones with Lowest Customer Ratings
CREATE VIEW poor_customer_rating AS
SELECT pickup_location, drop_location, 
       ROUND(AVG(customer_rating), 2) AS c_ratings
FROM ride_bookings
GROUP BY pickup_location, drop_location
ORDER BY c_ratings ASC
LIMIT 15;
SELECT * FROM poor_customer_rating;

-- 3.6 Zones with Lowest Driver Ratings
CREATE VIEW poor_driver_rating AS
SELECT pickup_location, drop_location, 
       ROUND(AVG(driver_ratings), 2) AS d_ratings
FROM ride_bookings
GROUP BY pickup_location, drop_location
ORDER BY d_ratings ASC
LIMIT 15;
SELECT * FROM poor_driver_rating;



