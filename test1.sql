create database smart_farm;
use smart_farm;

-- tạo bảng zones
create table zones (
    zone_id varchar(5) primary key,
    zone_name varchar(100) not null,
    area_square_meters decimal(10,2) not null,
    light_condition varchar(50) not null,
    status varchar(20) not null
);

-- tạo bảng crops
create table crops (
    crop_id varchar(5) primary key,
    crop_name varchar(100) not null unique,
    growth_time_days int not null,
    water_requirement varchar(50) not null,
    expected_yield decimal(10,2) not null
);

-- tạo bảng planting_logs
create table planting_logs (
    log_id int auto_increment primary key,
    zone_id varchar(5) not null,
    crop_id varchar(5) not null,
    planting_date date not null,
    last_watered datetime,
    is_automated boolean not null,
    unique(zone_id, crop_id),
    foreign key (zone_id) references zones(zone_id),
    foreign key (crop_id) references crops(crop_id)
);

-- tạo bảng harvests
create table harvests (
    harvest_id int auto_increment primary key,
    log_id int not null,
    harvest_date date not null,
    actual_yield decimal(10,2) not null,
    quality_grade varchar(10) not null,
    foreign key (log_id) references planting_logs(log_id)
);

-- insert bảng zones (viết hoa chữ cái đầu)
insert into zones values
('Z01','Khu Nhà Màng 01',50.5,'Full Sun','Occupied'),
('Z02','Khu Thủy Canh 02',30.0,'Partial Shade','Occupied'),
('Z03','Vườn Rau Gia Vị',15.0,'Full Sun','Available'),
('Z04','Nhà Kính Trung Tâm',100.0,'Full Sun','Occupied'),
('Z05','Khu Thực Nghiệm',25.0,'Shade','Maintenance');

-- insert bảng crops (viết hoa tên cây)
insert into crops values
('C01','Xà Lách Thủy Tinh',45,'High',2.5),
('C02','Cà Chua Cherry',90,'Medium',5.0),
('C03','Cải Bó Xôi',35,'High',1.8),
('C04','Dưa Lưới Nhật',85,'Medium',4.0),
('C05','Ớt Chuông',110,'Medium',3.5);

-- insert bảng planting_logs
insert into planting_logs values
(1,'Z01','C02','2025-10-01','2025-11-10 08:00:00',1),
(2,'Z02','C01','2025-11-05','2025-11-10 17:30:00',1),
(3,'Z01','C03','2025-11-08',null,0),
(4,'Z04','C04','2025-09-15','2025-11-11 09:00:00',1),
(5,'Z04','C05','2025-11-01','2025-11-11 10:00:00',1);

-- insert bảng harvests
insert into harvests values
(1,1,'2025-12-30',250.0,'A'),
(2,4,'2025-12-10',380.5,'A'),
(3,5,'2025-11-25',65.0,'B'),
(4,2,'2025-12-20',0.0,'C');


set sql_safe_updates = 0;
-- tăng expected_yield cây c01 thêm 10%
update crops
set expected_yield = expected_yield * 1.1
where crop_id='C01';

-- cập nhật status z03
update zones
set status='maintenance'
where zone_id = 'Z03';

-- xóa harvest không đạt
delete from harvests
where actual_yield = 0 or quality_grade = 'C';

-- thêm check diện tích > 0
alter table zones
add constraint chk_area check(area_square_meters > 0);

-- set default is_automated = 1
alter table planting_logs
alter is_automated set default 1;

-- thêm cột fertilizer_type
alter table crops
add fertilizer_type varchar(50);



-- cây sinh trưởng <50 ngày
select * from crops
where growth_time_days < 50;

-- khu vực full sun
select zone_name, area_square_meters
from zones
where light_condition='Full Sun';

-- sắp xếp sản lượng giảm dần
select crop_name, expected_yield
from crops
order by expected_yield desc;

-- 3 planting_logs mới nhất
select * from planting_logs
order by planting_date desc
limit 3;

-- phân trang zones
select zone_name,status
from zones
limit 2 offset 1;

-- cập nhật last_watered cho auto
update planting_logs
set last_watered = now()
where is_automated=1;

-- upper crop_name
update crops
set crop_name = upper(crop_name);

-- xóa zone maintenance
set foreign_key_checks=0;
delete from zones where status='maintenance';
set foreign_key_checks=1;



-- log + zone + crop khi zone occupied
select p.log_id, z.zone_name, c.crop_name, p.planting_date
from planting_logs p
join zones z on p.zone_id = z.zone_id
join crops c on p.crop_id = c.crop_id
where z.status = 'Occupied';

-- số lần trồng theo zone
select z.zone_name,count(p.log_id) total_logs
from zones z
left join planting_logs p on z.zone_id = p.zone_id
group by z.zone_name;

-- tổng sản lượng theo crop
select c.crop_name,sum(h.actual_yield) total_yield
from harvests h
join planting_logs p on h.log_id = p.log_id
join crops c on p.crop_id=c.crop_id
group by c.crop_name;

-- zone trồng >= 2 loại cây
select z.zone_name, count(distinct p.crop_id) crop_count
from zones z
join planting_logs p on z.zone_id = p.zone_id
group by z.zone_name
having count(distinct p.crop_id)>=2;

-- cây yield > trung bình
select *
from crops
where expected_yield > (select avg(expected_yield) from crops);

-- zone trồng cà chua cherry
select distinct z.zone_name
from planting_logs p
join zones z on p.zone_id=z.zone_id
join crops c on p.crop_id=c.crop_id
where c.crop_name like '%cherry%';

