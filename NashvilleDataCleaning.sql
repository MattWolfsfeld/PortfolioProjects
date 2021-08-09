/*

Cleaning Data in SQL Queries
*/

select *
from Portfolio.dbo.NashvilleHousing

--------------------------------------------------------------------------------------
--Standardize Date Format

select SaleDateConverted, convert(Date,SaleDate)
from Portfolio.dbo.NashvilleHousing

Update NashvilleHousing
set SaleDate = convert (Date,SaleDate)

alter table NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
set SaleDateConverted = convert (Date,SaleDate)
--------------------------------------------------------------------------------------
--Populate Property Address Data

select PropertyAddress
from Portfolio.dbo.NashvilleHousing
Where PropertyAddress is null 

select *
from Portfolio.dbo.NashvilleHousing
Where PropertyAddress is null

select *
from Portfolio.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from Portfolio.dbo.NashvilleHousing a
Join Portfolio.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID]<>b.[UniqueID]
where a.PropertyAddress is null


update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from Portfolio.dbo.NashvilleHousing a
Join Portfolio.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID]<>b.[UniqueID]
where a.PropertyAddress is null

-------------------------------------------------------------------------------------------------------
--Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from Portfolio.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID


select
substring(PropertyAddress,1, charindex(',',PropertyAddress)-1)as Address
, substring(PropertyAddress,charindex(',',PropertyAddress)+1, LEN(PropertyAddress))as CityAddress
from Portfolio.dbo.NashvilleHousing

alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255)

Update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress,1, charindex(',',PropertyAddress)-1)

alter table NashvilleHousing
Add PropertySplitCity nvarchar(255)

Update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress,charindex(',',PropertyAddress)+1, LEN(PropertyAddress))

--select *
--from Portfolio.dbo.NashvilleHousing


select OwnerAddress
from Portfolio.dbo.NashvilleHousing

select
parsename(OwnerAddress,1)
from Portfolio.dbo.NashvilleHousing

select
parsename(Replace(OwnerAddress,',','.'),3)
,parsename(Replace(OwnerAddress,',','.'),2)
,parsename(Replace(OwnerAddress,',','.'),1)
from Portfolio.dbo.NashvilleHousing


alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Update NashvilleHousing
set OwnerSplitAddress = parsename(Replace(OwnerAddress,',','.'),3)

alter table NashvilleHousing
Add OwnerSplitCity nvarchar(255)

alter table NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update NashvilleHousing
set OwnerSplitCity = parsename(Replace(OwnerAddress,',','.'),2)

Update NashvilleHousing
set OwnerSplitState = parsename(Replace(OwnerAddress,',','.'),1)

--select *
--from Portfolio.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold As Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from Portfolio.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant
,	CASE When SoldAsVacant = 'Y' then 'Yes'
		When SoldAsVacant = 'N' then 'No'
		Else SoldAsVacant
		End
from Portfolio.dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
		When SoldAsVacant = 'N' then 'No'
		Else SoldAsVacant
		End
------------------------------------------------------------------------------------------------------------
--Remove Duplicates
with RowNumCTE As (
select *,
	Row_number() Over(
	Partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by
					UniqueID
					) row_num
					
from Portfolio.dbo.NashvilleHousing
--Order by ParcelID
)
select *
from RowNumCTE
Where row_num > 1
Order by PropertyAddress

----------------------------------------------------------------------------------------------------------------------
--Delete unused columns

select *
from Portfolio.dbo.NashvilleHousing

Alter Table Portfolio.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table Portfolio.dbo.NashvilleHousing
drop column SaleDate