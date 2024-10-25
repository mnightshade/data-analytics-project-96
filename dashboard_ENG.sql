--Dashbord : https://6c897994.us2a.app.preset.io/superset/dashboard/10/?native_filters_key=QY18IDYWkpHS3GEJC5Oz0IwFR_HpISJrRv3HS-y3crQdrgmjpqxOp4gyXeUYb9au
-- Number of visitors
select COUNT(distinct visitor_id)
from sessions s 
where visitor_id is not null;

-- Most popular channel
select source, count(source)
from sessions
group by source
order by count(source) desc 
limit 1;

-- Most popular course
select campaign, count(campaign)
from sessions
group by campaign 
order by count(campaign) desc 
limit 1;

-- Visitors by channel and date
select date(visit_date), source, count(source)
from sessions
group by 1, 2
order by 3 desc;

-- Pie chart by channels
select source, count(source)
from sessions
group by 1
order by 2 desc;

-- Pie chart by medium
select medium, count(medium)
from sessions
group by 1
order by 2 desc;

-- Pie chart by courses
select campaign, count(campaign)
from sessions
group by 1
order by 2 desc;

-- Mediums by date
select date(visit_date), medium, count(medium)
from sessions
group by 1, 2
order by 3 desc;

-- Courses by date
select date(visit_date), campaign, count(campaign)
from sessions
group by 1, 2
order by 3 desc;

-- Conversion from click to lead
with l_c as (
    select date(created_at) as d, count(lead_id) as c
    from leads l
    group by 1
),
v_c as (
    select date(s.visit_date) as d, count(distinct s.visitor_id) as c
    from sessions s
    group by 1
)
select v_c.d as date, round((l_c.c * 1.00 / v_c.c) * 100, 3) as conversion
from v_c
inner join l_c on l_c.d = v_c.d;

-- Conversion from lead to deal by Last Paid Click
select visit_date, (leads_count * 1.00 / purchase_count) * 100
from aggregate_last_paid_click;

-- Advertising costs by channel
select visit_date, utm_source, total_coast
from aggregate_last_paid_click;

-- Advertising costs by courses
select utm_campaign, total_coast
from aggregate_last_paid_click;

-- Advertising return on investment
select utm_campaign, revenue - total_coast
from aggregate_last_paid_click
group by 1;

-- Advertising return on investment
select utm_source, revenue - total_coast
from aggregate_last_paid_click
group by 1;

-- Metrics
select utm_source, utm_medium, utm_campaign, visit_date,
total_cost / visitors_count as cpu,
total_cost / leads_count as cpl,
total_cost / purchases_count as cppu,
(revenue - total_cost) / total_cost * 100 as roi
from aggregate_last_paid_click;

-- Organic correlation by date
select date(visit_date), medium, count(medium)
from sessions
group by 1, 2
having medium = 'organic'
order by 1;
