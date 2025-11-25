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
