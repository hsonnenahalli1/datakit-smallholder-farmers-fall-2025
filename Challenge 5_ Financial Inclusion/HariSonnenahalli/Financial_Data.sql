# Test classification with a plain
SELECT
    question_id,
    question_content,

    /* Main category */
    CASE
        WHEN multiSearchAnyCaseInsensitive(
            question_content,
            ['loan','credit','debt','interest','repay','repayment','borrow','borrowing','emi','mortgage','overdraft']
        ) = 1 THEN 'credit_loans'

        WHEN multiSearchAnyCaseInsensitive(
            question_content,
            ['saving','savings','deposit','fd','recurring deposit','rd','insurance','policy','premium','claim','pension','subsidy','benefit']
        ) = 1 THEN 'savings_insurance'

        WHEN multiSearchAnyCaseInsensitive(
            question_content,
            ['price','market price','mandi','rate','cost','msp','selling price','buying price']
        ) = 1 THEN 'market_prices'

        WHEN multiSearchAnyCaseInsensitive(
            question_content,
            ['income','earnings','wage','salary','job','labour','labor','side business','business','work']
        ) = 1 THEN 'livelihood_income'

        ELSE 'non_financial'
    END AS financial_category,

    /* Overall financial flag */
    CASE
        WHEN multiSearchAnyCaseInsensitive(
            question_content,
            [
                'loan','credit','debt','interest','repay','repayment','borrow','borrowing','emi','mortgage','overdraft',
                'saving','savings','deposit','fd','recurring deposit','rd','insurance','policy','premium','claim','pension','subsidy','benefit',
                'price','market price','mandi','rate','cost','msp','selling price','buying price',
                'income','earnings','wage','salary','job','labour','labor','side business','business','work'
            ]
        ) = 1 THEN 1
        ELSE 0
    END AS is_financial

FROM farmers_data_english
LIMIT 100;
CREATE VIEW farmers_data_english_financial AS
SELECT
    *,
    CASE
        WHEN multiSearchAnyCaseInsensitive(
            question_content,
            ['loan','credit','debt','interest','repay','repayment','borrow','borrowing','emi','mortgage','overdraft']
        ) = 1 THEN 'credit_loans'

        WHEN multiSearchAnyCaseInsensitive(
            question_content,
            ['saving','savings','deposit','fd','recurring deposit','rd','insurance','policy','premium','claim','pension','subsidy','benefit']
        ) = 1 THEN 'savings_insurance'

        WHEN multiSearchAnyCaseInsensitive(
            question_content,
            ['price','market price','mandi','rate','cost','msp','selling price','buying price']
        ) = 1 THEN 'market_prices'

        WHEN multiSearchAnyCaseInsensitive(
            question_content,
            ['income','earnings','wage','salary','job','labour','labor','side business','business','work']
        ) = 1 THEN 'livelihood_income'

        ELSE 'non_financial'
    END AS financial_category,

    CASE
        WHEN multiSearchAnyCaseInsensitive(
            question_content,
            [
                'loan','credit','debt','interest','repay','repayment','borrow','borrowing','emi','mortgage','overdraft',
                'saving','savings','deposit','fd','recurring deposit','rd','insurance','policy','premium','claim','pension','subsidy','benefit',
                'price','market price','mandi','rate','cost','msp','selling price','buying price',
                'income','earnings','wage','salary','job','labour','labor','side business','business','work'
            ]
        ) = 1 THEN 1
        ELSE 0
    END AS is_financial
FROM farmers_data_english;
SELECT
    countIf(is_financial = 1) AS financial_questions,
    count() AS total_questions,
    round(financial_questions * 100.0 / total_questions, 2) AS financial_pct
FROM farmers_data_english_financial;
SELECT
    financial_category,
    count() AS questions,
    round(questions * 100.0 / sum(questions) OVER (), 2) AS pct_of_financial_questions
FROM farmers_data_english_financial
WHERE is_financial = 1
GROUP BY financial_category
ORDER BY questions DESC;
SELECT
    toStartOfMonth(question_sent) AS month,
    countIf(is_financial = 1) AS financial_questions,
    count() AS total_questions,
    round(financial_questions * 100.0 / total_questions, 2) AS pct_financial
FROM farmers_data_english_financial
GROUP BY month
ORDER BY month;
SELECT
    question_user_country_code AS country,
    countIf(is_financial = 1) AS financial_questions,
    count() AS total_questions,
    round(financial_questions * 100.0 / total_questions, 2) AS pct_financial
FROM farmers_data_english_financial
GROUP BY country
ORDER BY pct_financial DESC;


