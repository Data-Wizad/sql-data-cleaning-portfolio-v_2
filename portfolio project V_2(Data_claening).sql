select * from portfolio_pro_A..nhd_cleaning

---cleaning salesDate 

select saledateconverted, convert(date,SaleDate) from 
portfolio_pro_A..nhd_cleaning 

alter table portfolio_pro_A..nhd_cleaning 
add saledateconverted date 


update portfolio_pro_A..nhd_cleaning 
set saledateconverted  = convert(date,SaleDate)


--select saledateconverted 
--from portfolio_pro_A..nhd_cleaning


--- cleaning property address
 
select *  from 
portfolio_pro_A..nhd_cleaning 
where PropertyAddress is null


select a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, 
isnull(a.PropertyAddress,b.PropertyAddress) 
from 
portfolio_pro_A..nhd_cleaning as a 
join portfolio_pro_A..nhd_cleaning as b 
on a.ParcelID = b.ParcelID  
  and a.UniqueID <>  b.UniqueID  
where a.PropertyAddress is null



update a
set PropertyAddress  = isnull(a.PropertyAddress,b.PropertyAddress)
from portfolio_pro_A..nhd_cleaning as a 
join portfolio_pro_A..nhd_cleaning as b 
on a.ParcelID = b.ParcelID  
  and a.UniqueID <>  b.UniqueID  
where a.PropertyAddress is null

select PropertyAddress  from 
portfolio_pro_A..nhd_cleaning

select
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1) as  address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, len(PropertyAddress)) as address

from 
portfolio_pro_A..nhd_cleaning

--- Adding a new column 


alter table portfolio_pro_A..nhd_cleaning 
add propertysplitAddress nvarchar (255)


update portfolio_pro_A..nhd_cleaning 
set propertysplitAddress  = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1)


alter table portfolio_pro_A..nhd_cleaning 
add propertysplitcity nvarchar (255)
update portfolio_pro_A..nhd_cleaning 
set propertysplitcity  = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, len(PropertyAddress))


select * 

from 
portfolio_pro_A..nhd_cleaning



--- cleaning ownerAddress
select  parsename( replace (OwnerAddress, ',','.'),1),
 parsename( replace (OwnerAddress, ',','.'),2),
  parsename( replace (OwnerAddress, ',','.'),3)

from 
portfolio_pro_A..nhd_cleaning
--where OwnerAddress is not null


alter table portfolio_pro_A..nhd_cleaning 
add OwnersplitAddress nvarchar (255)
update portfolio_pro_A..nhd_cleaning 
set OwnersplitAddress  = parsename( replace (OwnerAddress, ',','.'),3)



alter table portfolio_pro_A..nhd_cleaning 
add Ownersplitstate nvarchar (255)
update portfolio_pro_A..nhd_cleaning 
set Ownersplitstate  = parsename( replace (OwnerAddress, ',','.'),1)



alter table portfolio_pro_A..nhd_cleaning 
add Ownersplitcity nvarchar (255)
update portfolio_pro_A..nhd_cleaning 
set Ownersplitcity = parsename( replace (OwnerAddress, ',','.'),2) 




select * 

from 
portfolio_pro_A..nhd_cleaning


--- changing Y and N to Yes or No in sold as vacant 
select distinct (SoldAsVacant),  count( SoldAsVacant)
from portfolio_pro_A..nhd_cleaning
group by SoldAsVacant 
order by 2


select SoldAsVacant 
, case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end 
from portfolio_pro_A..nhd_cleaning


update portfolio_pro_A..nhd_cleaning 
set  SoldAsVacant =  case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end 
 

 ---- removing duplicates
 with rownumCTE as (
 select *, 
 ROW_NUMBER () over (
 partition by ParcelID, PropertyAddress, SalePrice,SaleDate, LegalReference 
 order by UniqueID) as row_num
 from portfolio_pro_A..nhd_cleaning
)
delete 
from rownumCTE
where row_num = 1




--- selecting  all after removing duplicate 
 with rownumCTE as (
 select *, 
 ROW_NUMBER () over (
 partition by ParcelID, PropertyAddress, SalePrice,SaleDate, LegalReference 
 order by UniqueID) as row_num
 from portfolio_pro_A..nhd_cleaning
)
select *
from rownumCTE
where row_num = 1
order by PropertyAddress


---- deleting unused columns 
alter table portfolio_pro_A..nhd_cleaning 
drop  column OwnerAddress, TaxDistrict, PropertyAddress

alter table portfolio_pro_A..nhd_cleaning 
drop  column SaleDate






 select * from portfolio_pro_A..nhd_cleaning order  by ParcelID
