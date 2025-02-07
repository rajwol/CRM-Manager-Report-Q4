--KPI Card 1
--Total Sales current Qtr
SELECT 
manager,
ROUND(SUM(close_value),-3)
FROM sales_pipeline p
LEFT JOIN sales_teams t 
	ON p.sales_agent = t.sales_agent
WHERE close_date BETWEEN '2017-10-01' AND '2017-12-31'
GROUP BY manager
ORDER BY manager;

--Total Sales last Qtr
SELECT 
manager,
ROUND(SUM(close_value),-3)
FROM sales_pipeline p
LEFT JOIN sales_teams t 
	ON p.sales_agent = t.sales_agent
WHERE close_date BETWEEN '2017-07-01' AND '2017-09-30'
GROUP BY manager
ORDER BY manager;

--All Team Averages
SELECT 
AVG(total_sales) AS all_teams_average
FROM (
		SELECT 
        t.manager, 
        SUM(p.close_value) AS total_sales
		FROM 
        sales_pipeline p
		LEFT JOIN 
        sales_teams t 
			ON p.sales_agent = t.sales_agent
		WHERE 
        p.close_date BETWEEN '2017-10-01' AND '2017-12-31'
		GROUP BY 
        t.manager
) team_sales;

-------

--KPI Card 2
-- Avg. Sale Value current Qtr
SELECT 
manager,
AVG(close_value)
FROM sales_pipeline p
LEFT JOIN sales_teams t 
	ON p.sales_agent = t.sales_agent
WHERE deal_stage = 'won'
AND close_date BETWEEN '2017-10-01' AND '2017-12-31'
GROUP BY manager;

--Avg. Sales Value Last Qtr
SELECT 
manager,
AVG(close_value)
FROM sales_pipeline p
LEFT JOIN sales_teams t 
	ON p.sales_agent = t.sales_agent
WHERE deal_stage = 'won'
AND close_date BETWEEN '2017-07-01' AND '2017-09-30'
GROUP BY manager;

--All team averages
SELECT 
AVG(avg_sale_value) AS all_teams_average
FROM (
		SELECT 
        manager, 
        AVG(close_value) AS avg_sale_value
		FROM 
        sales_pipeline p
		LEFT JOIN 
        sales_teams t 
			ON p.sales_agent = t.sales_agent
		WHERE 
        close_date BETWEEN '2017-10-01' AND '2017-12-31' -- Q4 2017
        AND deal_stage = 'won'
		GROUP BY 
        manager
) team_avg_sales;

-------

--KPI Card 3
--Avg. Weeks to Close Current Qtr
SELECT 
manager,
ROUND(AVG(DATEDIFF(day, engage_date, close_date) * 1.0 / 7), 2) AS avg_weeks
FROM sales_pipeline p
LEFT JOIN sales_teams t 
	ON p.sales_agent = t.sales_agent
WHERE close_date BETWEEN '2017-10-01' AND '2017-12-31'
GROUP BY manager;

--Avg. Weeks to close last Qtr
SELECT 
manager,
ROUND(AVG(DATEDIFF(day, engage_date, close_date) * 1.0 / 7), 2) AS avg_weeks
FROM sales_pipeline p
LEFT JOIN sales_teams t 
	ON p.sales_agent = t.sales_agent
WHERE close_date BETWEEN '2017-07-01' AND '2017-09-30'
GROUP BY manager;

--All team averages
SELECT 
ROUND(AVG(DATEDIFF(day, engage_date, close_date) * 1.0 / 7), 2) AS avg_weeks
FROM 
sales_pipeline p
LEFT JOIN sales_teams t 
	ON p.sales_agent = t.sales_agent
WHERE close_date between '2017-10-01' AND '2017-12-31';

-------

--KPI 4
--New opportunities latest QTR
SELECT 
t.manager,
COUNT(p.opportunity_id) AS total_new_opportunities
FROM 
sales_pipeline p
LEFT JOIN sales_teams t 
	ON p.sales_agent = t.sales_agent
WHERE p.engage_date BETWEEN '2017-10-01' AND '2017-12-31' 
GROUP BY t.manager;

--New Opportunities last QTR
SELECT 
t.manager,
COUNT(p.opportunity_id) AS total_new_opportunities
FROM sales_pipeline p
LEFT JOIN sales_teams t 
	ON p.sales_agent = t.sales_agent
WHERE p.engage_date BETWEEN '2017-07-01' AND '2017-09-30' -- Specify the quarter
GROUP BY t.manager;

--Average Opportunities (All Teams)
WITH TeamOpportunities AS (
	SELECT 
	t.manager,
	COUNT(p.opportunity_id) AS total_new_opportunities
	FROM 
	sales_pipeline p
	LEFT JOIN sales_teams t 
		ON p.sales_agent = t.sales_agent
	WHERE p.engage_date BETWEEN '2017-10-01' AND '2017-12-31' 
	GROUP BY t.manager)
SELECT 
AVG(total_new_opportunities) as AllTeamAverages
FROM TeamOpportunities;

-------

--KPI Card 5 
SELECT t.manager,
SUM(pr.sales_price) AS TotalPotentialRevenue,
COUNT(p.opportunity_id) AS EngagedOpportunities
FROM sales_pipeline p
LEFT JOIN products pr 
	ON p.product = pr.product
LEFT JOIN sales_teams t 
	ON p.sales_agent = t.sales_agent
WHERE deal_stage = 'Engaging'
GROUP BY t.manager;

-------

-- Performance by Agent Table
SELECT 
p.sales_agent,
SUM(CASE WHEN p.deal_stage = 'Won' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS ConversionPct,
SUM(CASE WHEN p.deal_stage = 'Won' THEN 1 ELSE 0 END) AS NumOfSales,
SUM(p.close_value) AS TotalSales,
AVG(CASE WHEN p.deal_stage = 'Won' THEN p.close_value ELSE NULL END) AS AvgCloseValue,
AVG(DATEDIFF(WEEK,engage_date, close_date)) AS AvgWeeksToClose,
SUM(CASE WHEN p.close_value < pr.sales_price THEN p.close_value ELSE 0 END) * 1.0 / SUM(p.close_value) * 100.0 AS pct_sales_discounted
FROM 
    sales_pipeline p
LEFT JOIN sales_teams t 
	ON p.sales_agent = t.sales_agent
LEFT JOIN products pr 
	ON p.product = pr.product
WHERE close_date BETWEEN '2017-10-01' AND '2017-12-31'
GROUP BY p.sales_agent
ORDER BY p.sales_agent;