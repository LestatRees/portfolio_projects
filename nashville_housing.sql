/*

Cleanind data in SQL queries

*/


--Changing Date Format

select
	*
from
	nashville_housing


--Standardize Date Format


select 
	saledate_converted
  , convert(date,saledate)
from
	nashville_housing


update nashville_housing
set SaleDate = convert(date,saledate)


alter table nashville_housing
add saledate_converted date;


update nashville_housing
set saledate_converted = convert(date,saledate)



--populate property address data


select 
	*
from
	nashville_housing
--where 
--	PropertyAddress is null
order by
	ParcelID


select 
	f.ParcelID
  , f.PropertyAddress
  , s.ParcelID
  , s.PropertyAddress
  , isnull(f.PropertyAddress, s.PropertyAddress)
from
	nashville_housing f 
		join nashville_housing s
			on f.ParcelID = s.ParcelID
			and f.[UniqueID ] <> s.[UniqueID ]
where
	f.PropertyAddress is null


update f
set PropertyAddress = isnull(f.PropertyAddress, s.PropertyAddress)
from
	nashville_housing f 
		join nashville_housing s
			on f.ParcelID = s.ParcelID
			and f.[UniqueID ] <> s.[UniqueID ]
where
	f.PropertyAddress is null


--seperating address into individual columns (address, city, state)


select 
	PropertyAddress
from
	nashville_housing
--where 
--	PropertyAddress is null
--order by
--	ParcelID

select
	substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 ) as address
  , substring(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , len(PropertyAddress)) as city
from
	nashville_housing


alter table nashville_housing
add property_split_address nvarchar(255);

update nashville_housing
set property_split_address = substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 )


alter table nashville_housing
add property_split_city nvarchar(255);

update nashville_housing
set property_split_city = substring(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , len(PropertyAddress))


--changing owner address to usuable columns


select
	OwnerAddress
from
	nashville_housing

select
	PARSENAME(replace(OwnerAddress, ',', '.') , 3) 
  , PARSENAME(replace(OwnerAddress, ',', '.') , 2)
  , PARSENAME(replace(OwnerAddress, ',', '.') , 1)
from
	nashville_housing
;



alter table nashville_housing
add owner_split_address nvarchar(255);

update nashville_housing
set owner_split_address = PARSENAME(replace(OwnerAddress, ',', '.') , 3)


alter table nashville_housing
add owner_split_city nvarchar(255);

update nashville_housing
set owner_split_city = PARSENAME(replace(OwnerAddress, ',', '.') , 2)

alter table nashville_housing
add owner_split_state nvarchar(255);

update nashville_housing
set owner_split_state = PARSENAME(replace(OwnerAddress, ',', '.') , 1)





--change Y and  N to yes and no in "sold as vacant" field


select distinct
	(SoldAsVacant) 
  , count(SoldAsVacant)
from
	nashville_housing
group by
	SoldAsVacant
order by
	2



select
	SoldAsVacant
  , case
		when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
	end
from
	nashville_housing

update nashville_housing
	set SoldAsVacant = 
		case
		when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
	end


--remove duplicates


with row_num_CTE as(
select
	*
  , ROW_NUMBER() over (
						partition by
							ParcelID
						  , PropertyAddress
						  , SalePrice
						  , SaleDate
						  , LegalReference
							order by
								UniqueID) row_num
from
	nashville_housing
)

delete
from
	row_num_CTE
where
	row_num > 1



--delete unused columns



select
	*
from
	nashville_housing


alter table nashville_housing
drop column
	OwnerAddress
  , TaxDistrict
  , PropertyAddress
  , SaleDate
