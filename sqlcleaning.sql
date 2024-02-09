select * 
from portfolioproject.dbo.nashville

--standardize date format

select saledateconverted, convert(date, saledate)
from portfolioproject.dbo.nashville

update nashville
set saledate= convert(date, saledate)

alter table nashville
add saledateconverted date;

update nashville
set saledateconverted = convert(date, saledate)

-- populate property address
select propertyaddress
from portfolioproject.dbo.nashville
where propertyaddress is null

select a.parcelid,a.propertyaddress,b.parcelid,b.propertyaddress, isnull(a.propertyaddress,b.propertyaddress)
from portfolioproject.dbo.nashville a
join portfolioproject.dbo.nashville b
on a.parcelid= b.parcelid
and a.uniqueid<>b.uniqueid
where a.propertyaddress is null

update a
set propertyaddress=isnull(a.propertyaddress,b.propertyaddress)
from portfolioproject.dbo.nashville a
join portfolioproject.dbo.nashville b
on a.parcelid= b.parcelid
and a.uniqueid<>b.uniqueid

select *
from portfolioproject.dbo.nashville

--breaking up address into diff columns
select propertyaddress
from portfolioproject.dbo.nashville

select 
substring( propertyaddress,1,charindex(',',propertyaddress)-1) as address,
substring( propertyaddress,charindex(',',propertyaddress)+1, len(propertyaddress)) as address
from portfolioproject.dbo.nashville

alter table nashville
add propertysplitaddresss nvarchar(255);

update nashville
set propertysplitaddresss = substring( propertyaddress,1,charindex(',',propertyaddress)-1)

alter table nashville
add propertysplitcityy nvarchar(255);

update nashville
set  propertysplitcityy = substring(propertyaddress,charindex(',',propertyaddress)+1, len(propertyaddress))

select *
from portfolioproject.dbo.nashville


--alternate method
select owneraddress
from portfolioproject.dbo.nashville
select
parsename(replace(owneraddress,',','.'),3),
parsename(replace(owneraddress,',','.'),2),
  parsename(replace(owneraddress,',','.'),1)
 from portfolioproject.dbo.nashville

 alter table nashville
add ownersplitaddresss nvarchar(255);

update nashville
set  ownersplitaddresss = parsename(replace(owneraddress,',','.'),3)

alter table nashville
add  ownersplitcityy nvarchar(255);

update nashville
set   ownersplitcityy =parsename(replace(owneraddress,',','.'),2)

 alter table nashville
add ownersplitstate nvarchar(255);

update nashville
set  ownersplitstate = parsename(replace(owneraddress,',','.'),1)

select *
from portfolioproject.dbo.nashville


--change y as yes and n as no in sold vacant

select distinct (soldasvacant), count(soldasvacant)
from portfolioproject.dbo.nashville
group by soldasvacant
order by 2

select soldasvacant ,
CASE
when soldasvacant='y' then 'yes'
when soldasvacant='n' then 'no'
else soldasvacant
end
from portfolioproject.dbo.nashville

update nashville
set soldasvacant =
CASE
when soldasvacant='y' then 'yes'
when soldasvacant='n' then 'no'
else soldasvacant
end
from portfolioproject.dbo.nashville

--remove duplicates
with rowcte as(
select *,
row_number() over (
partition by parcelid,
propertyaddress, saleprice, saledate,legalreference
order by uniqueid
) row_num
from portfolioproject.dbo.nashville
)

select * from rowcte 
where row_num>1
order by propertyaddress


--delete unused columns

select * 
from portfolioproject.dbo.nashville

alter table portfolioproject.dbo.nashville
drop column owneraddress, taxdistrict,propertyaddress