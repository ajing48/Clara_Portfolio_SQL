-- Cleaning Data in SQL queries-- 

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing

-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate) 
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate) 

Alter TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing 
SET SaleDateConverted=CONVERT(Date,SaleDate)

-------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress is null  --There are 29 null value. 

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress is null -- Not only property, but also other columns has null value. 


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
-- WHERE PropertyAddress is null 
order by ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID] <>b.[UniqueID] -- This means parcelID is same but not the exact same row
WHERE a.PropertyAddress is null

Update a
SET PropertyAddress= ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID] <>b.[UniqueID]
WHERE a.PropertyAddress is null

-------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

-- 1. Manipulate PropertyAddress 
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
FROM PortfolioProject.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)) as Address, CHARINDEX(',',PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing


SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
FROM PortfolioProject.dbo.NashvilleHousing


-- Create seperated table and filling process 
Alter TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing 
SET PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing 
SET PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


 
-- 2. Manipulate OwnerAddress
SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing 

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)  -- Parcename is useful with period or 
, PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing


-- Actual filling process
Alter TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing 
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)


Alter TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing 
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)


Alter TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing 
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)



SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in 'Sold as Vacant' field

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2  -- There are four value: Yes, No, Y, N 


SELECT SoldAsVacant, -- Original data
	   CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	   WHEN SoldAsVacant='N' THEN 'No'
	   ELSE SoldAsVacant END  -- Converted data using CASE WHEN 
FROM PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	   WHEN SoldAsVacant='N' THEN 'No'
	   ELSE SoldAsVacant END 
FROM PortfolioProject.dbo.NashvilleHousing  -- The number of value is reduced. 



----------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	   ROW_NUMBER() OVER(
	   PARTITION BY ParcelID, PropertyAddress,SalePrice,SaleDate, LegalReference
	   ORDER BY UniqueID) row_num
FROM PortfolioProject.dbo.NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE row_num>1 -- Remove duplicated value. 



WITH RowNumCTE AS(
SELECT *,
	   ROW_NUMBER() OVER(
	   PARTITION BY ParcelID, PropertyAddress,SalePrice,SaleDate, LegalReference
	   ORDER BY UniqueID) row_num
FROM PortfolioProject.dbo.NashvilleHousing
)

SELECT *
FROM RowNumCTE
WHERE row_num>1
ORDER BY PropertyAddress


----------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns
-- : I already splited the PropertyAddress and OwnerAddress into City and State, the original address information is no longer useful. 

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate