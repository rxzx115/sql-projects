-- to test upload and initial query
SELECT *
FROM molten-thought-441320-u6.Example.insurancecomplaints
LIMIT 10




-- to count the total complaint numbers and unique complaint numbers
SELECT 
    COUNT(complaint_number) AS complaint_numbers_count_total,
    COUNT(DISTINCT complaint_number) AS complaint_numbers_count_unique
FROM molten-thought-441320-u6.Example.insurancecomplaints




-- to break out the unique complaint numbers and count the number of the related unique complaint numbers
SELECT 
    complaint_number,
    COUNT(complaint_number) AS complaint_numbers_count
FROM molten-thought-441320-u6.Example.insurancecomplaints
GROUP BY complaint_number
ORDER BY COUNT(complaint_number) DESC




--to find the complaint numbers that are already unique
SELECT
    complaint_number,
    COUNT(complaint_number) AS complaint_numbers_count,
FROM molten-thought-441320-u6.Example.insurancecomplaints
GROUP BY complaint_number
HAVING COUNT(complaint_number) = 1
ORDER BY COUNT(complaint_number) DESC




--to find the complaint numbers that are not unique and the related counts
SELECT
    complaint_number,
    COUNT(complaint_number) AS complaint_numbers_not_unique_count,
FROM molten-thought-441320-u6.Example.insurancecomplaints
GROUP BY complaint_number
HAVING COUNT(complaint_number) > 1
ORDER BY COUNT(complaint_number) DESC




--to confirm that there are no differences in the received date or closed date among the different parties
SELECT
    complaint_number,
    COUNT(complaint_number) AS complaint_numbers_not_unique_count,
    MIN(received_date) AS received_date_min,
    MAX(received_date) AS received_date_max,
    MIN(closed_date) AS closed_date_min,
    MAX(closed_date) AS closed_date_max
FROM molten-thought-441320-u6.Example.insurancecomplaints
GROUP BY complaint_number
HAVING COUNT(complaint_number) > 1
ORDER BY COUNT(complaint_number) DESC




--to confirm that there are no differences in the received date or closed date among the different parties continued, to research if there are any differences. confirmed that there are no differences since there is no data
SELECT
    complaint_number,
    COUNT(complaint_number) AS complaint_numbers_not_unique_count,
    MIN(received_date) AS received_date_min,
    MAX(received_date) AS received_date_max,
    MIN(closed_date) AS closed_date_min,
    MAX(closed_date) AS closed_date_max
FROM molten-thought-441320-u6.Example.insurancecomplaints
GROUP BY complaint_number
HAVING COUNT(complaint_number) > 1 AND MIN(closed_date) <> MAX(closed_date)
ORDER BY COUNT(complaint_number) DESC




--to review complaint number 17138 based on the number of counts for non unique complaint numbers
SELECT *
FROM molten-thought-441320-u6.Example.insurancecomplaints
WHERE complaint_number = 17138




--to review complaint number 116023 based on the number of counts for non unique complaint numbers
SELECT *
FROM molten-thought-441320-u6.Example.insurancecomplaints
WHERE complaint_number = 116023




-- to find the distinct complaint filed against by
SELECT DISTINCT complaint filed against_by
FROM molten-thought-441320-u6.Example.insurancecomplaints




-- to find the distinct complaint filed by
SELECT DISTINCT complaint_filed_by
FROM molten-thought-441320-u6.Example.insurancecomplaints




-- to find the complaint numbers and counts that the complaint filed by is null to identify the impact. to research if needed
SELECT complaint_number, 
    COUNT(complaint_number) AS complaint_number_count
    FROM molten-thought-441320-u6.Example.insurancecomplaints
GROUP BY complaint_number, complaint_filed_by
HAVING complaint_filed_by IS NULL




-- to find the distinct reason_complaint_filed
SELECT DISTINCT reason_complaint_filed
FROM molten-thought-441320-u6.Example.insurancecomplaints




-- to find the complaint numbers and counts that the reason_complaint_filed is null
SELECT complaint_number, 
    COUNT(complaint_number) AS count
    FROM molten-thought-441320-u6.Example.insurancecomplaints
GROUP BY complaint_number, reason_complaint_filed
HAVING reason_complaint_filed IS NULL
ORDER BY COUNT(complaint_number) DESC




-- to find the distinct complaint_type
SELECT DISTINCT complaint_type
FROM molten-thought-441320-u6.Example.insurancecomplaints




-- to find the complaint numbers and counts that the complaint_type is null
SELECT complaint_number, 
    COUNT(complaint_number) AS count
    FROM molten-thought-441320-u6.Example.insurancecomplaints
GROUP BY complaint_number, complaint_type
HAVING complaint_type IS NULL
ORDER BY COUNT(complaint_number) DESC




--to create a cte that removes duplicates since confirmed that only one record is needed FROM each complaint number. the complaint number can be used as the unique id
WITH InsComRowNum AS (
    SELECT *,
    ROW_NUMBER() OVER(PARTITION BY complaint_number) AS row_num
    FROM molten-thought-441320-u6.Example.insurancecomplaints
)
SELECT
    *,
    DATE_DIFF(closed_date, received_date, day) AS duration_days
FROM InsComRowNum
WHERE row_num = 1
ORDER BY complaint_number






--to create a table
CREATE TABLE molten-thought-441320-u6.Example.insurancecomplaintsupdated AS
WITH InsComRowNum AS (
    SELECT *,
    ROW_NUMBER() OVER(PARTITION BY complaint_number) AS row_num,
    DATE_DIFF(closed_date, received_date, day) AS duration_days,
    CASE 
      WHEN complaint_filed_against IN ('Blue Cross and Blue Shield of Texas, A Division of Health Care Service Corporation', 'BLUE CROSS AND BLUE SHIELD OF TEXAS, A DIVISION OF HEALTH CARE SERVICE CORPORATION', 'BLUE CROSS AND BLUE SHIELD OF TEXAS, A DIVISION OF HEALTH CARE SERVICE CORPORATION') THEN 'Anthem Blue Cross and Blue Shield'
      WHEN complaint_filed_against IN ('State Farm Lloyds', 'STATE FARM LLOYDS', 'State Farm Fire and Casualty Company', 'State Farm Mutual Automobile Insurance Company') THEN 'State Farm'
      WHEN complaint_filed_against IN ('UnitedHealthcare Insurance Company', 'United Healthcare Services, Inc.', 'UNITEDHEALTHCARE INSURANCE COMPANY', 'United HealthCare Services, Inc.') THEN 'United Healthcare'
      WHEN complaint_filed_against IN ('Humana Insurance Company', 'Humana Health Plan of Texas, Inc.') THEN 'Humana'
      WHEN complaint_filed_against IN ('ALLSTATE FIRE AND CASUALTY INSURANCE COMPANY', 'ALLSTATE VEHICLE AND PROPERTY INSURANCE COMPANY') THEN 'Allstate'
    ELSE INITCAP(complaint_filed_against) END AS complaint_filed_against_updated
    FROM molten-thought-441320-u6.Example.insurancecomplaints
)
SELECT
    *
FROM InsComRowNum
WHERE row_num = 1
ORDER BY complaint_number




--to test the new table
SELECT *
FROM molten-thought-441320-u6.Example.insurancecomplaintsupdated
LIMIT 10




--to drop a table
DROP TABLE molten-thought-441320-u6.Example.insurancecomplaintsupdated





--to count the different companies receiving complaints and find the percent of the total
SELECT 
        complaint_filed_against_updated AS company_receiving_complaint,
        COUNT(complaint_filed_against_updated) AS count_complaint,
        ROUND((COUNT(complaint_filed_against_updated)/ (SELECT COUNT(*)
FROM molten-thought-441320-u6.Example.insurancecomplaintsupdated)) * 100, 4) AS percent_total
FROM molten-thought-441320-u6.Example.insurancecomplaintsupdated
GROUP BY complaint_filed_against_updated
ORDER BY count(complaint_filed_against_updated) DESC
LIMIT 5




--to count the different complaint reasons and find the percent of the total
SELECT 
        reason_complaint_filed AS complaint_reason,
        COUNT(reason_complaint_filed) AS count_complaint,
        ROUND((COUNT(reason_complaint_filed)/ (SELECT COUNT(*)
FROM molten-thought-441320-u6.Example.insurancecomplaintsupdated)) * 100, 4) AS percent_total
FROM molten-thought-441320-u6.Example.insurancecomplaintsupdated
GROUP BY reason_complaint_filed
ORDER BY count(reason_complaint_filed) DESC
LIMIT 5



--to count the different complaint types and find the percent of the total
SELECT 
        complaint_type AS complaint_type,
        COUNT(complaint_type) AS count_complaint,
        ROUND((COUNT(complaint_type)/ (SELECT COUNT(*)
FROM molten-thought-441320-u6.Example.insurancecomplaintsupdated)) * 100, 4) AS percent_total
FROM molten-thought-441320-u6.Example.insurancecomplaintsupdated
GROUP BY complaint_type
ORDER BY count(complaint_type) DESC
LIMIT 5



--to count the different complaint_filed_by and find the percent of the total
SELECT 
        complaint_filed_by AS filed_by,
        COUNT(complaint_filed_by) AS count_complaint,
        ROUND((COUNT(complaint_filed_by)/ (SELECT COUNT(*)
FROM molten-thought-441320-u6.Example.insurancecomplaintsupdated)) * 100, 4) AS percent_total
FROM molten-thought-441320-u6.Example.insurancecomplaintsupdated
GROUP BY complaint_filed_by
ORDER BY count(complaint_filed_by) DESC
LIMIT 5



--to find the average of the duration of the tickets from start to close for each complaint_filed_by
SELECT 
        reason_complaint_filed AS complaint_reason,
        count(reason_complaint_filed) AS count_complaint,
        round(AVG(duration_days), 2) AS avg_time_days
FROM molten-thought-441320-u6.Example.insurancecomplaintsupdated
GROUP BY reason_complaint_filed
ORDER BY count(reason_complaint_filed) DESC
LIMIT 5




--to count the number of received complaints by year. To convert data type from date to string.
SELECT 
  SUM(CASE WHEN LEFT(CAST(received_date AS STRING),4) = '2022' THEN 1 ELSE 0 END) AS yearone_count,
  SUM(CASE WHEN LEFT(CAST(received_date AS STRING),4) = '2023' THEN 1 ELSE 0 END) AS yeartwo_count,
  SUM(CASE WHEN LEFT(CAST(received_date AS STRING),4) = '2024' THEN 1 ELSE 0 END) AS yearthree_count,
FROM molten-thought-441320-u6.Example.insurancecomplaintsupdated




--to count the different complaint reasons and find the percent of the total for a company receiving complaints
SELECT 
        reason_complaint_filed AS complaint_reason,
        COUNT(reason_complaint_filed) AS count_complaint,
        ROUND((COUNT(reason_complaint_filed)/ (SELECT COUNT(*)
FROM molten-thought-441320-u6.Example.insurancecomplaintsupdated WHERE complaint_filed_against_updated = 'Anthem Blue Cross and Blue Shield')) * 100, 4) AS percent_total
FROM molten-thought-441320-u6.Example.insurancecomplaintsupdated
WHERE complaint_filed_against_updated = 'Anthem Blue Cross and Blue Shield'
GROUP BY reason_complaint_filed
ORDER BY count(reason_complaint_filed) DESC


--to find the average of the duration of the tickets from start to close for each complaint_filed_by for a company receiving complaints
SELECT 
        reason_complaint_filed AS complaint_reason,
        COUNT(reason_complaint_filed) AS count_complaint,
        ROUND(AVG(duration_days), 2) AS avg_time_days
FROM molten-thought-441320-u6.Example.insurancecomplaintsupdated
WHERE complaint_filed_against_updated = 'Anthem Blue Cross and Blue Shield'
GROUP BY reason_complaint_filed
ORDER BY count(reason_complaint_filed) DESC


--To analyze the key words if needed
SELECT keywords
FROM molten-thought-441320-u6.Example.insurancecomplaintsupdated,
UNNEST(SPLIT(Keywords, ';')) AS keywords;
