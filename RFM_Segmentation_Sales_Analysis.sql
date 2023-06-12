--Inspecting data
select * from [dbo].[sales_data_sample]

--Checking unique values

select distinct STATUS from [dbo].[sales_data_sample]
select distinct DEALSIZE from [dbo].[sales_data_sample]
select distinct year_id from [dbo].[sales_data_sample]
select distinct TERRITORY` from [dbo].[sales_data_sample]
select distinct COUNTRY from [dbo].[sales_data_sample]
select distinct productline from  [dbo].[sales_data_sample]


--Analysis
-- Grouping Sales by productline

select productline,sum(sales) as Total_sales
from [dbo].[sales_data_sample]
group by productline
order by 2 desc

--Grouping Sales by productline

select YEAR_ID,sum(sales) as Total_sales
from [dbo].[sales_data_sample]
group by YEAR_ID
order by 2 desc


-- Grouping sales by DEALSIZE

select DEALSIZE,sum(sales) as Total_sales
from [dbo].[sales_data_sample]
group by DEALSIZE
order by 2 desc

-- what was the best month for sales in a specific year? How much was earned  that month?

select  month_id ,sum(sales) as total_sales,count(ordernumber) as total_orders
from [dbo].[sales_data_sample]
where YEAR_ID = 2003 
group by MONTH_ID
order by 2 desc 

-- November Sales

select month_id, productline, sum(sales) total_sales, count(ordernumber)
from  [dbo].[sales_data_sample]
where year_id=2003 and month_id =11
group by productline ,month_id
order by 3 desc

-- Who is our best customer (RFM analysis)

Drop table if exists #rfm

;with naga as 
	 (
	 select customername,
	   sum(sales) monetary_value,
	   avg(sales) avg_monetary_value,
	   count(ordernumber) as frequency,
	   max(orderdate) as recent_order,
	   (select max(orderdate) from [dbo].[sales_data_sample]) as last_order_date,
	   DATEDIFF(dd,max(orderdate),(select max(orderdate) from [dbo].[sales_data_sample])) as recency
	   from [dbo].[sales_data_sample]
	   group by customername
	   ),
rfm_calc as
 (
select * ,
 NTILE(4) over(order by recency desc) as rfm_recency,
 NTILE(4) over(order by frequency) as rfm_frequency,
 NTILE(4) over(order by monetary_value) as rfm_avg_monetary_value
   from naga
   )
   select * ,rfm_recency+rfm_frequency+rfm_avg_monetary_value as rfm_cell,
   cast(rfm_recency as varchar)+cast(rfm_frequency as varchar)+cast(rfm_avg_monetary_value as varchar) rfm_string
   into #rfm
   from rfm_calc

   select * from #rfm

    select CUSTOMERNAME , rfm_recency, rfm_frequency, rfm_avg_monetary_value,
	case 
		when rfm_string in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) then 'lost_customers'  --lost customers
		when rfm_string in (133, 134, 143, 244, 334, 343, 344, 144) then 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
		when rfm_string in (311, 411, 331) then 'new customers'
		when rfm_string in (222, 223, 233, 322) then 'potential churners'
		when rfm_string in (323, 333,321, 422, 332, 432) then 'active' --(Customers who buy often & recently, but at low price points)
		when rfm_string in (433, 434, 443, 444) then 'loyal'
	end rfm_segment

from #rfm

-- what products are often sold together

--select * from [dbo].[sales_data_sample]
--select * from [dbo].[sales_data_sample] where ordernumber = 10325


select distinct ordernumber, STUFF
(
(select ',', PRODUCTCODE from 
 [dbo].[sales_data_sample] p
 where ordernumber in 
 (
select ordernumber from 
(
select ordernumber,count(*) rn  from 
[dbo].[sales_data_sample] n
where STATUS = 'Shipped'
group by ORDERNUMBER
) rn 
where rn =2
and p.ORDERNUMBER=s.ordernumber
) 
for xml path ('')), 1,1, '')productnumber
from [dbo].[sales_data_sample] s
order by 2 desc












