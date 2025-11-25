SELECT
    question_user_country_code,
    count() AS num_pairs,
    quantile(0.5)(dateDiff('second', question_sent, response_sent) / 3600.0) AS median_response_hours,
    quantile(0.9)(dateDiff('second', question_sent, response_sent) / 3600.0) AS p90_response_hours
FROM farmers_data_english
WHERE
    response_sent IS NOT NULL
    AND question_user_country_code IS NOT NULL
GROUP BY question_user_country_code
ORDER BY num_pairs DESC;
