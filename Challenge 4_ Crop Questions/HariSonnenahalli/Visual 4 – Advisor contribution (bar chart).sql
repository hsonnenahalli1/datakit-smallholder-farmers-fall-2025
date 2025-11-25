SELECT
    response_user_id,
    count() AS num_responses
FROM farmers_data_english
WHERE response_sent IS NOT NULL
GROUP BY response_user_id
ORDER BY num_responses DESC
LIMIT 20;
