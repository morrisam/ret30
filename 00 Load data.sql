use [T_Globalp2]

select count(1) from Star_sales_info(1)

select *
into [T_Globalp2].[dbo].[sales_info] 
from [T_Globalp].[dbo].[sales_info]
 
select *   from [T_Globalp].[dbo].[xlscombined]

select Location_ID,count(1)  from [T_Globalp].[dbo].[Store_list_file$]
group by Location_ID
having count(1)>1

select distinct Day_Date from  [T_Globalp].[dbo].[xlscombined]

/**************/
--sales table
/**************/

drop table [dbo].[Sales]
  SELECT 
		cast(Day_Date as date) as Time_Stamp_DD
		,DATEADD(wk,DATEDIFF(wk,7,Day_Date),0) as Time_Stamp_WW
		,s.loc_id as Store_Identifier
		--  ,[item_code_SKU] as Item_Model_Code
		,[Group]+'_'+Item_Id as Item_id_key
		  ,cast ([Sales] as numeric (19,2))  as [sales_amount]
		  ,cast ([Qty_Sold] as numeric (19,2)) as [sales_quantity]
		into  [dbo].[Sales]
  FROM		(
			SELECT
				replace(substring ([Location_Desc],charindex('#',[Location_Desc])+1,len([Location_Desc])),' ','') as loc_id
				,*
			FROM [T_Globalp].[dbo].[xlscombined]
			) s
	join [T_Globalp].[dbo].[Store_list_file$] b
   on cast(b.[Location_ID] as varchar(10))=s.loc_id
  
  
   where b.[Location_ID] is null

		--check sales 
		select * from [dbo].[Sales]
		select sum(sales_amount),count(1) from  [dbo].[Sales]
		select sum(cast ([Sales] as  numeric (19,2)) ),count(1) from  [T_Globalp].[dbo].[xlscombined]



/**************/
--stores table
/**************/

drop table stores

select *  
into stores
from
(
	select
	row_number()  over(partition by Store_Identifier order by store_name) as rnk_dup
	,*
	from 
	(
	  SELECT 
			distinct
			loc_id as Store_Identifier
		  ,[Location_Desc] as Store_Name
		  ,[Group] as BU
		 --into  [dbo].[Sales_Info]
	  FROM		(
				SELECT
					distinct
					replace(substring ([Location_Desc],charindex('#',[Location_Desc])+1,len([Location_Desc])),' ','') as loc_id
					,[Location_Desc]
				FROM [T_Globalp].[dbo].[xlscombined]
				) s
			join [T_Globalp].[dbo].[Store_list_file$] b
				on cast(b.[Location_ID] as varchar(10))=s.loc_id 

	)t

)t2
where rnk_dup=1

  
/**************/
--items table
/**************/

select
*
into items
from 
(
  SELECT 
		row_number()  over(partition by s1.Item_id_key order by [UPC]) as rnk_dup
		--distinct
		,s1.Item_id_key
		,c.[Item Desc] as Item_Model_Name
		,Department_Desc  as [Product_category1]
		,Category_Desc  as [Product_category2]
		,Sub_Category_Desc as [Product_category3]
		,[UPC]+'_'+[Size Desc] as ITEM_MODEL_CODE
  FROM		(
			SELECT
				distinct
				[Group]+'_'+Item_Id as Item_id_key
				,[Item_Desc]
				,Category_Desc 
				,Department_Desc 
				,Sub_Category_Desc
			FROM	(
					SELECT
						distinct
						replace(substring ([Location_Desc],charindex('#',[Location_Desc])+1,len([Location_Desc])),' ','') as loc_id
						,Item_Id,[Item_Desc]
						,Category_Desc 
						,Department_Desc 
						,Sub_Category_Desc
					FROM [T_Globalp].[dbo].[xlscombined] s 
					)s
				join [T_Globalp].[dbo].[Store_list_file$] b
			on cast(b.[Location_ID] as varchar(10))=s.loc_id
			) s1
		join (
				select 'XM'+'_'+[Item ID] as Item_id_key, * from [T_Globalp].[dbo].[XM$]
				union all
				select 'Alliance'+'_'+[Item ID] as Item_id_key, * from [T_Globalp].[dbo].[AE]
				) c
			on c.Item_id_key=s1.Item_id_key 
)t
where rnk_dup=1

select * from [T_Globalp].[dbo].[item_list]

/**************/
--general table
/**************/

  SELECT cast(week_starting as date) as Time_Stamp_WW
	,week_starting
      ,[store_identifier] as Store_Identifier
      ,[item_code_SKU] as Item_Model_Code
      ,[model_item_name] as Item_Model_Name
      ,[Product_category1]
      ,[Product_category2]
      ,[product_category3]
      ,cast ([sales_amount] as numeric (19,2)) as [sales_amount]
      ,cast ([sales_quantity] as numeric (19,2)) as  [sales_quantity]
	  into  [dbo].[Sales_Info]
  FROM [table]

/**************/
--fashion table
/**************/
    select 
[your field here]as [Time_Stamp_DD],
[your field here] as [Time_Stamp_WW],
 DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + cast([Year] as CHAR(4)) ) + ( cast([Week] as  int)-1), 6) AS StartOfWeek
[your field here] as store_identifier,
[your field here] as Store_Name,
[your field here] as chain,
[your field here] as Item_Code_SKU,
[your field here] as Item_Model_Code,
[your field here] as Item_Model_Name,
[your field here] as Color,
[your field here] as Style_Color,
[your field here] as Size,
[your field here] as category 
into [Sales_Info]
from CastroSales S 


  /*presentation slide 1*/
  select sum(sales_amount),count(distinct store_identifier),count(distinct item_model_code) from sales_info

/*****************************************************/
				/*dategames*/
/****************************************************/
  DECLARE @datecol datetime = GETDATE();
DECLARE @WeekNum INT
      , @YearNum char(4);

SELECT @WeekNum = DATEPART(WK, @datecol)
     , @YearNum = CAST(DATEPART(YY, @datecol) AS CHAR(4));

-- once you have the @WeekNum and @YearNum set, the following calculates the date range.
SELECT DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + @YearNum) + (@WeekNum-1), 6) AS StartOfWeek;
SELECT DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + @YearNum) + (@WeekNum-1), 5) AS EndOfWeek;

--Get YYYYWW format from date
select  datepart(YYYY,'2016-03-06')*100 +  datepart(WW,'2016-03-07')

--Get first day of week format from date to format YYYY-MM-DD
   SELECT DATEADD(wk,DATEDIFF(wk,7,'2016-03-06'),0)

/******************/
--stored function
/******************/

DROP function star_sales_info
declare @sql varchar(max) ; set @sql = '8' 

CREATE FUNCTION Star_sales_info(@sales varchar(100))
RETURNS TABLE
RETURN 
(

    SELECT --top 100
		/* define fields */ 
		Item_Model_Name, Product_category1, Product_category2, Product_category3, ITEM_MODEL_CODE
		,Time_Stamp_DD, Time_Stamp_WW, s.Store_Identifier, s.Item_id_key, sales_amount, sales_quantity
		,Store_Name, BU
    FROM [dbo].[sales] s  ,[dbo].[stores] b , [dbo].[items] c
    WHERE s.store_identifier=b.store_identifier and c.[Item_id_key]=s.[Item_id_key] 

	)
GO

--check

select sum(sales_amount),count(1) from Star_sales_info(1)
select sum(sales_amount),count(1) from sales


