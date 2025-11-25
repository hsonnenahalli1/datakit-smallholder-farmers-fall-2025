# Visual 1 – Questions over time (line chart)
SELECT
    toDate(question_sent) AS question_date,
    count()               AS num_questions_with_en_response
FROM farmers_data_english
GROUP BY question_date
ORDER BY question_date;
# Visual 2 – Topics by country (stacked bar)
SELECT
    question_user_country_code,
    question_topic,
    count() AS num_questions
FROM farmers_data_english
WHERE
    question_topic IS NOT NULL
    AND question_user_country_code IS NOT NULL
GROUP BY
    question_user_country_code,
    question_topic
HAVING num_questions >= 50
ORDER BY
    question_user_country_code,
    num_questions DESC;
# Visual 3 – Response time by country (bar chart)
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
# Visual 4 – Advisor contribution (bar chart)
SELECT
    response_user_id,
    count() AS num_responses
FROM farmers_data_english
WHERE response_sent IS NOT NULL
GROUP BY response_user_id
ORDER BY num_responses DESC
LIMIT 20;
# Visual 5 – Response depth by topic (bar)
SELECT
    question_topic,
    count()                                   AS num_responses,
    avg(length(response_content))            AS avg_chars,
    median(length(response_content))         AS median_chars
FROM farmers_data_english
WHERE question_topic IS NOT NULL
GROUP BY question_topic
HAVING num_responses >= 100
ORDER BY num_responses DESC;


