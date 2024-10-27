INSERT INTO "with union_ads as (
    select
        utm_source,
        utm_medium,
        utm_campaign,
        date(campaign_date) as campaign_date,
        sum(daily_spent) as total_coast -- вывожу затраты по дням и моделям
    from ya_ads
    group by 1, 2, 3, 4
    union -- Объединяю таблицы ya_ads и vk_ads
    select
        utm_source,
        utm_medium,
        utm_campaign,
        date(campaign_date) as campaign_date,
        sum(daily_spent) as total_coast
    from vk_ads
    group by 1, 2, 3, 4
),
tab as (
    select
        l.visitor_id,
        s.visit_date,
        s.source as utm_source,
        s.medium as utm_medium,
        s.campaign as utm_campaign,
        l.lead_id,
        l.created_at,
        l.closing_reason,
        l.status_id,
        --Сумма по посетителю
        sum(l.amount) over (partition by l.visitor_id) as amount,
        row_number()
            over (partition by l.visitor_id order by s.visit_date desc)
        as r_n -- Сортириую клики по дате ,чтобы выбрать самый последний клик
    from leads as l
    full join sessions as s
        on l.visitor_id = s.visitor_id
    where s.visitor_id is not null --Отбрасываю не посетивших
    -- Выбираю только платные клики
    and s.medium in ('cpc', 'cpm', 'cpa', 'youtube', 'cpp', 'tg', 'social')
),
tab2 as (select * from tab where r_n = 1), -- Витрина с данными last Paid Click
tab3 as (    --Агрегирую данные
    select
        date(visit_date) as visit_date,
        utm_source,
        utm_medium,
        utm_campaign,
        count(distinct visitor_id) as visitor_count,
        count(lead_id) as leads_count,
        count(amount)
        filter (
            where closing_reason = 'Успешно реализованно' or status_id = 142
        )
        as purchase_count,
        sum(amount) as revenue
    from tab2
    group by 1, 2, 3, 4
)
select   --Вывожу необходимые столбики
    t3.visit_date,
    t3.utm_source,
    t3.utm_medium,
    t3.utm_campaign,
    t3.visitor_count,
    ua.total_coast,
    t3.leads_count,
    t3.purchase_count,
    t3.revenue
from tab3 as t3
left join union_ads as ua --Подтягиваю затраты на рекламу
    on
        t3.visit_date = ua.campaign_date
        and t3.utm_source = ua.utm_source
        and t3.utm_medium = ua.utm_medium
        and t3.utm_campaign = ua.utm_campaign
order by
    t3.revenue desc nulls last,
    t3.visit_date asc,
    t3.visitor_count desc,
    t3.utm_source asc,
    t3.utm_medium asc,
    t3.utm_campaign asc" (visit_date,utm_source,utm_medium,utm_campaign,visitor_count,total_coast,leads_count,purchase_count,revenue) VALUES
	 ('2023-06-01','yandex','cpc','freemium',103,21654,103,25,2397711),
	 ('2023-06-30','admitad','cpa','admitad',2,NULL,2,2,1810350),
	 ('2023-06-20','telegram','cpp','base-java',1,NULL,1,1,1511920),
	 ('2023-06-01','yandex','cpc','prof-frontend',78,57138,78,12,1228748),
	 ('2023-06-01','yandex','cpc','prof-python',62,33026,62,7,805620),
	 ('2023-06-01','yandex','cpc','base-python',31,12524,31,7,562101),
	 ('2023-06-01','vk','cpc','prof-java',23,3115,23,2,465452),
	 ('2023-06-01','yandex','cpc','prof-data-analytics',14,10086,14,2,372304),
	 ('2023-06-01','yandex','cpc','prof-java',49,29490,49,4,368840),
	 ('2023-06-20','admitad','cpa','admitad',3,NULL,3,1,363280);
