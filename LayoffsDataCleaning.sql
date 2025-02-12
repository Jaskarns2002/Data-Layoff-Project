 -- Data Cleaning 
 
 -- 1. Remove Duplicates
 -- 2. Standarize the Data 
 -- 3. Null values or Blank Values
 -- 4. Remove any colums  or rows
 
 Create table layoffs_staging
 like layoffs;
 
 Insert layoffs_staging        
 select *
 from layoffs;
 
 Select *
 from layoffs_staging;
 
 -- 1. Remove Duplicates -----------------------------------------------------
  
  /* This Cte is searching for dulpicates using a cte        */
 with Duplicate_cte as 
 (
  Select *,
row_number() over(partition by company,Location, industry,total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
 from layoffs_staging
 )
 Select *
 from Duplicate_cte
 where row_num > 1;
 
 /*testing to confirm the duplicate is actual duplicate */
 select *
 from layoffs_staging 
 where company = 'cazoo';
 
/* Creating a staging table that allows us to look at dulpciates and delete  */ 
 CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` text,
  `row_num` Int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


  Select *
 from layoffs_staging2;
 -- inserting the layoff table that contains row_num column 
 Insert into layoffs_staging2
 Select *,
row_number() over(partition by company,Location, industry,total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
 from layoffs_staging;
 
-- Deleting the Duplicate's 
Delete
 from layoffs_staging2
 where row_num > 1;
 -- checking 
Select *
 from layoffs_staging2
where row_num>1;
 -- 2. Standardizing data ---------------------------

/* Triming the company colum */ 
Select company, Trim(company)
 from layoffs_staging2;
 
 update layoffs_staging2
 set company = Trim(company);
 
 /* Cleaning industry column  */
 Select  *
 from layoffs_staging2
 where industry like 'Crypto%';

/* updating the crypto industry, so all of them are the same name*/
update layoffs_staging2
Set industry = 'Crypto'
where industry like 'Crypto%';

/* Doubkle checking if crypto industry has been updates*/
Select distinct industry	
from layoffs_staging2;

/* fixing any country column data*/
Select distinct country
from layoffs_staging2;
/*removing extra period end of the country name */
update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'united states%';

/*changing/updating the date column to date format*/
 Select `date`
 From layoffs_staging2;
 
 /*updating the date column to date format*/
 update layoffs_staging2
 set `date` = str_to_date(`date`, '%m/%d/%Y');

/* Ran into a error, so I had to update the none values into null in order to change date format*/
UPDATE layoffs_staging2
SET `date` = NULL 
WHERE `date` = 'None';

/* Changing the data type for the date colum to date */
Alter Table layoffs_staging2 
Modify Column `date` Date;

-------------- 3. Null values or Blank Values ------------------------------

Select *
from layoffs_staging2
where total_laid_off is NULL
and percentage_laid_off is null;
 
 select  distinct industry
 from layoffs_staging2
 where industry is null or industry = '';
 
 /* Replace all none to nulls for industry column*/
UPDATE layoffs_staging2
SET industry = NULL WHERE industry = 'None' ;

 /* Replace all none to nulls for funds_raised_millions column*/
UPDATE layoffs_staging2
SET funds_raised_millions = NULL WHERE funds_raised_millions= 'None';

/* Find null or blank values in the table*/
select *
from layoffs_staging2
where industry is null 
or industry ='';

/*populating the missing data*/
select *
from layoffs_staging2
where company like 'airbnb';

/* updadting the blank values to null*/
update layoffs_staging2
set industry = null 
where industry = '';

/* using join table to see all company that have null value and not null value, (populated rows)*/
Select *
from layoffs_staging2 t1
join layoffs_staging2 t2 
	on t1.company = t2.company 
    and t1.location = t2.location
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;


/*udating the industry by using joins and using popualed rows to fill in the nulls*/
update layoffs_staging2 t1
join layoffs_staging2 t2 
	on t1.company = t2.company
set t1.industry = t2.industry
where (t1.industry is null )
and (t2.industry is not null);

/* check for any null in the industry column (bally's has null but doesn't have a populated row)*/
select *
from layoffs_staging2
where industry is null 
or industry ='';

/* check comapny that have no layoff information or value. */
select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;
-------------------- 4. Removing any Columns or Rows -------------------------------

/*Delete company that have no values or information on layoffs from the staging table*/
Delete 
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;


/*Checking any other data needs or can to be cleaned*/
Select *
from layoffs_staging2;


/*Dropping the row_num column because we don't need it anymore*/
Alter table layoffs_staging2
drop column row_num;

/*Checking table again*/
Select *
from layoffs_staging2;

































