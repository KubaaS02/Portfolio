SELECT *
FROM PortfolioProject..NashvillHousing

-- Changing date type

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject..NashvillHousing

UPDATE NashvillHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvillHousing
ADD SaleDateConverted Date;

UPDATE NashvillHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Populate Property Address data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvillHousing AS a 
JOIN PortfolioProject..NashvillHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvillHousing AS a 
JOIN PortfolioProject..NashvillHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Breaking out address into (Address, City, State)

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject..NashvillHousing

ALTER TABLE NashvillHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvillHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvillHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvillHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT
 PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM PortfolioProject..NashvillHousing

ALTER TABLE NashvillHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvillHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE NashvillHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvillHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvillHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvillHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

-- Change Y and N to Yes And No in 'Sold as Vacant' field

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject..NashvillHousing

UPDATE NashvillHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) AS row_num
FROM PortfolioProject..NashvillHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

-- Delete Unused Columns

ALTER TABLE PortfolioProject..NashvillHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvillHousing
DROP COLUMN SaleDate