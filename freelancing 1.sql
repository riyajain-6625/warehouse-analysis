-- How many shipments do we receive each month, and what percentage are successfully delivered?
select month(order_at)",month" ,count(*) as "total shipments"  from shipments 
group by  month(order_at)
order by month(order_at);

select count(*) * 100 /(select count(*) from shipments)  from shipments 
where  status="Delivered";

-- Of the shipments delivered, what percentage reach customers within the promised delivery time?
 select  sum(Datediff(promised_delivery_at,delivered_at)/100 )as "reached  on time "
 from shipments 
 where   status="Delivered";
-- Which warehouses take the longest to dispatch orders? Please compare average and maximum order-to-dispatch time in hours, excluding cancelled shipments.
select max(Datediff(promised_delivery_at,delivered_at))  as"longest shipment"from shipments
 where status="Delivered";
 select max(timestampdiff(HOUR, order_at, dispatch_at)) as "maximus order dispatch time"
 from shipments
 where status="Delivered";
 select avg(timestampdiff(HOUR, order_at, dispatch_at)) as "avg order dispatch time"
 from shipments
 where status="Delivered";
-- How do our courier partners compare on average delivery time, measured from dispatch to delivery?
SELECT
    c.carrier_id,
    AVG(
        TIMESTAMPDIFF(HOUR, s.dispatch_at, s.delivered_at)
    ) AS avg_delivery_hours
FROM carriers AS c
JOIN shipments AS s
    ON c.carrier_id = s.carrier_id
WHERE s.status = 'Delivered'
GROUP BY c.carrier_id
ORDER BY avg_delivery_hours;
-- Which courier partners have the highest late-delivery rates? Please include only partners with at least 30 delivered shipments.

SELECT   carrier_name ,COUNT(*) AS late_deliveries
FROM shipments s 
join carriers c
on c.carrier_id=s.carrier_id
WHERE status = 'Delivered'
  AND delivered_at > promised_delivery_at
group by carrier_name;
-- Which destination regions have the highest percentage of late deliveries?
select reigon ,  max(delivered_at > promised_delivery_at)*100
from shipments s 
join  warehouse where
w.warehouse_id= s.warehouse_id
group by reigon;

-- How much shipping margin does each courier partner generate? Use shipping fee minus shipping cost for delivered shipments.
 
select   c.carrier_name ,sum(s.shipping_fee-s.shipping_cost) as"margin" from shipments s
join logistics.carriers c
on c.carrier_id= s.carrier_id
group by c.carrier_name
;
-- Please identify the 10 delivered shipments where shipping costs exceeded shipping fees by the largest amount.
 select  *from shipments
 where shipping_fee>shipping_cost 
 order by shipping_fee limit 10;
-- Were there any days when a warehouse dispatched more shipments than its daily capacity? Please show the warehouse, date and excess volume.
SELECT
    w.warehouse_id,
    SUM(DAY(s.dispatch_at) - w.daily_dispatch_capacity) AS "exceed volume"
FROM shipments s
JOIN warehouses w
    ON w.warehouse_id = s.warehouse_id
WHERE DAY(s.dispatch_at) > w.daily_dispatch_capacity
GROUP BY w.warehouse_id;

-- How has our shipping margin changed month over month, based on the delivery date?
select month(delivered_at) , count(*)*100 /( select count(*) as "delivery rate" from shipments)  as "delivery rate" , sum(shipping_fee- shipping_cost) as "margin" 
from shipments
where status="delivered"
group by month(delivered_at) 
order by month(delivered_at)  ;

-- Which warehouses have the highest cancellation rates? Please include total shipments and cancelled shipments for context.

SELECT
    COUNT(*) AS "total shipments",
    (SELECT COUNT(*) FROM shipments WHERE status = 'Cancelled') AS "cancelled shipments",
    (SELECT COUNT(*) FROM shipments WHERE status = 'Cancelled') * 100.0 / COUNT(*) AS "cancelled rate"
FROM shipments;




-- For late deliveries, how many hours late do shipments arrive on average, and which courier partner has the highest average delay?
select  c.carrier_name, avg(timestampdiff(HOUR, order_at, dispatch_at)) as"avg late aarival hour" from shipments s
join  carriers c
on  c.carrier_id=s.carrier_id
group by  c.carrier_name 
order by  c.carrier_name, max(timestampdiff(HOUR, order_at, dispatch_at));
-- limit 1 ;

 -- Which warehouse-and-courier combinations have the highest on-time delivery rates? Please include only combinations with at least 30 delivered shipments.
 select  w.warehouse_id ,
c.carrier_name ,
max(timestampdiff(hour,s.order_at, s.dispatch_at)) as "max dispatch hour"
 from shipments s
 join  warehouses w 
 on w.warehouse_id= s.warehouse_id
 join  carriers c
 on s.carrier_id=c.carrier_id
 group by c.carrier_name ,w.warehouse_id;
 

-- How do Standard and Express services compare on average delivery time, on-time delivery rate and average shipping cost per delivered shipment?

SELECT
    c.service_type,
    AVG(TIMESTAMPDIFF(HOUR, s.dispatch_at, s.delivered_at)) AS "avg delivery hours",
    SUM(s.delivered_at <= s.promised_delivery_at) * 100.0 / COUNT(*) AS "on-time delivery rate",
    AVG(s.shipping_cost) AS "avg shipping cost"
FROM shipments s
join  carriers c
on s.carrier_id=c.carrier_id
WHERE s.status = 'Delivered'
    AND c.service_type IN ('Standard', 'Express')
GROUP BY  c.service_type;


