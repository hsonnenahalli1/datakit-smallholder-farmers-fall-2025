# Base view: response time per Q–A pair in hours
CREATE OR REPLACE VIEW v_en_response_time AS
SELECT
    question_id,
    question_sent,
    response_sent,
    question_user_country_code,
    response_user_id,
    dateDiff('second', question_sent, response_sent) / 3600.0 AS response_time_hours
FROM farmers_data_english
WHERE response_sent IS NOT NULL;
# Check 
SELECT *
FROM v_en_response_time
LIMIT 10;
# Summary Stats
CREATE OR REPLACE VIEW v_en_response_time_summary AS
SELECT
    min(response_time_hours)                         AS min_hours,
    quantile(0.25)(response_time_hours)              AS p25_hours,
    quantile(0.5)(response_time_hours)               AS median_hours,
    quantile(0.9)(response_time_hours)               AS p90_hours,
    max(response_time_hours)                         AS max_hours,
    count()                                          AS num_pairs
FROM v_en_response_time;
# Usage 
SELECT *
FROM v_en_response_time_summary;
# Response Time by country 
CREATE OR REPLACE VIEW v_en_response_time_by_country AS
SELECT
    question_user_country_code,
    count() AS num_pairs,
    quantile(0.5)(response_time_hours) AS median_response_hours,
    quantile(0.9)(response_time_hours) AS p90_response_hours
FROM v_en_response_time
WHERE question_user_country_code IS NOT NULL
GROUP BY question_user_country_code
ORDER BY num_pairs DESC;
# Response time by advisors
CREATE OR REPLACE VIEW v_en_response_time_by_advisor AS
SELECT
    response_user_id,
    count() AS num_responses,
    quantile(0.5)(response_time_hours) AS median_response_hours
FROM v_en_response_time
GROUP BY response_user_id
ORDER BY num_responses DESC;
#Usage
SELECT *
FROM v_en_response_time_by_advisor
WHERE num_responses >= 50
ORDER BY median_response_hours ASC
LIMIT 50;