INSERT INTO "with union_ads as (
    select
        utm_source,
        utm_medium,
        utm_campaign,
        date(campaign_date) as campaign_date,
        sum(daily_spent) as total_coast -- вывожу затраты по дням и моделям
    from ya_ads
    group by 1, 2, 3, 4
    union -- Объединяю таблицы ya_ads и vk_ads
    select
        utm_source,
        utm_medium,
        utm_campaign,
        date(campaign_date) as campaign_date,
        sum(daily_spent) as total_coast
    from vk_ads
    group by 1, 2, 3, 4
),
tab as (
    select
        l.visitor_id,
        s.visit_date,
        s.source as utm_source,
        s.medium as utm_medium,
        s.campaign as utm_campaign,
        l.lead_id,
        l.created_at,
        l.closing_reason,
        l.status_id,
        --Сумма по посетителю
        sum(l.amount) over (partition by l.visitor_id) as amount,
        row_number()
            over (partition by l.visitor_id order by s.visit_date desc)
        as r_n -- Сортириую клики по дате ,чтобы выбрать самый последний клик
    from leads as l
    full join sessions as s
        on l.visitor_id = s.visitor_id
    where s.visitor_id is not null --Отбрасываю не посетивших
    -- Выбираю только платные клики
    and s.medium in ('cpc', 'cpm', 'cpa', 'youtube', 'cpp', 'tg', 'social')
),
tab2 as (select * from tab where r_n = 1), -- Витрина с данными last Paid Click
tab3 as (    --Агрегирую данные
    select
        date(visit_date) as visit_date,
        utm_source,
        utm_medium,
        utm_campaign,
        count(distinct visitor_id) as visitor_count,
        count(lead_id) as leads_count,
        count(amount)
        filter (
            where closing_reason = 'Успешно реализованно' or status_id = 142
        )
        as purchase_count,
        sum(amount) as revenue
    from tab2
    group by 1, 2, 3, 4
)
select   --Вывожу необходимые столбики
    t3.visit_date,
    t3.utm_source,
    t3.utm_medium,
    t3.utm_campaign,
    t3.visitor_count,
    ua.total_coast,
    t3.leads_count,
    t3.purchase_count,
    t3.revenue
from tab3 as t3
left join union_ads as ua --Подтягиваю затраты на рекламу
    on
        t3.visit_date = ua.campaign_date
        and t3.utm_source = ua.utm_source
        and t3.utm_medium = ua.utm_medium
        and t3.utm_campaign = ua.utm_campaign
order by
    t3.revenue desc nulls last,
    t3.visit_date asc,
    t3.visitor_count desc,
    t3.utm_source asc,
    t3.utm_medium asc,
    t3.utm_campaign asc" (visit_date,utm_source,utm_medium,utm_campaign,visitor_count,total_coast,leads_count,purchase_count,revenue) VALUES
	 ('2023-06-01','vk','cpc','prof-python',40,2028,40,5,355564),
	 ('2023-06-01','vk','cpc','freemium-frontend',43,3160,43,5,338083),
	 ('2023-06-01','yandex','cpc','base-frontend',40,18061,40,3,271440),
	 ('2023-06-01','yandex','cpc','base-professions-retarget',4,151,4,1,268200),
	 ('2023-06-01','yandex','cpc','prof-professions-brand',13,4818,13,3,237342),
	 ('2023-06-07','vk','social','hexlet-blog',1,NULL,1,1,168000),
	 ('2023-06-01','yandex','cpc','dod-php',4,5964,4,1,150255),
	 ('2023-06-01','yandex','cpc','base-java',20,19252,20,1,144000),
	 ('2023-06-13','admitad','cpa','admitad',1,NULL,1,1,62000),
	 ('2023-06-01','yandex','cpc','dod-professions',6,NULL,6,1,37800);
INSERT INTO "with union_ads as (
    select
        utm_source,
        utm_medium,
        utm_campaign,
        date(campaign_date) as campaign_date,
        sum(daily_spent) as total_coast -- вывожу затраты по дням и моделям
    from ya_ads
    group by 1, 2, 3, 4
    union -- Объединяю таблицы ya_ads и vk_ads
    select
        utm_source,
        utm_medium,
        utm_campaign,
        date(campaign_date) as campaign_date,
        sum(daily_spent) as total_coast
    from vk_ads
    group by 1, 2, 3, 4
),
tab as (
    select
        l.visitor_id,
        s.visit_date,
        s.source as utm_source,
        s.medium as utm_medium,
        s.campaign as utm_campaign,
        l.lead_id,
        l.created_at,
        l.closing_reason,
        l.status_id,
        --Сумма по посетителю
        sum(l.amount) over (partition by l.visitor_id) as amount,
        row_number()
            over (partition by l.visitor_id order by s.visit_date desc)
        as r_n -- Сортириую клики по дате ,чтобы выбрать самый последний клик
    from leads as l
    full join sessions as s
        on l.visitor_id = s.visitor_id
    where s.visitor_id is not null --Отбрасываю не посетивших
    -- Выбираю только платные клики
    and s.medium in ('cpc', 'cpm', 'cpa', 'youtube', 'cpp', 'tg', 'social')
),
tab2 as (select * from tab where r_n = 1), -- Витрина с данными last Paid Click
tab3 as (    --Агрегирую данные
    select
        date(visit_date) as visit_date,
        utm_source,
        utm_medium,
        utm_campaign,
        count(distinct visitor_id) as visitor_count,
        count(lead_id) as leads_count,
        count(amount)
        filter (
            where closing_reason = 'Успешно реализованно' or status_id = 142
        )
        as purchase_count,
        sum(amount) as revenue
    from tab2
    group by 1, 2, 3, 4
)
select   --Вывожу необходимые столбики
    t3.visit_date,
    t3.utm_source,
    t3.utm_medium,
    t3.utm_campaign,
    t3.visitor_count,
    ua.total_coast,
    t3.leads_count,
    t3.purchase_count,
    t3.revenue
from tab3 as t3
left join union_ads as ua --Подтягиваю затраты на рекламу
    on
        t3.visit_date = ua.campaign_date
        and t3.utm_source = ua.utm_source
        and t3.utm_medium = ua.utm_medium
        and t3.utm_campaign = ua.utm_campaign
order by
    t3.revenue desc nulls last,
    t3.visit_date asc,
    t3.visitor_count desc,
    t3.utm_source asc,
    t3.utm_medium asc,
    t3.utm_campaign asc" (visit_date,utm_source,utm_medium,utm_campaign,visitor_count,total_coast,leads_count,purchase_count,revenue) VALUES
	 ('2023-06-01','vk','cpc','base-python',36,2537,36,1,9072),
	 ('2023-06-01','vk','cpc','freemium-python',25,980,25,1,1560),
	 ('2023-06-01','vk','cpc','prof-data-analytics',30,1072,30,0,0),
	 ('2023-06-01','vk','cpc','freemium-java',24,487,24,0,0),
	 ('2023-06-01','yandex','cpc','prof-professions-retarget',10,1714,10,0,0),
	 ('2023-06-01','vk','cpc','prof-frontend',7,NULL,7,0,0),
	 ('2023-06-01','vk','cpm','prof-data-analytics',6,385,6,0,0),
	 ('2023-06-01','yandex','cpc','dod-java',4,2906,4,0,0),
	 ('2023-06-01','yandex','cpc','dod-frontend',3,2871,3,0,0),
	 ('2023-06-01','yandex','cpc','dod-python-java',3,NULL,3,0,0);
INSERT INTO "with union_ads as (
    select
        utm_source,
        utm_medium,
        utm_campaign,
        date(campaign_date) as campaign_date,
        sum(daily_spent) as total_coast -- вывожу затраты по дням и моделям
    from ya_ads
    group by 1, 2, 3, 4
    union -- Объединяю таблицы ya_ads и vk_ads
    select
        utm_source,
        utm_medium,
        utm_campaign,
        date(campaign_date) as campaign_date,
        sum(daily_spent) as total_coast
    from vk_ads
    group by 1, 2, 3, 4
),
tab as (
    select
        l.visitor_id,
        s.visit_date,
        s.source as utm_source,
        s.medium as utm_medium,
        s.campaign as utm_campaign,
        l.lead_id,
        l.created_at,
        l.closing_reason,
        l.status_id,
        --Сумма по посетителю
        sum(l.amount) over (partition by l.visitor_id) as amount,
        row_number()
            over (partition by l.visitor_id order by s.visit_date desc)
        as r_n -- Сортириую клики по дате ,чтобы выбрать самый последний клик
    from leads as l
    full join sessions as s
        on l.visitor_id = s.visitor_id
    where s.visitor_id is not null --Отбрасываю не посетивших
    -- Выбираю только платные клики
    and s.medium in ('cpc', 'cpm', 'cpa', 'youtube', 'cpp', 'tg', 'social')
),
tab2 as (select * from tab where r_n = 1), -- Витрина с данными last Paid Click
tab3 as (    --Агрегирую данные
    select
        date(visit_date) as visit_date,
        utm_source,
        utm_medium,
        utm_campaign,
        count(distinct visitor_id) as visitor_count,
        count(lead_id) as leads_count,
        count(amount)
        filter (
            where closing_reason = 'Успешно реализованно' or status_id = 142
        )
        as purchase_count,
        sum(amount) as revenue
    from tab2
    group by 1, 2, 3, 4
)
select   --Вывожу необходимые столбики
    t3.visit_date,
    t3.utm_source,
    t3.utm_medium,
    t3.utm_campaign,
    t3.visitor_count,
    ua.total_coast,
    t3.leads_count,
    t3.purchase_count,
    t3.revenue
from tab3 as t3
left join union_ads as ua --Подтягиваю затраты на рекламу
    on
        t3.visit_date = ua.campaign_date
        and t3.utm_source = ua.utm_source
        and t3.utm_medium = ua.utm_medium
        and t3.utm_campaign = ua.utm_campaign
order by
    t3.revenue desc nulls last,
    t3.visit_date asc,
    t3.visitor_count desc,
    t3.utm_source asc,
    t3.utm_medium asc,
    t3.utm_campaign asc" (visit_date,utm_source,utm_medium,utm_campaign,visitor_count,total_coast,leads_count,purchase_count,revenue) VALUES
	 ('2023-06-01','telegram','cpp','prof-python',1,NULL,1,0,0),
	 ('2023-06-02','telegram','cpp','prof-frontend',1,NULL,1,0,0),
	 ('2023-06-03','vk-senler','cpc','freemium',1,NULL,1,0,0),
	 ('2023-06-04','admitad','cpa','admitad',1,NULL,1,0,0),
	 ('2023-06-04','telegram','cpp','dod-java',1,NULL,1,0,0),
	 ('2023-06-05','vk','cpp','dod-php',1,NULL,1,0,0),
	 ('2023-06-06','vc','cpp','dod-frontend',1,NULL,1,0,0),
	 ('2023-06-06','vk','cpp','dod-php',1,NULL,1,0,0),
	 ('2023-06-06','vk','social','hexlet-blog',1,NULL,1,0,0),
	 ('2023-06-06','vk','social','hexlet.io/my',1,NULL,1,0,0);
INSERT INTO "with union_ads as (
    select
        utm_source,
        utm_medium,
        utm_campaign,
        date(campaign_date) as campaign_date,
        sum(daily_spent) as total_coast -- вывожу затраты по дням и моделям
    from ya_ads
    group by 1, 2, 3, 4
    union -- Объединяю таблицы ya_ads и vk_ads
    select
        utm_source,
        utm_medium,
        utm_campaign,
        date(campaign_date) as campaign_date,
        sum(daily_spent) as total_coast
    from vk_ads
    group by 1, 2, 3, 4
),
tab as (
    select
        l.visitor_id,
        s.visit_date,
        s.source as utm_source,
        s.medium as utm_medium,
        s.campaign as utm_campaign,
        l.lead_id,
        l.created_at,
        l.closing_reason,
        l.status_id,
        --Сумма по посетителю
        sum(l.amount) over (partition by l.visitor_id) as amount,
        row_number()
            over (partition by l.visitor_id order by s.visit_date desc)
        as r_n -- Сортириую клики по дате ,чтобы выбрать самый последний клик
    from leads as l
    full join sessions as s
        on l.visitor_id = s.visitor_id
    where s.visitor_id is not null --Отбрасываю не посетивших
    -- Выбираю только платные клики
    and s.medium in ('cpc', 'cpm', 'cpa', 'youtube', 'cpp', 'tg', 'social')
),
tab2 as (select * from tab where r_n = 1), -- Витрина с данными last Paid Click
tab3 as (    --Агрегирую данные
    select
        date(visit_date) as visit_date,
        utm_source,
        utm_medium,
        utm_campaign,
        count(distinct visitor_id) as visitor_count,
        count(lead_id) as leads_count,
        count(amount)
        filter (
            where closing_reason = 'Успешно реализованно' or status_id = 142
        )
        as purchase_count,
        sum(amount) as revenue
    from tab2
    group by 1, 2, 3, 4
)
select   --Вывожу необходимые столбики
    t3.visit_date,
    t3.utm_source,
    t3.utm_medium,
    t3.utm_campaign,
    t3.visitor_count,
    ua.total_coast,
    t3.leads_count,
    t3.purchase_count,
    t3.revenue
