--SQL Advance Case Study
Create database db_SQLCaseStudies

select * from dbo.DIM_CUSTOMER
select * from dbo.DIM_DATE
select * from dbo.DIM_LOCATION
select * from dbo.DIM_MANUFACTURER
select * from dbo.DIM_MODEL
select * from dbo.FACT_TRANSACTIONS

--Q1--BEGIN 
	
select state from DIM_LOCATION as T1 inner join FACT_TRANSACTIONS as T2
on T1.IDLocation = T2.IDLocation
where year(date) between 2005 and GETDATE()
group by State

--Q1--END

--Q2--BEGIN

select top 1 state from FACT_TRANSACTIONS as T1 inner join DIM_LOCATION as T2
on T1.IDLocation = T2.IDLocation
inner join DIM_MODEL as T3
on T1.IDModel = T3.IDModel
inner join DIM_MANUFACTURER as T4
on T3.IDManufacturer = t4.IDManufacturer
where country = 'US' and Manufacturer_Name = 'Samsung'
group by State
order by count(Quantity) desc

--Q2--END

--Q3--BEGIN      

select count(idcustomer) as no_of_transaction, IDModel, zipcode, state from dbo.FACT_TRANSACTIONS as T1 inner join DIM_LOCATION as T2
on T1.IDLocation = T2.IDLocation
group by IDModel, ZipCode, State

--Q3--END

--Q4--BEGIN

select top 1 model_name, unit_price from DIM_MODEL
order by Unit_price

--Q4--END

--Q5--BEGIN

select top 5 Manufacturer_Name, avg(T3.TotalPrice) as avg_price , T2.Model_Name, count(T3.Quantity) as sales_Qty from DIM_MANUFACTURER as T1 inner join DIM_MODEL as T2
on T1.IDManufacturer = T2.IDManufacturer inner join FACT_TRANSACTIONS as T3
on T2.IDModel = T3.IDModel
group by T1.Manufacturer_Name, T2.Model_Name
order by avg_price

--Q5--END

--Q6--BEGIN

Select T1.Customer_Name, Avg(TotalPrice) from dbo.DIM_CUSTOMER as T1 inner join FACT_TRANSACTIONS as T2
on T1.IDCustomer = T2.IDCustomer
where year(date) = 2009
group by T1.Customer_Name
having Avg(TotalPrice) > 500

--Q6--END
	
--Q7--BEGIN

Select top 5 Model_Name, count(quantity) as Qty from FACT_TRANSACTIONS as T1 inner join DIM_MODEL as T2
on t1.IDModel = T2.IDModel
where year(date) in (2008, 2009, 2010)
group by Model_Name
order by count(quantity) desc

--Q7--END

--Q8--BEGIN

select * from (select top 1 manufacturer_name, sum(TotalPrice) as sales from DIM_MANUFACTURER as T1 inner join DIM_MODEL as T2
on T1.IDManufacturer = T2.IDManufacturer inner join FACT_TRANSACTIONS as T3
on T2.IDModel = T3.IDModel
where year(date) = 2009
group by Manufacturer_Name
having max(TotalPrice) < (select max(TotalPrice) from FACT_TRANSACTIONS)
order by sales desc as x
union
select top 1 manufacturer_name, sum(TotalPrice) as sales from DIM_MANUFACTURER as T1 inner join DIM_MODEL as T2
on T1.IDManufacturer = T2.IDManufacturer inner join FACT_TRANSACTIONS as T3
on T2.IDModel = T3.IDModel
where year(date) = 2010
group by Manufacturer_Name
having max(totalprice) < (select max(TotalPrice) from FACT_TRANSACTIONS)
order by sales desc


--Q8--END

--Q9--BEGIN

select Manufacturer_Name from DIM_MANUFACTURER as T1 inner join DIM_MODEL as T2
on T1.IDManufacturer = T2.IDManufacturer inner join FACT_TRANSACTIONS as T3
on T2.IDModel = T3.IDModel
where year(date) = 2010
except
select Manufacturer_Name from DIM_MANUFACTURER as T1 inner join DIM_MODEL as T2
on T1.IDManufacturer = T2.IDManufacturer inner join FACT_TRANSACTIONS as T3
on T2.IDModel = T3.IDModel
where year(date) = 2009

--Q9--END

--Q10--BEGIN

with top_customers as (select top 10
 customer_name, t1.idcustomer, sum(totalprice) as total_spend
 from FACT_TRANSACTIONS as t1
 inner join DIM_CUSTOMER as t2 on
 t1.IDCustomer = t2.IDCustomer
 group by
 t1.IDCustomer, Customer_Name
 order by total_spend desc),
 average as
 (select Customer_name,
 T3.Idcustomer, year(T3.date) as
 [year],avg(t3.quantity) as
 average_quantity, avg(t3.totalprice)
 as average_spend
 From FACT_TRANSACTIONS T3
 Inner join top_customers T4 on
 T4.IDCustomer = T3.IDCustomer
 Group by Customer_Name,
 T3.IDCustomer,T3.Date)
 Select Customer_name,Year,average_quantity,Average_spend,
 ((Average_spend - lag(average_spend,1)
 Over(partition by idcustomer order by [year])) / Average_spend)*100 as 
 percentage_of_change
 From average

--Q10--END
	