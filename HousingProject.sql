-----CLEANING DATA IN SQL QUERIES----

SELECT *
FROM housingdata;

-----STANDARDIZE DATE FORMAT

SELECT Saledate
FROM HousingData;

ALTER TABLE HousingData
ADD SaleDateConverted Date;
UPDATE HousingData
SET SaleDateConverted = CONVERT(DATE, SaleDate);


SELECT SaleDateConverted
FROM HousingData;


---------------POPULATE PROPERTY ADDRESS DATA
SELECT PropertyAddress, ParcelID
FROM HousingData
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;



SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
FROM HousingData a
JOIN HousingData b
	ON a.ParcelID = b.ParcelID
	AND A.[UniqueID ] <>  B.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET propertyaddress = ISNULL(a.propertyaddress, b.propertyaddress)
FROM HousingData a
JOIN HousingData b
	ON a.ParcelID = b.ParcelID
	AND A.[UniqueID ] <>  B.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


-----BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS(ADDRESS, CITY, STATE)
SELECT PropertyAddress
FROM HousingData;

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', Propertyaddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', Propertyaddress)+1, LEN(PropertyAddress)) as Address
from HousingData

ALTER TABLE HousingData
ADD PropertySplitAddress NVARCHAR(255);

UPDATE HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', Propertyaddress)-1)

ALTER TABLE HousingData
ADD PropertySplitCity NVARCHAR(255);

UPDATE HousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', Propertyaddress)+1, LEN(PropertyAddress))

---TO CHECK
SELECT *
FROM HousingData;

----ALTERNATIVE WAY

SELECT OwnerAddress
From HousingData;

SELECT 
PARSENAME(REPLACE(OwnerAddress,',' ,'.'),3),
PARSENAME(REPLACE(OwnerAddress,',' ,'.'),2),
PARSENAME(REPLACE(OwnerAddress,',' ,'.'),1)
from HousingData;


----------CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD

Select  DISTINCT(Soldasvacant), COUNT(Soldasvacant)
FROM HousingData
GROUP BY Soldasvacant
ORDER BY 2;

SELECT Soldasvacant,
CASE WHEN SoldasVacant = 'Y' THEN 'Yes'
	WHEN Soldasvacant = 'N' THEN 'No'
	ELSE SoldasVacant
	END
FROM HousingData;

UPDATE HousingData
SET SoldAsVacant = CASE WHEN SoldasVacant = 'Y' THEN 'Yes'
	WHEN Soldasvacant = 'N' THEN 'No'
	ELSE SoldasVacant
	END
FROM HousingData;


SELECT Soldasvacant
from HousingData;


------REMOVE DUPLICATES

WITH RownumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY PARCELID,
				Propertyaddress,
				saleprice,
				saledate,
				Legalreference
				ORDER BY 
					UniqueID
					) row_num
FROM HousingData
)
DELETE
FROM RownumCTE
WHERE row_num > 1;


----DELETE UNUSED COLUMNS

SELECT *
FROM HousingData;

ALTER TABLE Housingdata
DROP COLUMN Owneraddress, TaxDistrict, PropertyAddress;

ALTER TABLE Housingdata
DROP COLUMN Saledate;