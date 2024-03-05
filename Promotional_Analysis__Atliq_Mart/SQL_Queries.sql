/* 1.	Provide a list of products with a base price greater than 500 and that are featured in promo type of 'BOGOF' (Buy One Get One Free). */


select  distinct p.product_name, e.base_price,e.promo_type
from dim_products as p
join fact_events as e on p.product_code=e.product_code
where base_price>500 and promo_type="BOGOF";


/* 2.	Generate a report that provides an overview of the number of stores in each city. The results will be sorted in descending order of 
store counts, allowing us to identify the cities with the highest store presence. */


select count(*) as Store_Count,city 
from dim_stores
group by city 
order by Store_Count desc;


/* 3.	Generate a report that displays each campaign along with the total revenue generated before and after the campaign? */

select c.campaign_name,
 CONCAT(SUM(e.`quantity_sold(before_promo)` * base_price)/1000000," M")  as total_revenue_before_promotion,
 CONCAT(SUM(e.`quantity_sold(after_promo)` * e.base_price)/1000000," M") as total_revenue_after_promotion
from dim_campaigns c
join fact_events e on c.campaign_id=e.campaign_id
group by campaign_name
;


/* 4.	Produce a report that calculates the Incremental Sold Quantity (ISU%) for each category during the Diwali campaign. 
Additionally, provide rankings for the categories based on their ISU%. */
 

 select category
	,round(
		((SUM(`quantity_sold(after_promo)`)-SUM(`quantity_sold(before_promo)`))/SUM(`quantity_sold(before_promo)`))*100
        ,2) as 'isu'
  ,rank() over (order by (
				round(
					((SUM(`quantity_sold(after_promo)`)-SUM(`quantity_sold(before_promo)`))/SUM(`quantity_sold(before_promo)`))*100
                    ,2)
                ) desc) as 'rank'
 from dim_products p 
 join fact_events e on p.product_code=e.product_code
 where e.campaign_id="CAMP_DIW_01"
 group by category
 order by isu desc;
 
  
/* 5.	Create a report featuring the Top 5 products, ranked by Incremental Revenue Percentage (IR%), across all campaigns.*/


with cte as
(
select product_name
		,category
        , `quantity_sold(before_promo)`*base_price as Revenue_Before_Promo
        ,`quantity_sold(after_promo)`*base_price as Revenue_After_Promo
       -- ,(Revenue_After_Promo - Revenue_Before_Promo)/Revenue_Before_Promo *100 as Incremental_Revenue_Percentage 
from dim_products p 
join fact_events e on p.product_code=e.product_code
)
select distinct product_name
		,category
        ,round((Revenue_After_Promo - Revenue_Before_Promo)/Revenue_Before_Promo *100,2) as Incremental_Revenue_Percentage 
        from cte
order by Incremental_Revenue_Percentage desc
limit 5;