from tab3 as t3
left join union_ads as ua --Подтягиваю затраты на рекламу
    on
        t3.visit_date = ua.campaign_date
        and t3.utm_source = ua.utm_source
        and t3.utm_medium = ua.utm_medium
        and t3.utm_campaign = ua.utm_campaign
order by
    t3.revenue desc nulls last,
    t3.visit_date asc,
    t3.visitor_count desc,
    t3.utm_source asc,
    t3.utm_medium asc,
    t3.utm_campaign asc" (visit_date,utm_source,utm_medium,utm_campaign,visitor_count,total_coast,leads_count,purchase_count,revenue) VALUES
	 ('2023-06-07','telegram','cpp','prof-java',2,NULL,2,0,0),
	 ('2023-06-07','telegram','cpp','dod-java',1,NULL,1,0,0),
	 ('2023-06-08','telegram','cpp','dod-frontend',1,NULL,1,0,0),
	 ('2023-06-08','telegram','cpp','dod-java',1,NULL,1,0,0),
	 ('2023-06-08','telegram','cpp','prof-python',1,NULL,1,0,0),
	 ('2023-06-09','telegram','cpp','prof-java',1,NULL,1,0,0),
	 ('2023-06-09','vk','cpc','prof-frontend',1,5077,1,0,0),
	 ('2023-06-13','vk','cpc','freemium-frontend',1,2746,1,0,0),
	 ('2023-06-13','vk','cpc','prof-java',1,4350,1,0,0),
	 ('2023-06-14','telegram','social','dod-professions',3,NULL,3,0,0);
INSERT INTO "with union_ads as (
    select
        utm_source,
        utm_medium,
        utm_campaign,
        date(campaign_date) as campaign_date,
        sum(daily_spent) as total_coast -- вывожу затраты по дням и моделям
    from ya_ads
    group by 1, 2, 3, 4
    union -- Объединяю таблицы ya_ads и vk_ads
    select
        utm_source,
        utm_medium,
        utm_campaign,
        date(campaign_date) as campaign_date,
        sum(daily_spent) as total_coast
    from vk_ads
    group by 1, 2, 3, 4
),
tab as (
    select
        l.visitor_id,
        s.visit_date,
        s.source as utm_source,
        s.medium as utm_medium,
        s.campaign as utm_campaign,
        l.lead_id,
        l.created_at,
        l.closing_reason,
        l.status_id,
        --Сумма по посетителю
        sum(l.amount) over (partition by l.visitor_id) as amount,
        row_number()
            over (partition by l.visitor_id order by s.visit_date desc)
        as r_n -- Сортириую клики по дате ,чтобы выбрать самый последний клик
    from leads as l
    full join sessions as s
        on l.visitor_id = s.visitor_id
    where s.visitor_id is not null --Отбрасываю не посетивших
    -- Выбираю только платные клики
    and s.medium in ('cpc', 'cpm', 'cpa', 'youtube', 'cpp', 'tg', 'social')
),
tab2 as (select * from tab where r_n = 1), -- Витрина с данными last Paid Click
tab3 as (    --Агрегирую данные
    select
        date(visit_date) as visit_date,
        utm_source,
        utm_medium,
        utm_campaign,
        count(distinct visitor_id) as visitor_count,
        count(lead_id) as leads_count,
        count(amount)
        filter (
            where closing_reason = 'Успешно реализованно' or status_id = 142
        )
        as purchase_count,
        sum(amount) as revenue
    from tab2
    group by 1, 2, 3, 4
)
select   --Вывожу необходимые столбики
    t3.visit_date,
    t3.utm_source,
    t3.utm_medium,
    t3.utm_campaign,
    t3.visitor_count,
    ua.total_coast,
    t3.leads_count,
    t3.purchase_count,
    t3.revenue
