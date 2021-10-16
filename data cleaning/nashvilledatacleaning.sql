

-- cleaning dta in sql queries

select *
from housedatacleaning.dbo.nashvillehousing

--standardize date format

ALTER TABLE nashvillehousing
ADD SalesDateConverted Date;

Update nashvillehousing
SET SalesDateConverted = CONVERT(Date,SaleDate)

select SalesDateConverted
from housedatacleaning.dbo.nashvillehousing

--populate address data
select * 
from housedatacleaning.dbo.nashvillehousing
where PropertyAddress is null

select *
from housedatacleaning.dbo.nashvillehousing
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from housedatacleaning.dbo.nashvillehousing a
JOIN housedatacleaning.dbo.nashvillehousing b
     on a.parcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
SET PropertyAddress = ISNULL(a.propertyAddress,b.PropertyAddress)
from housedatacleaning.dbo.nashvillehousing a
JOIN housedatacleaning.dbo.nashvillehousing b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID]
where a.PropertyAddress is null

-- Break address into individual columns(address,city,state)

select PropertyAddress
from housedatacleaning.dbo.nashvillehousing

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)) as address
from housedatacleaning.dbo.nashvillehousing

-- remaove coma
select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as address
from housedatacleaning.dbo.nashvillehousing

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as address
, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) as address
from housedatacleaning.dbo.nashvillehousing

-- add address columns
ALTER TABLE housedatacleaning.dbo.nashvillehousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE housedatacleaning.dbo.nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE housedatacleaning.dbo.nashvillehousing
ADD PropertySplitCity Nvarchar(255);

Update housedatacleaning.dbo.nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))

select *
from housedatacleaning.dbo.nashvillehousing

--a simple way on owners address using parsename
select OwnerAddress
from housedatacleaning.dbo.nashvillehousing

select
PARSENAME(REPLACE(owneraddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from housedatacleaning.dbo.nashvillehousing

ALTER TABLE housedatacleaning.dbo.nashvillehousing
ADD ownerSplitAddress Nvarchar(255);

UPDATE housedatacleaning.dbo.nashvillehousing
SET ownerSplitAddress = PARSENAME(REPLACE(owneraddress,',','.'),3)

ALTER TABLE housedatacleaning.dbo.nashvillehousing
ADD ownerSplitCity Nvarchar(255);

Update housedatacleaning.dbo.nashvillehousing
SET ownerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE housedatacleaning.dbo.nashvillehousing
ADD ownerSplitstate Nvarchar(255);

Update housedatacleaning.dbo.nashvillehousing
SET ownerSplitstate = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select *
from housedatacleaning.dbo.nashvillehousing

--change Y and N to yes and no in "sold as vacant fields"

select Distinct(SoldAsVacant),Count(SoldAsVacant)
from housedatacleaning.dbo.nashvillehousing
group by SoldAsVacant
order by 2

select SoldASVacant
,CASE When SoldAsVacant = 'Y' THEN 'Yes'
      When SoldAsVacant = 'N' THEN 'NO'
	  ELSE SoldAsVacant
	  END
from housedatacleaning.dbo.nashvillehousing

--Remove duplicates
WITH RowNumCTE AS(
select *,
      ROW_NUMBER() OVER(
	  PARTITION BY ParcelID,
	               PropertyAddress,
				   SalePrice,
				   SaleDate,
				   LegalReference
				   ORDER BY
				     UNIQUEID
					 )row_num

from housedatacleaning.dbo.nashvillehousing
--order by ParcelID
)
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress

--delete used columns
select *
from housedatacleaning.dbo.nashvillehousing

ALTER TABLE housedatacleaning.dbo.nashvillehousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE housedatacleaning.dbo.nashvillehousing
DROP COLUMN SaleDate