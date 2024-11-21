Select * 
From PortfolioProject.dbo.DogBreeds

------------------------------------------------------------------------------------------------------------------
-- 1. What are the top 10 countries where the largest number of breeds come from?
Select TOP 10 COUNT(Breed) as BreedCount, Country_of_Origin
From PortfolioProject.dbo.DogBreeds
Group by Country_of_Origin
Order by BreedCount DESC

------------------------------------------------------------------------------------------------------------------
-- Now we want analyze the Common Health Problems column.
-- To do so, we have to break it out into 3 individual columns. We can achieve that by using Parsename.

-- Firstly, we will add new columns into the table.

ALTER TABLE PortfolioProject.dbo.DogBreeds
Add Health_Problem_1 Nvarchar(255);

ALTER TABLE PortfolioProject.dbo.DogBreeds
Add Health_Problem_2 Nvarchar(255);

ALTER TABLE PortfolioProject.dbo.DogBreeds
Add Health_Problem_3 Nvarchar(255);

-- Now we can update these columns with the new values. Parsename works only when '.' is the delimiter so we have to replace ',' in the Common_Health_Problems columns. 

Update PortfolioProject.dbo.DogBreeds
Set Health_Problem_1 = PARSENAME(REPLACE(Common_Health_Problems, ',', '.') ,3)

Update PortfolioProject..DogBreeds
Set Health_Problem_2 = PARSENAME(REPLACE(Common_Health_Problems, ',', '.') ,2)

Update PortfolioProject.dbo.DogBreeds
Set Health_Problem_3 = PARSENAME(REPLACE(Common_Health_Problems, ',', '.') ,1)


-- Delete spaces at the beginning of rows in Health_Problem_2 and Health_Problem_3

UPDATE PortfolioProject.dbo.DogBreeds 
SET  Health_Problem_2 = TRIM(Health_Problem_2)

UPDATE PortfolioProject.dbo.DogBreeds 
SET  Health_Problem_3 = TRIM(Health_Problem_3)

-- Let's unify the naming convention first since health problems in the Health_Problem_1 are in upper case

Select LOWER(Health_Problem_1)
From PortfolioProject.dbo.DogBreeds

-- Let's update the table now

Update PortfolioProject.dbo.DogBreeds
SET Health_Problem_1 = LOWER(Health_Problem_1)

-- Assuming that "Eye issues" are the exact health problem as "Eye problems", let's unify those entries in all 3 columns

Update PortfolioProject.dbo.DogBreeds
SET Health_Problem_1 = Case When Health_Problem_1 = 'eye issues' THEN 'eye problems'
							Else Health_Problem_1


Update PortfolioProject.dbo.DogBreeds
SET Health_Problem_2 = Case When Health_Problem_2 = 'eye issues' THEN 'eye problems'
							Else Health_Problem_2


Update PortfolioProject.dbo.DogBreeds
SET Health_Problem_3 = Case When Health_Problem_3 = 'eye issues' THEN 'Eye problems'
							Else Health_Problem_3
						End

-- Deleting Common_Health_Problems columnn since we created individual columns already

Alter Table PortfolioProject.dbo.DogBreeds
Drop Column Common_Health_Problems

-- 2. What are the most common health problems?

Select Health_Problem, COUNT(*) AS TotalCount
From (
Select Health_Problem_1 AS Health_Problem From PortfolioProject.dbo.DogBreeds
UNION ALL
Select Health_Problem_2 AS Health_Problem From PortfolioProject.dbo.DogBreeds
UNION ALL
Select Health_Problem_3 AS Health_Problem From PortfolioProject.dbo.DogBreeds
) AS All_Problems
Group by Health_Problem
Order by TotalCount DESC

------------------------------------------------------------------------------------------------------------------

-- 3. Counting average longevity of a specific breed from the given interval. Then counting average longevity for all breeds

Select 
    ROUND(AVG((CAST(LEFT(Longevity_yrs, CHARINDEX('-', Longevity_yrs) - 1) as Float) +
         CAST(RIGHT(Longevity_yrs, LEN(Longevity_yrs) - CHARINDEX('-', Longevity_yrs)) as Float)) / 2), 2) AS Average_Longevity
From PortfolioProject.dbo.DogBreeds
Where Longevity_yrs LIKE '%-%';

-- 4. Counting average height of a specific breed from the given interval. Then counting average height for all breeds

Select 
    ROUND(AVG((CAST(LEFT(Height_in, CHARINDEX('-', Height_in) - 1) as Float) +
         CAST(RIGHT(Height_in, LEN(Height_in) - CHARINDEX('-', Height_in)) as Float)) / 2), 2) AS Average_Height
From PortfolioProject.dbo.DogBreeds
Where Height_in LIKE '%-%';


