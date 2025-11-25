# Response length stats 
CREATE OR REPLACE VIEW v_en_response_length_stats AS
WITH
    (
        lengthUTF8(response_content)
            - lengthUTF8(replaceAll(response_content, ' ', ''))
            + 1
    ) AS words
SELECT
    avg(length(response_content))      AS avg_chars,
    median(length(response_content))   AS median_chars,
    min(length(response_content))      AS min_chars,
    max(length(response_content))      AS max_chars,
    avg(words)                         AS avg_words,
    median(words)                      AS median_words,
    max(words)                         AS max_words,
    count()                            AS num_responses
FROM farmers_data_english;
# Usage
SELECT *
FROM v_en_response_length_stats;
# Depth by advisor
CREATE OR REPLACE VIEW v_en_response_depth_by_advisor AS
SELECT
    response_user_id,
    count()                                   AS num_responses,
    avg(length(response_content))            AS avg_chars,
    median(length(response_content))         AS median_chars
FROM farmers_data_english
GROUP BY response_user_id
ORDER BY num_responses DESC;
# Usage (Active Advisors)
SELECT *
FROM v_en_response_depth_by_advisor
WHERE num_responses >= 50
ORDER BY num_responses DESC
LIMIT 50;
# Depth by topic 
CREATE OR REPLACE VIEW v_en_response_depth_by_topic AS
SELECT
    question_topic,
    count()                                   AS num_responses,
    avg(length(response_content))            AS avg_chars,
    median(length(response_content))         AS median_chars
FROM farmers_data_english
WHERE question_topic IS NOT NULL
GROUP BY question_topic
ORDER BY num_responses DESC;
# Usage
SELECT *
FROM v_en_response_depth_by_topic
WHERE num_responses >= 100
ORDER BY num_responses DESC;
# Topic alignment (question vs response topic)
CREATE OR REPLACE VIEW v_en_topic_alignment_pairs AS
SELECT
    question_topic,
    response_topic,
    count() AS num_pairs
FROM farmers_data_english
WHERE
    question_topic IS NOT NULL
    AND response_topic IS NOT NULL
GROUP BY
    question_topic,
    response_topic
ORDER BY num_pairs DESC;
# Usage
SELECT *
FROM v_en_topic_alignment_pairs
LIMIT 50;
# Daily usage 
SELECT * FROM v_en_questions_by_date;
SELECT * FROM v_en_questions_by_country;
SELECT * FROM v_en_response_time_summary;
SELECT * FROM v_en_topics_by_country WHERE num_questions >= 50;


