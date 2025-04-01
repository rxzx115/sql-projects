-- to find the ranges in SaleDate and present this in various date formats

SELECT 
    MIN(SaleDate) AS sale_date_min, 
    MAX(SaleDate) AS sale_date_max, 
    DATE_DIFF(MAX(SaleDate), MIN(SaleDate), year) AS sale_date_range_year, 
    DATE_DIFF(MAX(SaleDate), MIN(SaleDate), month) AS sale_date_range_month,
    DATE_DIFF(MAX(SaleDate), MIN(SaleDate), day) AS sale_date_range_day, 
    DATETIME_DIFF(MAX(SaleDate), min(SaleDate), hour) AS range_sale_date_hour
FROM molten-thought-441320-u6.Example.nashvillehousing




-- to compare the date format on 'SaleDate' field to timestamp format and confirm that the SaleDate is in the date data format

SELECT SaleDate, CAST(SaleDate AS DATE) AS sale_date_day, CAST(SaleDate AS TIMESTAMP) AS sale_date_timestamp
FROM molten-thought-441320-u6.Example.nashvillehousing




-- to populate property address WHERE is null

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress) AS property_address_to_update
FROM molten-thought-441320-u6.Example.nashvillehousing a
JOIN molten-thought-441320-u6.Example.nashvillehousing b
ON a.ParcelID = b.ParcelID AND a.`UniqueID ` <> b.`UniqueID `
WHERE a.PropertyAddress IS NULL




-- to SELECT the `UniqueID ` field

SELECT `UniqueID `
FROM molten-thought-441320-u6.Example.nashvillehousing
LIMIT 10




-- to break out property address into individual columns (e.g., street, city)

SELECT 
    PropertyAddress,
    SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress,',') -1) AS property_street, 
    SUBSTRING(PropertyAddress, INSTR(PropertyAddress,',') +1, LENGTH(PropertyAddress)) AS property_city
FROM molten-thought-441320-u6.Example.nashvillehousing




-- to break out owner address into individual columns (e.g., street, city, state)

SELECT 
    OwnerAddress,
    SUBSTRING(OwnerAddress, 1, INSTR(OwnerAddress,',') -1) AS owner_street, 
    SUBSTRING(REPLACE(OwnerAddress, SUBSTRING(OwnerAddress, 1, INSTR(OwnerAddress,',') +1), ""), 1, INSTR(REPLACE(OwnerAddress, SUBSTRING(OwnerAddress, 1, INSTR(OwnerAddress,',') +1), ""),',') -1) AS owner_city,
   RIGHT(OwnerAddress, 2) AS owner_state
FROM molten-thought-441320-u6.Example.nashvillehousing




-- to confirm and change y and n to Yes and No in 'SoldAsVacant' field if needed or vice versa. Use Case When if needed.
-- note: Some platforms such as Google BigQuery converts the data type FROM string to boolean data type

SELECT DISTINCT SoldAsVacant
FROM molten-thought-441320-u6.Example.nashvillehousing

SELECT SoldAsVacant,
       CASE WHEN SoldAsVacant = TRUE THEN 'Yes'
            WHEN SoldAsVacant = FALSE THEN 'No'
            ELSE CAST(SoldAsVacant AS STRING) END SoldAsVacantUpdated
FROM molten-thought-441320-u6.Example.nashvillehousing




-- to filter out duplicates using a CTE

WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY `UniqueID `) AS row_num
    FROM molten-thought-441320-u6.Example.nashvillehousing
)
SELECT *
FROM RowNumCTE
WHERE row_num = 1
ORDER BY PropertyAddress




-- to populate the property address WHERE is null

SELECT a.*, 
    IFNULL(a.PropertyAddress, b.PropertyAddress) AS property_address_updated,
FROM molten-thought-441320-u6.Example.nashvillehousing a
LEFT JOIN molten-thought-441320-u6.Example.nashvillehousing b
ON a.ParcelID = b.ParcelID AND a.`UniqueID ` <> b.`UniqueID `




-- to query the data WHERE the property address is normalized, the addresses are cleaned up, and the duplicates are filtered out in one query

