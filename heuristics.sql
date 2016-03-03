use [T_Crecos]

drop table [periods_list];
drop table items_diff_table;
drop table items_medhigh_table;
drop table [periods_list];
drop table highest_items;

/*insert code here to go for each class*/

go

declare @Number_of_Weeks int; set @Number_of_Weeks =4

--period list
select [Time_Stamp_WW], row_number() over (order by [Time_Stamp_WW] desc) rnk_period
into [periods_list]
from [dbo].[Sales_Info]
group by  [Time_Stamp_WW]

print('created period table')

/*phase 1: different thershold and stores above mid high */


Select [item_model_code]
,sum(case when RN=1+CNT/6 then sales_quantity else 0 end) med_low
,sum(case when RN=1+5*CNT/6 then sales_quantity else 0 end) med_high
,sum(case when RNS=1+CNT/6 then [sales_amount] else 0 end) med_low_s
,sum(case when RNS=1+5*CNT/6 then [sales_amount] else 0 end) med_high_s
--
into items_diff_table
from
	(SELECT
		   [item_model_code]
		  , row_number() over (partition by [item_model_code] order by [sales_quantity]) RN
		  , row_number() over (partition by [item_model_code] order by [sales_amount]) RNS
		  , count(*) over (partition by [item_model_code]) cnt
		  ,[sales_amount]
		 ,[sales_quantity]
	  FROM
		  (select --model_color, BRANCH_ID, sum([sales_amount]) [sales_amount], sum ([sales_quantity]) [sales_quantity]
					[Store_Identifier], [item_model_code] ,sum([sales_amount]) as [sales_amount], sum ([sales_quantity])  as [sales_quantity]
		   from [dbo].[Sales_Info]
		   where [Time_Stamp_WW] in (select [Time_Stamp_WW] from [periods_list] where rnk_period <= @Number_of_Weeks )
		   group by [Store_Identifier],[item_model_code]
		   ) t1
	  ) t2
group by [item_model_code]


		Select [item_model_code]
		,sum(case when RN=1+CNT/6 then sales_quantity else 0 end) med_low
		,sum(case when RN=1+5*CNT/6 then sales_quantity else 0 end) med_high
		,sum(case when RNS=1+CNT/6 then [sales_amount] else 0 end) med_low_s
		,sum(case when RNS=1+5*CNT/6 then [sales_amount] else 0 end) med_high_s
		--
		into items_diff_table
		from
			(SELECT
				   [item_model_code]
				  , row_number() over (partition by [item_model_code] order by [sales_quantity]) RN
				  , row_number() over (partition by [item_model_code] order by [sales_amount]) RNS
				  , count(*) over (partition by [item_model_code]) cnt
				  ,[sales_amount]
				 ,[sales_quantity]
			  FROM
				  (select --model_color, BRANCH_ID, sum([sales_amount]) [sales_amount], sum ([sales_quantity]) [sales_quantity]
							[Store_Identifier], [item_model_code] ,sum([sales_amount]) as [sales_amount], sum ([sales_quantity])  as [sales_quantity]
				   from [dbo].[Sales_Info]
				   where [Time_Stamp_WW] in (select [Time_Stamp_WW] from [periods_list] where rnk_period <= 4 )-- @Number_of_Weeks )
				   and  [item_model_code]='2049'
				   group by [Store_Identifier],[item_model_code]
				   ) t1
			  ) t2
		group by [item_model_code]

--having sum(case when RN=1+5*CNT/6 then sales_quantity else 0 end) - sum(case when RN=1+CNT/6 then sales_quantity else 0 end)> @diff_threshold;
	print('#items_diff_table|created')
	--insert into #steps_info
	--select '#items_diff_table',(select count(distinct [item_model_code]) from items_diff_table where med_high-med_low> 2)--@diff_threshold)



Select 
t1.[item_model_code]
,count(1) as [n_stores_medhigh]
into items_medhigh_table
  FROM
    (select [Store_Identifier],[item_model_code] ,sum([sales_amount]) as [sales_amount], sum ([sales_quantity])  as [sales_quantity]
	from [dbo].[Sales_Info]
	where [Time_Stamp_WW] in (select [Time_Stamp_WW] from [periods_list] where rnk_period <= @Number_of_Weeks )
	group by [item_model_code],[Store_Identifier]
	) t1 
	join items_diff_table t2  on t1.[item_model_code]=t2.[item_model_code] and t1.[sales_quantity]>[med_high]
group by t1.[item_model_code]

--	print('##items_medhigh_table|created')
--	insert into #steps_info
--	select '#items_medhigh_table',(select count(distinct [item_model_code]) from items_medhigh_table where [n_stores_medhigh]> 5) --@midhigh)

/* enough sales*/

select Item_Model_Code
		,sum([sales_amount]) as [sales_amount], sum ([sales_quantity])  as [sales_quantity] ,count(distinct [Store_Identifier]) as [count_stores]
into highest_items
from [dbo].[Sales_Info]
where [Time_Stamp_WW] in (select [Time_Stamp_WW] from [periods_list] where rnk_period <= @Number_of_Weeks )
group by Item_Model_Code
having sum([sales_amount])> 200 --@amount
and sum ([sales_quantity]) > 10 --@quantity
and count(distinct [Store_Identifier])> 7--@support*2

	print('#highest_items|created')
	--insert into #steps_info
	select '#highest_items',(select count(distinct Item_Model_Code) from highest_items )


----temp---
select sum(sales_amount) from sales_info 
where [item_model_code] in (
				select [item_model_code] from items_medhigh_table where [n_stores_medhigh]>20--@midhigh
				 union all 
				select [item_model_code] from items_diff_table where med_high-med_low>3 and med_high_s-med_low_s>200 ---@diff_threshold
				)
and [Time_Stamp_WW] in (select [Time_Stamp_WW] from [periods_list] where rnk_period <= @Number_of_Weeks)
--2,181,935.40



select sum(sales_amount)
from sales_info
where [Time_Stamp_WW] in (select [Time_Stamp_WW] from [periods_list] where rnk_period <= @Number_of_Weeks)
--4,159,504.42

---

drop table [high_velocity]
select distinct [item_model_code] into dbo.[high_velocity] from sales_info 
where [item_model_code] in (
				select [item_model_code] from items_medhigh_table where [n_stores_medhigh]>5--@midhigh
				 union all 
				select [item_model_code] from items_diff_table where med_high-med_low>3 and med_high_s-med_low_s>200 --@diff_threshold
				)
and [Time_Stamp_WW] in (select [Time_Stamp_WW] from [periods_list] where rnk_period <= @Number_of_Weeks)


select distinct [item_model_code] from dbo.[high_velocity]

select [item_model_code],store_identifier,sum(sales_amount) as sa,sum(sales_quantity) as sq from sales_info 
where not ([item_model_code]  in (select [item_model_code] from items_medhigh_table))
 and [Time_Stamp_WW] in (select [Time_Stamp_WW] from [periods_list] where rnk_period <= 4 )
group by [item_model_code],store_identifier