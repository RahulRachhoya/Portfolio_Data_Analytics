
/*
	Cleaning Data in SQL Queries
*/

select * from Housing

-----------------------------------------------------------------

--Standard Date Format

select SaleDate 
from Housing

alter table housing
add SaleDate_Converted date

update Housing
set SaleDate_Converted = convert(date,SaleDate)

select SaleDate_Converted from Housing

-----Populate Property Address Data------


select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from Housing a Join Housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Housing a Join Housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-----Breaking out Address into Individual Column (Address , City, State)--------------------

select PropertyAddress,
	SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as addre,
	SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
from Housing

alter table housing
add address nvarchar(255);

update Housing
set address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table housing
add city nvarchar(255)

update Housing
set city = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
	
select * from Housing


-----For delimeted Specific Value 

select PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	   PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	   PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from Housing


alter table housing
add Owner_Split_address nvarchar(255);

alter table housing
add Owner_Split_City nvarchar(255);

alter table housing
add Owner_Split_State nvarchar(255);

update Housing
set Owner_Split_address = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	Owner_Split_City = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	Owner_Split_State = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select * from Housing



-----Change Y and N to Yes and No in sold as Vacant Field

select distinct(SoldAsVacant), count(SoldAsVacant) from Housing
group by SoldAsVacant
order by SoldAsVacant


select SoldAsVacant,
		case when SoldAsVacant = 'Y' then 'Yes'
			 when SoldAsVacant = 'N' then 'No'
			 else SoldAsVacant
			 end
from Housing


update Housing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
				   end


------------Remove Duplicates----------------
with RowNumCTE as (
select *, 
	ROW_NUMBER() Over(
	Partition by parcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by UniqueID
					 ) rowNum
from Housing
)
select * from RowNumCTE
where rowNum>1
/*Delete from RowNumCTE
where rowNum > 1
--order by PropertyAddress
*/


--------------Delete Unused Columns------------------

select * from Housing

alter table housing
drop column OwnerAddress,PropertyAddress,TaxDistrict,SaleDate