
--Format SaleDate column to date only
select SaleDate, convert(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

Alter table PortfolioProject.dbo.NashvilleHousing
alter column SaleDate date;

Update NashvilleHousing set SaleDate = convert(Date,SaleDate)


--Populate property address data based on parcelid reference
select *
from PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--Break out the address city state from the address field
select *
from PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

select substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address
, substring(PropertyAddress, charindex(',', PropertyAddress)+1, Len(PropertyAddress)) as City
from PortfolioProject.dbo.NashvilleHousing

Alter table PortfolioProject.dbo.NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1)

Alter table PortfolioProject.dbo.NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress)+1, Len(PropertyAddress))

select parsename(replace(OwnerAddress,',','.'),3)
, parsename(replace(OwnerAddress,',','.'),2)
, parsename(replace(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing

Alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress,',','.'),3)

Alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress,',','.'),2)

Alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress,',','.'),1)


--Clean soldasvacant column
select distinct(SoldAsVacant), count(soldasvacant)
from NashvilleHousing
Group by SoldAsVacant
order by 2

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	    when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	    when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end


--remove duplicates
with RowNumCTE AS (
select *, 
row_number() over (
partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference Order by UniqueID) row_num
from NashvilleHousing
)
delete from RowNumCTE where row_num > 1 


--delete unused columns
alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress
