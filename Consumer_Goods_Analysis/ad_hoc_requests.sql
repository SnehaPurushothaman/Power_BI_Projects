-- Codebasics SQL Challenge

-- Requests:
1. Provide the list of markets in which customer "Atliq Exclusive" operates its business in the APAC region.

  select distinct market from dim_customer where customer="Atliq Exclusive" and region="APAC";


2. What is the percentage of unique product increase in 2021 vs. 2020? The final output contains these fields, 
unique_products_2020, unique_products_2021, percentage_chg

with cte as 
(select 
		g.fiscal_year
        ,count(distinct g.product_code) as unique_products 
 from fact_gross_price g  
 group by fiscal_year
 )
 select 
		prod2020.unique_products as unique_products_2020
        ,prod2021.unique_products as unique_products_2021
        ,round((prod2021.unique_products -prod2020.unique_products)/prod2020.unique_products*100,2) as percentage_chg
 from cte as prod2020
 cross join cte prod2021
where prod2020.fiscal_year =2020
and prod2021.fiscal_year =2021;


3. Provide a report with all the unique product counts for each segment and sort them in descending order of product counts. The final output contains 2 fields,
segment, product_count

select segment
		,count(distinct product_code) as product_count
 from dim_product
 group by segment
order by product_count desc;


4. Follow-up: Which segment had the most increase in unique products in 2021 vs 2020? The final output contains these fields,
segment, product_count_2020, product_count_2021, difference

with cte as 
(select p.segment
		,s.fiscal_year
		,count(distinct s.product_code) as product_count
 from fact_sales_monthly s 
 join dim_product p
 on
 p.product_code=s.product_code
 group by segment,fiscal_year
 )
 select prodcnt2020.segment
		,prodcnt2020.product_count as product_count_2020
        ,prodcnt2021.product_count as product_count_2021
        ,(prodcnt2021.product_count - prodcnt2020.product_count) as difference
 from cte prodcnt2020
  join cte prodcnt2021
  on prodcnt2021.segment = prodcnt2020.segment
 where prodcnt2020.fiscal_year=2020
 and prodcnt2021.fiscal_year=2021
order by difference desc;



5. Get the products that have the highest and lowest manufacturing costs.The final output should contain these fields,
product_code, product, manufacturing_cost

select m.product_code
		,p.product
        ,m.manufacturing_cost
 from fact_manufacturing_cost m
join dim_product p
on p.product_code=m.product_code
where m.manufacturing_cost=(select min(manufacturing_cost) from fact_manufacturing_cost)
or m.manufacturing_cost=(select max(manufacturing_cost) from fact_manufacturing_cost);


6. Generate a report which contains the top 5 customers who received an average high pre_invoice_discount_pct for the fiscal year 2021 and in the Indian market. The final output contains these fields,
customer_code, customer, average_discount_percentage

select c.customer_code
		,c.customer
        ,round(avg(pre_invoice_discount_pct)*100,2) as average_discount_percentage
 from fact_pre_invoice_deductions p
join  dim_customer c
on c.customer_code=p.customer_code
where fiscal_year=2021 and market="India"
group by c.customer_code,c.customer
order by average_discount_percentage desc
limit 5;



7. Get the complete report of the Gross sales amount for the customer “Atliq Exclusive” for each month. This analysis helps to get an idea of low and high-performing months and take strategic decisions.
The final report contains these columns:
Month, Year, Gross sales Amount

select 
date_format(s.date,'%b') as Month
,Year(s.date) as Year 
,round(sum(g.gross_price*s.sold_quantity)/1000000,2) as gross_sales_amount_mln
 from fact_sales_monthly s
join fact_gross_price g
on
s.product_code=g.product_code and 
s.fiscal_year=g.fiscal_year
join dim_customer c
on c.customer_code=s.customer_code
where customer="Atliq Exclusive"
group by Month,Year
order by   Year,Month; 


8. In which quarter of 2020, got the maximum total_sold_quantity? The final output contains these fields sorted by the total_sold_quantity,
Quarter, total_sold_quantity

select 
		case when Month(s.date) in (9,10,11) then "Q1"
        when Month(s.date) in (12,1,2) then "Q2"
        when Month(s.date) in (3,4,5) then "Q3"
        when Month(s.date) in (6,7,8) then "Q4"
        end as Quarter
        ,round(sum(sold_quantity)/1000000,2) as total_sold_quantity_mln
from fact_sales_monthly s
where fiscal_year=2020
group by Quarter
order by total_sold_quantity desc;


9. Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of contribution? The final output contains these fields,
channel, gross_sales_mln, percentage

with cte as
(	select channel
			,round(sum(g.gross_price*s.sold_quantity)/1000000,2) as gross_sales_mln
	from fact_sales_monthly s 
	join dim_customer c
	on 
		c.customer_code=s.customer_code
	join fact_gross_price g
	on
		g.product_code=s.product_code and 
		g.fiscal_year=s.fiscal_year
    where s.fiscal_year=2021
    group by channel
    order by gross_sales_mln desc
)
select channel
		,gross_sales_mln
        ,round((gross_sales_mln/sum(gross_sales_mln) over())*100,2) as gross_sales_pct
        from cte;
        
        
10. Get the Top 3 products in each division that have a high total_sold_quantity in the fiscal_year 2021? The final output contains these fields,
division, product_code, product, total_sold_quantity, rank_order

with cte1 as
(select p.division
		,s.product_code
        ,p.product
        ,sum(s.sold_quantity) as total_sold_quantity
from fact_sales_monthly s
join dim_product p
on p.product_code=s.product_code
where fiscal_year = 2021
group by division,s.product_code,p.product
),
cte2 as
(select * 
		,rank() over(partition by division order by total_sold_quantity) as rank_order
		from cte1)
        select * from cte2
       where rank_order<4;


-- ==============================



