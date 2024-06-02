Select*
From PortfolioProjectDataCleaning..NashvilleHousing

--STANDARDIZE DATE FORMAT
Select SaleDateConverted,CONVERT(Date,SaleDate)
From PortfolioProjectDataCleaning..NashvilleHousing

--Update Nashvillehousing
--Set SaleDate = Covert(Date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date, SaleDate)



--Populate Property Adress data
Select PropertyAddress
From PortfolioProjectDataCleaning..NashvilleHousing
--Where PropertyAddress is Null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjectDataCleaning..NashvilleHousing a
Join PortfolioProjectDataCleaning..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <>b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjectDataCleaning..NashvilleHousing a
Join PortfolioProjectDataCleaning..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




--Breaking Address into Individual Columns(Address,City,State)
--using Substring
Select PropertyAddress 
From PortfolioProjectDataCleaning..NashvilleHousing
--Where PropertyAddress is Null
--Order by ParcelID


Select
SUBSTRING (PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress)) as City
From PortfolioProjectDataCleaning..NashvilleHousing 

Alter Table NashvilleHousing --Execute the AlterTable First
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING (PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress))


Select*
From PortfolioProjectDataCleaning..NashvilleHousing


--Split Owner Address using
Select OwnerAddress
From PortfolioProjectDataCleaning..NashvilleHousing

--With ParseName (works with period not comma. replace comma with period. also it works barkwards
Select
PARSENAME(Replace(OwnerAddress, ',','.'),3),
PARSENAME(Replace(OwnerAddress, ',','.'),2),
PARSENAME(Replace(OwnerAddress, ',','.'),1)
From PortfolioProjectDataCleaning..NashvilleHousing

Alter Table NashvilleHousing --Execute the AlterTable First
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',','.'),3)

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',','.'),2)

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',','.'),1)


Select*
from PortfolioProjectDataCleaning..NashvilleHousing




--CHANGE Y AND N TO YES AND NO IN "SOLD AS VACCANT" COLUMN
Select Distinct (SoldAsVacant), COUNT(SoldAsVacant)			---Use to check the distinct values in that column and thier count
From PortfolioProjectDataCleaning..NashvilleHousing 
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
	Case When SoldAsVacant = 'Y' then 'Yes'
		When SoldAsVacant = 'N' then 'Yes'
		Else SoldAsVacant
		End
From PortfolioProjectDataCleaning..NashvilleHousing


Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' then 'Yes'
		When SoldAsVacant = 'N' then 'Yes'
		Else SoldAsVacant
		End

Select Distinct (SoldAsVacant), COUNT(SoldAsVacant)			
From PortfolioProjectDataCleaning..NashvilleHousing 





--REMOVE DUPLICATES
With RowNumCTE as(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
					UniqueID
					) Row_num
 From PortfolioProjectDataCleaning..NashvilleHousing
 )


 Delete
From RowNumCTE
Where Row_num > 1

Select*
From PortfolioProjectDataCleaning..NashvilleHousing



--DELETE UNUSED COLUMNS
Alter Table PortfolioProjectDataCleaning..NashvilleHousing
Drop Column OwnerAddress,TaxDistrict, PropertyAddress, SaleDate

Select*
From PortfolioProjectDataCleaning..NashvilleHousing

