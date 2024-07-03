use HR

select * from bank;
-- Find Distict Loan_Status
SELECT DISTINCT LOAN_STATUS FROM bank;

--Find TOTAL LOAN APPLICATIONS
SELECT COUNT(distinct ID) AS TOTAL_LOAN_APPLICATIONS FROM bank;

---- TOTAL FUNDED AMOUNT in million
select round(sum(loan_amount)/1000000,2) as "Total_loan_funded_in_millions"
		from bank;

 --- Find  TOTAL PAYMENT RECEIVED
 select round(sum(total_payment)/1000000,2)as "Recieved_payment_in_million"
							from bank;


-- AVERAGE INTEREST RATE
SELECT PURPOSE, ROUND(AVG(INT_RATE), 2)*100 AS "AVG_INT_RATE" 
FROM bank
GROUP BY PURPOSE;

-- AVERAGE DTI
select round(avg(dti),2)*100 as "avgDTI" from bank ;

-- AVERAGE DTI GROUP BY MONTH & year 2021.
select year(issue_date) as 'year',month(issue_date) as 'month',round(avg(dti),2)*100
	from bank
		where year(issue_date)=2021
		group by month(issue_date),
		year(issue_date)
		order by month(issue_date) asc;

-- find  distinct loan status

select distinct(loan_status) from bank;

---- GOOD LOAN VS BAD LOAN :

-- GOOD LOAN APPLICATION %

select count(case when loan_status ='Fully Paid'
						or 
						loan_status='Current'
						then
						ID End)*100/count(Distinct(ID)) AS 'Good Loan Application %'
						from bank;
-- Bad Loan Appliction Percntage 
select count(case when loan_status ='Charged off'
						then
						ID end)*100/COUNT(DISTINCT(ID)) AS 'Bad Loan Application %'
						from bank;


-- GOOD LOAN TOTAL AMNT RECD
SELECT CONCAT(CAST(SUM(TOTAL_PAYMENT)/1000000 AS DECIMAL(18,2)), ' ', 'millions') AS 'GOOD_LOAN_TOTAL_AMNT_RECD (in millions)'
FROM bank
WHERE loan_status IN ('FULLY PAID', 'CURRENT');

-- Bad LOAN TOTAL AMNT RECD

SELECT CONCAT(CAST(SUM(TOTAL_PAYMENT)/1000000 AS DECIMAL(18,2)), ' ', 'millions') AS 'BAD_LOAN_TOTAL_AMNT_RECD (in millions)'
FROM bank
WHERE loan_status IN ('CHARGED OFF');


-- MONTH OVER MONTH TOTAL AMOUNT RECD


WITH MONTHLYTOTALS AS (
     SELECT 
	    YEAR(ISSUE_DATE) AS 'YEAR',
	    MONTH(ISSUE_DATE) AS 'MONTH',
	    SUM(TOTAL_PAYMENT) AS 'MONTHLY_TOTAL_PAYMENT_RECEIVED'
	 FROM 
	    bank
	 WHERE 
	    YEAR(ISSUE_DATE) = 2021
	 GROUP BY
	    YEAR(ISSUE_DATE),
		MONTH(ISSUE_DATE)
),
MONTHOVERMONTH AS (
     SELECT 
	       T1.YEAR,
	       T1.MONTH,
	       T1.MONTHLY_TOTAL_PAYMENT_RECEIVED AS 'CURRENT_MONTH_PAYMENT',
	       T2.MONTHLY_TOTAL_PAYMENT_RECEIVED AS 'PREVIOUS_MONTH_PAYMENT',
	       T1.MONTHLY_TOTAL_PAYMENT_RECEIVED - T2.MONTHLY_TOTAL_PAYMENT_RECEIVED AS 'MONTH_OVER_MONTH_AMOUNT'
	 FROM
	      MONTHLYTOTALS T1
	 LEFT JOIN
	      MONTHLYTOTALS T2 ON T1.YEAR = T2.YEAR AND T1.MONTH = T2.MONTH + 1
)
SELECT
     YEAR,
	 MONTH,
	 MONTH_OVER_MONTH_AMOUNT
FROM 
    MONTHOVERMONTH
ORDER BY
    YEAR, 
	MONTH;

-- MONTH TO MONTH AVERAGE INTEREST RATE AND I WANT TO BE ROUNDED OF UPTO 2 DECIMAL PLACES

WITH MonthlyInterestRate AS(
	SELECT
		YEAR(issue_date) as Year,
		MONTH(issue_date) as Month,
		ROUND(AVG(int_rate)*100,2) as monthly_average_interest_rate
	FROM
		bank
	WHERE
		YEAR(issue_date) = 2021
	GROUP BY
		YEAR(issue_date),
		MONTH(issue_date)
), 
MonthOverMonthInterestRate AS(
	SELECT
		MIR1.Year,
		MIR1.Month,
		MIR1.monthly_average_interest_rate as Current_Month_Interest_Rate,
		MIR2.monthly_average_interest_rate as Previous_Month_Interest_Rate,
		ROUND((MIR1.monthly_average_interest_rate - MIR2.monthly_average_interest_rate),2) as Month_Over_Month_Interest_Rate
	FROM
		MonthlyInterestRate MIR1
	LEFT JOIN
		MonthlyInterestRate MIR2
	ON
		MIR1.Year = MIR2.Year
		and MIR1.Month = MIR2.Month+1
)
SELECT
	Year, 
	Month, 
	Current_Month_Interest_Rate, 
	Previous_Month_Interest_Rate, 
	Month_Over_Month_Interest_Rate 
FROM 
	MonthOverMonthInterestRate 
ORDER BY
	Year, 
	Month;
select * from bank;
