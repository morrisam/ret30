use [T_Crecos]


1

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


  /*dategames*/
  DECLARE @datecol datetime = GETDATE();
DECLARE @WeekNum INT
      , @YearNum char(4);

SELECT @WeekNum = DATEPART(WK, @datecol)
     , @YearNum = CAST(DATEPART(YY, @datecol) AS CHAR(4));

-- once you have the @WeekNum and @YearNum set, the following calculates the date range.
SELECT DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + @YearNum) + (@WeekNum-1), 6) AS StartOfWeek;
SELECT DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + @YearNum) + (@WeekNum-1), 5) AS EndOfWeek;


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
		time_stamp_dd, time_stamp_ww, s.item_mode_code_concat, s.store_identifier, sales_amount, sales_quantity
		,c.ITEM_MODEL_CODE, Item_description, category_desc, sub_category_desc 
		,Store_Name, market_id
    FROM [dbo].[sales_me] s  ,[dbo].[stores_me] b , [dbo].[items_me] c
    WHERE s.store_identifier=b.store_identifier and c.[item_mode_code_concat]=s.[item_mode_code_concat] and c.bu=b.bu

	)
GO


 select count(1) from Star_sales_info(1)