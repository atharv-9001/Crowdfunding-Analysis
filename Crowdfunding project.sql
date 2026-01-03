use crowdfunding_project;
select * from projects;
desc projects;
desc category;
desc calender_table;
show tables;


-- Projects Overview KPI :
-- 1) Total Number of Projects based on outcome 
select 
    state as outcome,
    COUNT(*) as total_projects
from projects
group by state;



-- 2) Total Number of Projects based on Locations
select 
    country as location,
    COUNT(*) as total_projects
from projects
group by country
limit 10;


-- 3) Total Number of Projects based on Category
select 
    c.name as category,
    COUNT(*) as total_projects
from projects p
join category c
    on p.category_id = c.id
group by c.name
order by total_projects desc
limit 10;


-- 4) Total Number of Projects created by Year , Quarter , Month
select
    year(dt) as year,
    quarter(dt) as quarter,
    month(dt) as month_no,
    MAX(MONTHNAME(dt)) as month,
    COUNT(*) as total_projects
from (
    select FROM_UNIXTIME(created_at) as dt
    from projects
) t
group by
    year(dt),
    quarter(dt),
    month(dt)
order by
    year desc,
    quarter,
    month_no
    limit 10;


-- Successful Projects
-- 1) Amount Raised 
select 
    name as project_name,
    state,
    (goal * static_usd_rate) as amount_raised
from 
    crowdfunding_project.projects
where 
    state = 'successful'
    order by amount_raised desc
    limit 10;
    
    
-- 2) Number of Backers
select
    name as project_name,
    state,
    backers_count
from 
    crowdfunding_project.projects
where 
    state = 'successful'
order by
    backers_count desc
    limit 10;
    
    
-- 3) Avg Number of Days for successful projects
select
    ROUND(
        AVG(
            DATEDIFF(
                FROM_UNIXTIME(deadline),
                FROM_UNIXTIME(created_at)
            )
        ),
        2
    ) as avg_project_duration_days
from projects
where state = 'successful';


-- PERCENTAGE OF SUCCESSFUL PROJECTS 
-- 1) Percentage of Successful Projects overall
select
    ROUND(
        SUM(CASE WHEN state='successful' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) as success_percentage
from projects;


-- 2) Percentage of Successful Projects by Category
select
    c.name as category,
    ROUND(
        SUM(CASE WHEN p.state = 'successful' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) as success_percentage
from projects p
join category c
    on p.category_id = c.id
group by c.name
order by success_percentage desc
limit 10;


-- 3) Percentage of Successful Projects by Year , Month etc..
select
    c.`Year`,
    c.`Month_Name`,
    ROUND(
        SUM(CASE WHEN p.state = 'successful' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) as success_percentage
from projects p
join calender_table c
    ON DATE(FROM_UNIXTIME(p.created_at)) =
       STR_TO_DATE(c.`Created_Date`, '%Y-%m-%d')
group by
    c.`Year`,
    c.`Month`,
    c.`Month_Name`
order by
    c.`Year`,
    c.`Month`
    limit 10;


-- 4) Percentage of Successful projects by Goal Range 
select 
    case 
        when (goal * static_usd_rate) < 5000 then 'less than 5000'
        when (goal * static_usd_rate) between 5000 and 20000 then '5000 to 20000'
        when (goal * static_usd_rate) between 20000 and 50000 then '20000 to 50000'
        when (goal * static_usd_rate) between 50000 and 100000 then '50000 to 100000'
        else 'greater than 100000'
    end as goal_range,
    COUNT(ProjectID) as total_projects,
    COUNT(CASE WHEN state = 'successful' THEN 1 END) as successful_projects,
    COUNT(CASE WHEN state = 'successful' THEN 1 END) * 100.0 
        / COUNT(ProjectID) AS success_percentage
from crowdfunding_project.projects
group by goal_range
order by success_percentage desc;