from tab3 as t3
left join union_ads as ua --Подтягиваю затраты на рекламу
    on
        t3.visit_date = ua.campaign_date
        and t3.utm_source = ua.utm_source
        and t3.utm_medium = ua.utm_medium
        and t3.utm_campaign = ua.utm_campaign
order by
    t3.revenue desc nulls last,
    t3.visit_date asc,
    t3.visitor_count desc,
    t3.utm_source asc,
    t3.utm_medium asc,
    t3.utm_campaign asc" (visit_date,utm_source,utm_medium,utm_campaign,visitor_count,total_coast,leads_count,purchase_count,revenue) VALUES
	 ('2023-06-14','vc','cpp','dod-frontend',2,NULL,2,0,0),
	 ('2023-06-15','dzen','social','dzen_post',1,NULL,1,0,0),
	 ('2023-06-15','vk','cpc','prof-frontend',1,4688,1,0,0),
	 ('2023-06-16','telegram','social','dod-professions',1,NULL,1,0,0),
	 ('2023-06-16','vk','cpc','prof-frontend',1,5458,1,0,0),
	 ('2023-06-16','vk','cpc','prof-java',1,4427,1,0,0),
	 ('2023-06-16','vk','cpc','prof-python',1,5838,1,0,0),
	 ('2023-06-18','vk','social','dod-professions',1,NULL,1,0,0),
	 ('2023-06-20','instagram','social','prof-qa-auto',1,NULL,1,0,0),
	 ('2023-06-20','telegram','social','dod-professions',1,NULL,1,0,0);
INSERT INTO "with union_ads as (
    select
        utm_source,
        utm_medium,
        utm_campaign,
        date(campaign_date) as campaign_date,
        sum(daily_spent) as total_coast -- вывожу затраты по дням и моделям
    from ya_ads
    group by 1, 2, 3, 4
    union -- Объединяю таблицы ya_ads и vk_ads
    select
        utm_source,
        utm_medium,
        utm_campaign,
        date(campaign_date) as campaign_date,
        sum(daily_spent) as total_coast
    from vk_ads
    group by 1, 2, 3, 4
),
tab as (
    select
        l.visitor_id,
        s.visit_date,
        s.source as utm_source,
        s.medium as utm_medium,
        s.campaign as utm_campaign,
        l.lead_id,
        l.created_at,
        l.closing_reason,
        l.status_id,
        --Сумма по посетителю
        sum(l.amount) over (partition by l.visitor_id) as amount,
        row_number()
            over (partition by l.visitor_id order by s.visit_date desc)
        as r_n -- Сортириую клики по дате ,чтобы выбрать самый последний клик
    from leads as l
    full join sessions as s
        on l.visitor_id = s.visitor_id
    where s.visitor_id is not null --Отбрасываю не посетивших
    -- Выбираю только платные клики
    and s.medium in ('cpc', 'cpm', 'cpa', 'youtube', 'cpp', 'tg', 'social')
),
tab2 as (select * from tab where r_n = 1), -- Витрина с данными last Paid Click
tab3 as (    --Агрегирую данные
    select
        date(visit_date) as visit_date,
        utm_source,
        utm_medium,
        utm_campaign,
        count(distinct visitor_id) as visitor_count,
        count(lead_id) as leads_count,
        count(amount)
        filter (
            where closing_reason = 'Успешно реализованно' or status_id = 142
        )
        as purchase_count,
        sum(amount) as revenue
    from tab2
    group by 1, 2, 3, 4
)
select   --Вывожу необходимые столбики
    t3.visit_date,
    t3.utm_source,
    t3.utm_medium,
    t3.utm_campaign,
    t3.visitor_count,
    ua.total_coast,
    t3.leads_count,
    t3.purchase_count,
    t3.revenue
from tab3 as t3
left join union_ads as ua --Подтягиваю затраты на рекламу
    on
        t3.visit_date = ua.campaign_date
        and t3.utm_source = ua.utm_source
        and t3.utm_medium = ua.utm_medium
        and t3.utm_campaign = ua.utm_campaign
