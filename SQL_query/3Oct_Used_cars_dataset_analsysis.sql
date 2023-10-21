


use exercise;

# Import used cars1 data

select * from used_cars1;

# Cleaning string based columns
UPDATE used_cars1 SET Engine = REPLACE(Engine, ' CC', '');
UPDATE used_cars1 SET Power = REPLACE(Power, ' bhp', ''); 
UPDATE used_cars1 SET Power = REPLACE(Power, 'null', '0.0000');

 
# Change data types of columns
desc used_cars1;
select * from used_cars1;
alter table used_cars1 modify Power float;   # done
alter table used_cars1 modify Engine int;   # done
# alter table used_cars1 modify Price float; # done
# alter table used_cars1 modify Mileage double; # error

select * from used_cars1;
desc used_cars1;

# View Entire data
select * from used_cars1;


# Fetch Car_Brand_names
select SUBSTRING_INDEX(Name,' ', 2) as Car_Brand from used_cars1;

# Fetch Car Model
select SUBSTRING_INDEX(SUBSTRING_INDEX(Name, ' ', 2),' ',-1) as Car_Model 
from used_cars1;

select * from used_cars1;

# 1) Query for KPI
# 2) Stored Procedure for Dim Value COunts
# 3) Year and Region Wise Avg Price and Rank them based on Year
# 4) Set a Target AvgPrice_Goal, Display Loctaion wise Avg_Price, Avg_Price_2Goal
# and Percent_2Goal
# 5) Owner Type and Transmission wise Avg_Mileage and Avg_Power
# 6) Find Car_Brand wise_AvgPrice where Avg_Price>
# Avg_Price for Car_Brand wise_AvgPrice.


# Q1) KPI
# Find Avg_mileage, Avg_Power, Avg_Engine,Avg_Price, Avg_Kms, and Avg_NumSeats

select round(avg(mileage),1) as Avg_Mileage, round(avg(Power),1) as AvgPower, 
round(avg(Price),1) as AvgPrice,round(avg(Kilometers_driven),1) as Avg_Kms, 
round(avg(Engine),1) as AvgEngine, round(avg(Seats),1) as AvgSeats
from used_cars1;


select * from used_cars1;


# Q2) Fetch value count of each column with a parameter
# Creating stored Procedure for the same

select fuel_type,count(*) VCount from used_cars1 group by fuel_type;

select feat,count(*) VCount from used_cars1 group by feat;

select 'Fuel_type',count('Fuel_type') VCount from used_cars1 group by 'Fuel_type';



drop procedure dim_value_counts;

delimiter //
create procedure dim_value_counts(in dim varchar(50))
begin
	SET @sql = CONCAT('SELECT ', dim, ', COUNT(*) AS Dim_Count FROM 
    used_cars1 GROUP BY ', dim,' order by Dim_Count desc');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
end //
delimiter ;


call dim_value_counts('Year');
call dim_value_counts('Transmission');


select * from used_cars1;

select Fuel_Type, count(Fuel_Type) from used_cars1
group by Fuel_Type order by Fuel_Type desc;



# Q3)  Car_Brand wise as Avg_Price
select SUBSTRING_INDEX(Name, ' ', 1) as Car_Brand, round(avg(Price),2) as Avg_Price
from used_cars1 group by Car_Brand order by Avg_Price desc;

# Avg of Avg_Price
select avg(Avg_Price) Avg_of_Avg_Price from 
(select SUBSTRING_INDEX(Name, ' ', 1) as Car_Brand, round(avg(Price),2) as Avg_Price
from used_cars1 group by Car_Brand order by Avg_Price desc) dt;

# a) Filter Car_Brand wise Avge_price where Avg_price > Avg of Car_Brand wise Avge_price
with cte1 as
(select SUBSTRING_INDEX(Name, ' ', 1) as Car_Brand, round(avg(Price),2) as Avg_Price
from used_cars1 group by Car_Brand order by Avg_Price desc)
select * from cte1 where cte1.Avg_Price > (select avg(Avg_Price) from cte1);

# Avg of Avg Price = 18.82
# Overall Avg = 9.5

# b) Filter Car_Brand wise Avge_price where Avg_price > Overall Avg of Car Price
with cte1 as
(select SUBSTRING_INDEX(Name, ' ', 1) as Car_Brand, round(avg(Price),2) as Avg_Price
from used_cars1 group by Car_Brand order by Avg_Price desc),
cte2 as (Select avg(Price) as Overall_Avg from used_cars1)
select * from cte1 where cte1.Avg_Price > (Select Overall_Avg from cte2);


delimiter //
create procedure brand_wise_avgPriceAvg_higher_than_N(in N float)
begin
select * from
(select SUBSTRING_INDEX(Name, ' ', 1) as Car_Brand, round(avg(Price),2) as Avg_Price
from used_cars1 group by Car_Brand order by Avg_Price desc) as dt
where dt.Avg_Price >N; 
end //
delimiter ;

call brand_wise_avgPriceAvg_higher_than_N(35.87);

select * from used_cars1;

# Q4)

select max(AvgPrice) from
(select location, round(avg(price),2) as AvgPrice from used_cars1 
group by location) dt;

set @max_AvgPrice = 15.1;

create or replace view location_wise_price_2goal as
select location, round(avg(price),2) as AvgPrice from used_cars1 
group by location;

select * from location_wise_price_2goal;

# [AvgPrice_2Goal]/avg([Price])


select location, AvgPrice, Price_2MaxAvgGoal, 
round((Price_2MaxAvgGoal/AvgPrice)*100,3) as Percentage_2MaxAvgGoal from 
(select location, AvgPrice,  round(@max_AvgPrice - AvgPrice,2) as Price_2MaxAvgGoal
from location_wise_price_2goal) dt;


# Q5 Year and Avg_Price wise Rank different Regions

select * from
(select Location, Year, round(Avg(Price),2) as AvgPrice,
rank() over (partition by Location order by Avg(Price) desc) as SRank
from used_cars1 group by Location, Year) dt
where SRank<=5;




 




