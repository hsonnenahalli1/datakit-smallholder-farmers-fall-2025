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

