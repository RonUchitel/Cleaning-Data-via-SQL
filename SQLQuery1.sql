SELECT *
FROM NashvilleHousing..Housing

--Converting SaleDate Column to date format
SELECT SaleDate, CONVERT(date, SaleDate)
FROM NashvilleHousing..Housing

ALTER TABLE NashvilleHousing..Housing
ADD SaleDateFixed Date

Update NashvilleHousing..Housing
SET SaleDateFixed = CONVERT(date, SaleDate)
---------------------------------------------------------------------------------------------

--Fill Nulls Values in PropertyAdress Calumn
SELECT *
FROM NashvilleHousing..Housing
WHERE PropertyAddress is null

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing..Housing a
JOIN NashvilleHousing..Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing..Housing a
JOIN NashvilleHousing..Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null
---------------------------------------------------------------------------------------------

--Breaking Out Address Into Individual Columns: Address, City
SELECT PropertyAddress
FROM NashvilleHousing..Housing

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM NashvilleHousing..Housing

ALTER TABLE NashvilleHousing..Housing
ADD PropertySplitAddress Nvarchar(255)
Update NashvilleHousing..Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing..Housing
ADD PropertySplitCity Nvarchar(255)
Update NashvilleHousing..Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
---------------------------------------------------------------------------------------------

--Owner address Split: Address, City, State
ALTER TABLE NashvilleHousing..Housing
ADD OwnerSplitAdress Nvarchar(255)
Update NashvilleHousing..Housing
SET OwnerSplitAdress = PARSENAME (REPLACE(OwnerAddress,',', '.'),3)

ALTER TABLE NashvilleHousing..Housing
ADD OwnerSplitCity Nvarchar(255)
Update NashvilleHousing..Housing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress,',', '.'),2)

ALTER TABLE NashvilleHousing..Housing
ADD OwnerSplitState Nvarchar(255)
Update NashvilleHousing..Housing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress,',', '.'),1)
---------------------------------------------------------------------------------------------

--Change Y and N to Yes and No
SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant 
		END
FROM NashvilleHousing..Housing

UPDATE NashvilleHousing..Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant 
		END
---------------------------------------------------------------------------------------------

--Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference
	ORDER BY UniqueID
	) row_num
FROM NashvilleHousing..Housing)

DELETE
FROM RowNumCTE
where row_num>1
---------------------------------------------------------------------------------------------

--Delete Unused Columns
ALTER TABLE NashvilleHousing..Housing
DROP COLUMN TaxDistrict

SELECT *
FROM NashvilleHousing..Housing
---------------------------------------------------------------------------------------------