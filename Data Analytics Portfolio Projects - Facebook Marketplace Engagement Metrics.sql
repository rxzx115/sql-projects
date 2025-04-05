-- To test the data that is loaded into the database and table
SELECT *
FROM molten-thought-441320-u6.Example.facebookmarketplaceengagement
LIMIT 10




-- To confirm if there are any missing data in the status_id
SELECT status_id
FROM molten-thought-441320-u6.Example.facebookmarketplaceengagement
WHERE status_id IS NULL




-- To confirm if there are any missing data in the status_type
SELECT status_type
FROM molten-thought-441320-u6.Example.facebookmarketplaceengagement
WHERE status_type IS NULL




-- To confirm if there are any missing data in the status_published
SELECT status_published
FROM molten-thought-441320-u6.Example.facebookmarketplaceengagement
WHERE status_published IS NULL




-- To confirm if there are any missing data in the num_reactions
SELECT num_reactions
FROM molten-thought-441320-u6.Example.facebookmarketplaceengagement
WHERE num_reactions IS NULL




-- To confirm if there are any missing data in the num_comments
SELECT num_comments
FROM molten-thought-441320-u6.Example.facebookmarketplaceengagement
WHERE num_comments IS NULL




-- To find the distinct status_type to clean up any incomplete data
SELECT DISTINCT status_type
FROM molten-thought-441320-u6.Example.facebookmarketplaceengagement




-- To recalculate the total number of reactions to identify any variances and clean up any incomplete data
-- To research if there are material variances
WITH reactions AS (
    SELECT *,
        num_likes + num_loves + num_wows + num_hahas + num_sads + num_angrys AS num_reactions_calc
    FROM molten-thought-441320-u6.Example.facebookmarketplaceengagement
),
variances AS (
    SELECT *,
        num_reactions - num_reactions_calc AS reactions_variance
    FROM reactions
)
SELECT *,
FROM variances
WHERE reactions_variance <> 0
ORDER BY reactions_variance DESC




--To find the number of distinct status_id
SELECT COUNT(DISTINCT status_id) AS status_id_count
FROM molten-thought-441320-u6.Example.facebookmarketplaceengagement




-- To identify the number of status_id that show up more than once in the data
SELECT status_id, COUNT(status_id) AS status_id_count
FROM molten-thought-441320-u6.Example.facebookmarketplaceengagement
GROUP BY status_id
HAVING COUNT(status_id) > 1




-- To identify and confirm the number of status_id that show up once
SELECT status_id, COUNT(status_id) AS status_id_count
FROM molten-thought-441320-u6.Example.facebookmarketplaceengagement
GROUP BY status_id
HAVING COUNT(status_id) = 1




-- To count the number of statuses by status type and find the earliest and latest dates to identify outliers
SELECT 
    status_type, 
    COUNT(status_type) AS status_type_count, 
    DATE(MIN(status_published)) AS date_min, 
    DATE(MAX(status_published)) AS date_max
FROM molten-thought-441320-u6.Example.facebookmarketplaceengagement
GROUP BY status_type
ORDER BY status_type_count DESC




-- To create a clean table with the calculations to finish the data cleaning process and to use for data visualization process
SELECT *,
    date(status_published) AS date,
    time(status_published) AS time
FROM molten-thought-441320-u6.Example.facebookmarketplaceengagement




-- To find the count, average, min, and max of reactions, comments, and shares overall
SELECT 
    COUNT(status_id) AS status_id_count, 
    ROUND(AVG(num_reactions), 0) AS num_reactions_avg, 
    ROUND(AVG(num_comments), 0) AS num_comments_avg, 
    ROUND(AVG(num_shares), 0) AS num_shares_avg, 
    DATE(MIN(status_published)) AS date_min,
    DATE(MAX(status_published)) AS date_max, 
FROM molten-thought-441320-u6.Example.facebookmarketplaceengagement




-- To find the count, average, min, and max of reactions, comments, and shares in 2018
SELECT 
    COUNT(status_id) AS status_id_count, 
    ROUND(AVG(num_reactions), 0) AS num_reactions_avg, 
    ROUND(AVG(num_comments), 0) AS num_comments_avg, 
    ROUND(AVG(num_shares), 0) AS num_shares_avg, 
    DATE(MIN(status_published)) AS date_min,
    DATE(MAX(status_published)) AS date_max, 
FROM molten-thought-441320-u6.Example.facebookmarketplaceengagement
WHERE EXTRACT(YEAR FROM status_published) = 2018




-- To find the count, average, min, and max of reactions, comments, and shares by status_type
SELECT 
    status_type,
    COUNT(status_id) AS status_id_count, 
    ROUND(AVG(num_reactions), 0) AS num_reactions_avg, 
    ROUND(AVG(num_comments), 0) AS num_comments_avg, 
    ROUND(AVG(num_shares), 0) AS num_shares_avg, 
    DATE(MIN(status_published)) AS date_min,
    DATE(MAX(status_published)) AS date_max, 
FROM molten-thought-441320-u6.Example.facebookmarketplaceengagement
GROUP BY status_type
ORDER BY COUNT(status_id) DESC




-- To find the statuses that received the top 5 number of reactions of all time using rank function
-- Note: the rank function has rank gaps. The dense rank function may work better.
WITH rankedreactions AS (
    SELECT *,
    RANK() OVER (ORDER BY num_reactions DESC) AS reactions_ranked
    FROM molten-thought-441320-u6.Example.facebookmarketplaceengagement
)
SELECT status_id, num_reactions, reactions_ranked
FROM rankedreactions
WHERE reactions_ranked IN (1,2,3,4,5)
ORDER BY reactions_ranked ASC




-- To find the statuses that received the top 5 number of reactions of all time using dense rank function
WITH rankedreactions AS (
    SELECT *,
    DENSE_RANK() OVER (ORDER BY num_reactions DESC) AS reactions_ranked
    FROM molten-thought-441320-u6.Example.facebookmarketplaceengagement
)
SELECT status_id, num_reactions, reactions_ranked
FROM rankedreactions
WHERE reactions_ranked IN (1,2,3,4,5)
ORDER BY reactions_ranked ASC




-- To find the statuses that received the top 5 number of reactions of all time using rank function and limit to the top 5 items by including an additional parameter the order by function
-- Note: the rank function has rank gaps. The dense rank function may work better.
WITH rankedreactions AS (
    SELECT *,
    RANK() OVER (ORDER BY num_reactions DESC, status_id ASC) AS reactions_ranked
    FROM molten-thought-441320-u6.Example.facebookmarketplaceengagement
)
SELECT status_id, num_reactions, reactions_ranked
FROM rankedreactions
WHERE reactions_ranked IN (1,2,3,4,5)
ORDER BY reactions_ranked ASC

