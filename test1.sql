create database test1;
use test1;

create table Zones (
	zone_id varchar(5) primary key not null,
    zone_name varchar(100) not null,
    area_square_meters decimal(10, 2) not null,
    light_condition varchar(50) not null,
    status varchar(20) not null check(status in('Available', 'Occupied', 'Maintenance'))
);

create table Crops (
	crop_id varchar(5) primary key not null,
    crop_name varchar(100) not null unique,
	growth_time_days int not null,
    water_requirement 
    expected_yield
); 