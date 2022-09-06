-- PropertyAddress column has NULLs

SELECT COUNT(*)
FROM Project2NashvilleHousing..NashvilleHousing
WHERE PropertyAddress IS NULL

-- ParcelID will always have the same PropertyAddress. So if the ParcelID is duplicated in rows we can populate the missing PropertyAddress
-- Joined table to view ParcelID and PropertyAddress

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM Project2NashvilleHousing..NashvilleHousing a
JOIN Project2NashvilleHousing..NashvilleHousing b
   ON a.ParcelID = b.parcelID
   AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL


-- PropertyAddress always matches the ParcelID but it’s not populating in duplicate ParcelIDs
-- Made temp column ISNULL that is then populated with

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Project2NashvilleHousing..NashvilleHousing a
JOIN Project2NashvilleHousing..NashvilleHousing b
   ON a.ParcelID = b.parcelID
   AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

-- Update table with final results
 
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Project2NashvilleHousing..NashvilleHousing a
JOIN Project2NashvilleHousing..NashvilleHousing b
   ON a.ParcelID = b.parcelID
   AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL
Check for NULLs.. Returned 0 NULLs for PropertyAddress column 
SELECT COUNT(*)
FROM Project2NashvilleHousing..NashvilleHousing
WHERE PropertyAddress IS NULL

-- PropertyAddress column has: address, city
-- We want to separate the address from the city into separate columns using the delimiter (comma)
-- Use SUBSTRING + CHARINDEX, the following to separate the Address from the City. Results show in temp column again
-- SUBTRING pulls string from column, “PropertyAddress”, starting from position 1, stopping at CHARINDEX (which is designated at ',')

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM Project2NashvilleHousing..NashvilleHousing
 
-- Make permanent columns using ALTER TABLE and SET
ALTER TABLE NashvilleHousing
Add PropertySplitAddress NVARCHAR(255);
 
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)
 
 
ALTER TABLE NashvilleHousing
Add PropertySplitCity NVARCHAR(255);
 
UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))
 
-- Checked to see if it was added correctly

SELECT PropertySplitAddress, PropertySplitCity
FROM Project2NashvilleHousing..NashvilleHousing

-- OwnerAddress column has: address, city, state
-- Another way to split the STRING into separate columns aside from SUBSTRING is PARSENAME. 

SELECT
PARSENAME(OwnerAddress,1)
FROM Project2NashvilleHousing..NashvilleHousing

-- PARSENAME only uses periods. Above query in this instance doesn’t work because our columns have commas so we replace them first

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Project2NashvilleHousing..NashvilleHousing


-- The numbers refer to the chunk of string to be pulled,
-- Officially add the new columns and corresponding values

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);
 
ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);
 
ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);
 
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
 
UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
 
UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Verify change to table

SELECT OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM Project2NashvilleHousing..NashvilleHousing

-- SoldAsVacant column contains: Yes, Y, No, N. 

SELECT DISTINCT(SoldAsVacant), COUNT(*)
FROM Project2NashvilleHousing..NashvilleHousing
GROUP BY SoldAsVacant

-- We want to change the Y and N results to group with Yes and No using a case statement 

SELECT SoldAsVacant,
CASE   
   WHEN SoldAsVacant = 'Y' THEN 'Yes'
   WHEN SoldAsVacant = 'N' THEN 'No'
   ELSE SoldAsVacant
END
FROM Project2NashvilleHousing..NashvilleHousing

-- Officially update

UPDATE NashvilleHousing
SET SoldAsVacant =
CASE   
   WHEN SoldAsVacant = 'Y' THEN 'Yes'
   WHEN SoldAsVacant = 'N' THEN 'No'
   ELSE SoldAsVacant
END
Check update
SELECT DISTINCT(SoldAsVacant), COUNT(*)
FROM Project2NashvilleHousing..NashvilleHousing
GROUP BY SoldAsVacant

-- Remove columns (standard practice: do not delete data from database)

ALTER TABLE Project2NashvilleHousing..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate