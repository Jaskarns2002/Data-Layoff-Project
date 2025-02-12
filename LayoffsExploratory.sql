-- Exploratory Data Analysis -------------

Select *
from layoffs_staging2;

-- maxium number of total laid, and max percentage laid off
Select Max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2;

-- company laid off 100 percent, sorted by funds raised highest to lowest
Select *
from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions DESC;


-- total laid off base off of each company, sorted highest to lowest. 
Select company, sum(total_laid_off) as Sum_layoffs
from layoffs_staging2
group by company
order by sum_layoffs desc;

-- start and end date for the layoffs----
Select min(`date`), max(`date`)
from layoffs_staging2;

-- total laidoff based off industry and sorted by highest to lowest number
Select industry, sum(total_laid_off) as Sum_layoffs
from layoffs_staging2
group by industry
order by sum_layoffs desc;

-- total laidoff based off country and sorted by highest to lowest number
Select country, sum(total_laid_off) as Sum_layoffs
from layoffs_staging2
group by country
order by sum_layoffs desc;

-- total laid odd base off year-----
Select year(`date`) as years, sum(total_laid_off) as Sum_layoffs
from layoffs_staging2
group by years
order by years desc;


-- total laid odd base off of stage, sorted by highes to lowest laid off
Select stage, sum(total_laid_off) as Sum_layoffs
from layoffs_staging2
group by stage
order by sum_layoffs desc;

-- total laid off base off ofyear and month, sorted by the year and month
Select substring(`date`,1,7) as Month, Sum(total_laid_off)
from layoffs_staging2
group by month
having month is not null
order by month;

-- this shows the total rolling sum of layoffs over each month. 
with Rolling_total as
(
Select substring(`date`,1,7) as Month, Sum(total_laid_off) as total_laidoff
from layoffs_staging2
group by month
having month is not null
order by month
)
Select Month, total_laidoff, 
sum(total_laidoff) over(order by month) as rolling_sum
from rolling_total;



-- shows number of people layoff each year for each company. sorted by highest to lowest layoffs
Select company, year(`date`) as years ,sum(total_laid_off) as Sum_layoffs
from layoffs_staging2
group by company, year(`date`)
order by 3 desc;


/* creating first cte shows total laid off by years for each company*/
with company_years_cte (company, years, Sum_laidoff) as
(
Select company, year(`date`),sum(total_laid_off) 
from layoffs_staging2
group by company, year(`date`)
), /*  cte to rank comapny total laid off by each year */
company_year_rank_cte as 
(
select *, (dense_rank() over(partition by years order by sum_laidoff desc)) as LaidOffByYear
from company_years_cte
where years is not null
) /* ranking only top 5 companys laid off for each year */
select *
from company_year_rank_cte
where laidoffbyyear <= 5;

