order by
    t3.revenue desc nulls last,
    t3.visit_date asc,
    t3.visitor_count desc,
    t3.utm_source asc,
    t3.utm_medium asc,
    t3.utm_campaign asc" (visit_date,utm_source,utm_medium,utm_campaign,visitor_count,total_coast,leads_count,purchase_count,revenue) VALUES
	 ('2023-06-20','vc','cpp','dod-professions',1,NULL,1,0,0),
	 ('2023-06-20','vk','cpc','freemium-frontend',1,2851,1,0,0),
	 ('2023-06-21','telegram','cpp','prof-python',1,NULL,1,0,0),
	 ('2023-06-21','telegram','social','dod-professions',1,NULL,1,0,0),
	 ('2023-06-22','vk','social','all-courses',1,NULL,1,0,0),
	 ('2023-06-23','admitad','cpa','admitad',1,NULL,1,0,0),
	 ('2023-06-23','telegram','cpp','prof-java',1,NULL,1,0,0),
	 ('2023-06-23','telegram','social','hexlet-blog',1,NULL,1,0,0),
	 ('2023-06-24','admitad','cpa','admitad',2,NULL,2,0,0),
	 ('2023-06-24','vk','cpc','freemium-python',1,2273,1,0,0);
INSERT INTO "with union_ads as (
    select
        utm_source,
        utm_medium,
        utm_campaign,
        date(campaign_date) as campaign_date,
        sum(daily_spent) as total_coast -- вывожу затраты по дням и моделям
    from ya_ads
    group by 1, 2, 3, 4
    union -- Объединяю таблицы ya_ads и vk_ads
    select
        utm_source,
        utm_medium,
        utm_campaign,
        date(campaign_date) as campaign_date,
        sum(daily_spent) as total_coast
    from vk_ads
    group by 1, 2, 3, 4
),
tab as (
    select
        l.visitor_id,
        s.visit_date,
        s.source as utm_source,
        s.medium as utm_medium,
        s.campaign as utm_campaign,
        l.lead_id,
        l.created_at,
        l.closing_reason,
        l.status_id,
        --Сумма по посетителю
        sum(l.amount) over (partition by l.visitor_id) as amount,
        row_number()
            over (partition by l.visitor_id order by s.visit_date desc)
        as r_n -- Сортириую клики по дате ,чтобы выбрать самый последний клик
    from leads as l
    full join sessions as s
        on l.visitor_id = s.visitor_id
    where s.visitor_id is not null --Отбрасываю не посетивших
    -- Выбираю только платные клики
    and s.medium in ('cpc', 'cpm', 'cpa', 'youtube', 'cpp', 'tg', 'social')
),
tab2 as (select * from tab where r_n = 1), -- Витрина с данными last Paid Click
tab3 as (    --Агрегирую данные
    select
        date(visit_date) as visit_date,
        utm_source,
        utm_medium,
        utm_campaign,
        count(distinct visitor_id) as visitor_count,
        count(lead_id) as leads_count,
        count(amount)
        filter (
            where closing_reason = 'Успешно реализованно' or status_id = 142
        )
        as purchase_count,
        sum(amount) as revenue
    from tab2
    group by 1, 2, 3, 4
)
select   --Вывожу необходимые столбики
    t3.visit_date,
    t3.utm_source,
    t3.utm_medium,
    t3.utm_campaign,
    t3.visitor_count,
    ua.total_coast,
    t3.leads_count,
    t3.purchase_count,
    t3.revenue
from tab3 as t3
left join union_ads as ua --Подтягиваю затраты на рекламу
    on
        t3.visit_date = ua.campaign_date
        and t3.utm_source = ua.utm_source
        and t3.utm_medium = ua.utm_medium
        and t3.utm_campaign = ua.utm_campaign
