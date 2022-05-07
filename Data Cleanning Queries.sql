/*

Cleaning Data in SQL Queries

*/

Select *
From PortfolioProject..NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select SaleDate
From PortfolioProject..NashvilleHousing

Select SaleDateConverted, Convert(Date, SaleDate)
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
     ON a.ParcelID = B.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
     ON a.ParcelID = B.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



--------------------------------------------------------------------------------------------------------------------------


-- Breaking out Address into Individual Columns (Address, City, State)



Select PropertyAddress
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySpiltAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySpiltAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySpiltCity Nvarchar(255);

Update NashvilleHousing
SET PropertySpiltCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing


Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSpiltAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSpiltAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSpiltCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSpiltCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSpiltState Nvarchar(255);

Update NashvilleHousing
SET OwnerSpiltState =PARSENAME(REPLACE(OwnerAddress,',','.'), 1)



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject..NashvilleHousing
GROUP BY SoldASVacant
ORDER BY 2

Select SoldAsVacant,
CASE When SoldAsVacant='Y' THEN 'Yes'
     When SoldAsVacant='N' THEN 'No'
	 Else SoldAsVacant
	 END
From PortfolioProject..NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant='Y' THEN 'Yes'
     When SoldAsVacant='N' THEN 'No'
	 Else SoldAsVacant
	 END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


WITH RowNumCTE AS(
Select *,
         ROW_NUMBER() OVER (
		 PARTITION BY ParcelID,
		              PropertyAddress,
					  SalePrice,
					  SaleDate,
					  LegalReference
					  ORDER BY
					     UniqueID
						 ) row_num
From PortfolioProject..NashvilleHousing
--order by ParcelID
)
DELETE
From RowNumCTE
where row_num > 1
--order by PropertyAddress


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