WITH CleanedAddresses AS (
    -- Clean up PropertyAddress and populate missing values
    SELECT
        a.*,
        COALESCE(a.PropertyAddress, b.PropertyAddress) AS property_address_updated
    FROM `molten-thought-441320-u6.Example.nashvillehousing` a
    LEFT JOIN `molten-thought-441320-u6.Example.nashvillehousing` b
    ON a.ParcelID = b.ParcelID AND a.`UniqueID ` <> b.`UniqueID `
),
ParsedAddresses AS (
    -- Parse addresses using SUBSTR and STRPOS with checks
    SELECT
        *,
        CASE
            WHEN STRPOS(property_address_updated, ',') > 0 THEN SUBSTR(property_address_updated, 1, STRPOS(property_address_updated, ',') - 1)
            ELSE property_address_updated END AS property_street,
        CASE
            WHEN STRPOS(property_address_updated, ',') > 0 AND STRPOS(SUBSTR(property_address_updated, STRPOS(property_address_updated, ',') + 1), ',') > 0 THEN TRIM(SUBSTR(SUBSTR(property_address_updated, STRPOS(property_address_updated, ',') + 1), 1, STRPOS(SUBSTR(property_address_updated, STRPOS(property_address_updated, ',') + 1), ',') - 1))
            ELSE NULL END AS property_city,
        CASE
            WHEN STRPOS(OwnerAddress, ',') > 0 THEN SUBSTR(OwnerAddress, 1, STRPOS(OwnerAddress, ',') - 1)
            ELSE OwnerAddress END AS owner_street,
        CASE
            WHEN STRPOS(OwnerAddress, ',') > 0 AND STRPOS(SUBSTR(OwnerAddress, STRPOS(OwnerAddress, ',') + 1), ',') > 0 THEN TRIM(SUBSTR(SUBSTR(OwnerAddress, STRPOS(OwnerAddress, ',') + 1), 1, STRPOS(SUBSTR(OwnerAddress, STRPOS(OwnerAddress, ',') + 1), ',') - 1))
            ELSE NULL END AS owner_city,
        TRIM(RIGHT(OwnerAddress, 2)) AS owner_state
    FROM CleanedAddresses
),
RowNumCTE AS (
    -- Remove duplicates
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY ParcelID, property_address_updated, SalePrice, SaleDate, LegalReference ORDER BY `UniqueID `
        ) AS row_num
    FROM ParsedAddresses
)
-- to select Final result: SELECT unique rows
SELECT
    *
FROM RowNumCTE
WHERE row_num = 1;


--To use improved code but with substr

WITH CleanedAddresses AS (
    -- Clean up PropertyAddress and populate missing values
    SELECT
        a.*,
        COALESCE(a.PropertyAddress, b.PropertyAddress) AS property_address_updated
    FROM `molten-thought-441320-u6.Example.nashvillehousing` a
    LEFT JOIN `molten-thought-441320-u6.Example.nashvillehousing` b
    ON a.ParcelID = b.ParcelID AND a.`UniqueID ` <> b.`UniqueID `
),
ParsedAddresses AS (
    SELECT 
    *,
    SUBSTRING(property_address_updated, 1, INSTR(property_address_updated,',') -1) AS property_street,
    SUBSTRING(property_address_updated, INSTR(property_address_updated,',') +1, LENGTH(property_address_updated)) AS property_city,
    SUBSTRING(OwnerAddress, 1, INSTR(OwnerAddress,',') -1) AS owner_street, 
    SUBSTRING(REPLACE(OwnerAddress, SUBSTRING(OwnerAddress, 1, INSTR(OwnerAddress,',') +1), ""), 1, INSTR(REPLACE(OwnerAddress, SUBSTRING(OwnerAddress, 1, INSTR(OwnerAddress,',') +1), ""),',') -1) AS owner_city,
    RIGHT(OwnerAddress, 2) AS owner_state,
    FROM CleanedAddresses
),
RowNumCTE AS (
    -- Remove duplicates
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY ParcelID, property_address_updated, SalePrice, SaleDate, LegalReference ORDER BY `UniqueID `) AS row_num
    FROM ParsedAddresses
)
-- Final result: SELECT unique rows
SELECT
    *
FROM RowNumCTE
WHERE row_num = 1;