order by
    t3.revenue desc nulls last,
    t3.visit_date asc,
    t3.visitor_count desc,
    t3.utm_source asc,
    t3.utm_medium asc,
    t3.utm_campaign asc" (visit_date,utm_source,utm_medium,utm_campaign,visitor_count,total_coast,leads_count,purchase_count,revenue) VALUES
	 ('2023-06-24','vk','social','hexlet-blog',1,NULL,1,0,0),
	 ('2023-06-26','admitad','cpa','admitad',1,NULL,1,0,0),
	 ('2023-06-26','zen','social','all-courses',1,NULL,1,0,0),
	 ('2023-06-27','telegram','cpp','prof-java',1,NULL,1,0,0),
	 ('2023-06-27','telegram','social','hexlet-blog',1,NULL,1,0,0),
	 ('2023-06-28','admitad','cpa','admitad',1,NULL,1,0,0),
	 ('2023-06-28','telegram','social','hexlet-blog',1,NULL,1,0,0),
	 ('2023-06-28','vk','cpc','freemium-python',1,1954,1,0,0),
	 ('2023-06-29','telegram','cpp','prof-java',1,NULL,1,0,0),
	 ('2023-06-29','telegram','cpp','prof-python',1,NULL,1,0,0);
INSERT INTO "with union_ads as (
    select
        utm_source,
        utm_medium,
        utm_campaign,
        date(campaign_date) as campaign_date,
        sum(daily_spent) as total_coast -- вывожу затраты по дням и моделям
    from ya_ads
    group by 1, 2, 3, 4
    union -- Объединяю таблицы ya_ads и vk_ads
    select
        utm_source,
        utm_medium,
        utm_campaign,
        date(campaign_date) as campaign_date,
        sum(daily_spent) as total_coast
    from vk_ads
    group by 1, 2, 3, 4
),
tab as (
    select
        l.visitor_id,
        s.visit_date,
        s.source as utm_source,
        s.medium as utm_medium,
        s.campaign as utm_campaign,
        l.lead_id,
        l.created_at,
        l.closing_reason,
        l.status_id,
        --Сумма по посетителю
        sum(l.amount) over (partition by l.visitor_id) as amount,
        row_number()
            over (partition by l.visitor_id order by s.visit_date desc)
        as r_n -- Сортириую клики по дате ,чтобы выбрать самый последний клик
    from leads as l
    full join sessions as s
        on l.visitor_id = s.visitor_id
    where s.visitor_id is not null --Отбрасываю не посетивших
    -- Выбираю только платные клики
    and s.medium in ('cpc', 'cpm', 'cpa', 'youtube', 'cpp', 'tg', 'social')
),
tab2 as (select * from tab where r_n = 1), -- Витрина с данными last Paid Click
tab3 as (    --Агрегирую данные
    select
        date(visit_date) as visit_date,
        utm_source,
        utm_medium,
        utm_campaign,
        count(distinct visitor_id) as visitor_count,
        count(lead_id) as leads_count,
        count(amount)
        filter (
            where closing_reason = 'Успешно реализованно' or status_id = 142
        )
        as purchase_count,
        sum(amount) as revenue
    from tab2
    group by 1, 2, 3, 4
)
select   --Вывожу необходимые столбики
    t3.visit_date,
    t3.utm_source,
    t3.utm_medium,
    t3.utm_campaign,
    t3.visitor_count,
    ua.total_coast,
    t3.leads_count,
    t3.purchase_count,
    t3.revenue
from tab3 as t3
left join union_ads as ua --Подтягиваю затраты на рекламу
    on
        t3.visit_date = ua.campaign_date
        and t3.utm_source = ua.utm_source
        and t3.utm_medium = ua.utm_medium
        and t3.utm_campaign = ua.utm_campaign
order by
    t3.revenue desc nulls last,
    t3.visit_date asc,
    t3.visitor_count desc,
    t3.utm_source asc,
    t3.utm_medium asc,
    t3.utm_campaign asc" (visit_date,utm_source,utm_medium,utm_campaign,visitor_count,total_coast,leads_count,purchase_count,revenue) VALUES
	 ('2023-06-29','vk','cpc','prof-frontend',1,5442,1,0,0),
	 ('2023-06-29','vk-senler','cpc','dod-frontend',1,NULL,1,0,0),
	 ('2023-06-30','telegram','cpp','prof-java',1,NULL,1,0,0),
	 ('2023-06-30','telegram','cpp','prof-python',1,NULL,1,0,0),
	 ('2023-06-30','vk','cpc','freemium-python',1,2101,1,0,0),
	 ('2023-06-30','vk','cpc','prof-frontend',1,4306,1,0,0),
	 ('2023-06-30','vk','cpc','prof-python',0,4989,0,0,NULL);
