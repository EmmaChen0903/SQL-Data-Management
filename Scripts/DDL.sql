# 0. Create database
create database if not exists G1T1; 
use G1T1;

# 1. Create tables 
create table if not exists vo
(
VOID int not null, 
Name varchar(40) not null,
constraint vo_pk primary key(VOID)
);

create table if not exists activity
(
Name varchar(100) not null,
Date date not null,
MinReqEd varchar(20),
constraint activity_pk primary key (Name, Date)
);

create table if not exists vo_parent
(
Parent int not null,
Child int not null,
constraint vo_parent_pk primary key(Parent, Child),
constraint vo_parent_fk1 foreign key(Parent)
	references vo(VOID), 
constraint vo_parent_fk2 foreign key(Child)
	references vo(VOID)
);

create table if not exists award
(
VOID int not null,
Name varchar(30) not null,
Date date not null,
Type varchar(15) not null,
constraint award_pk primary key(VOID, Name, Date),
constraint award_fk1 foreign key(VOID)
	references vo(VOID)
);

create table if not exists post
(
VOID int not null,
CreateDateTime datetime not null,
StartDate date not null,
Enddate date not null,
Message varchar(100) not null,
IsPublic tinyint not null,
Name varchar(100),
Date date DEFAULT NULL,
constraint post_pk primary key(VOID, CreateDateTime),
constraint post_fk1 foreign key(VOID)
	references vo(VOID),
constraint post_fk2 foreign key (Name, Date)
	references activity(Name, Date)
);


create table if not exists visible
(
VOID int not null,
PostVOID int not null,
CreateDateTime datetime not null,
constraint visible_pk primary key(VOID, PostVOID, CreateDateTime),
constraint visible_fk1 foreign key(VOID)
	references vo(VOID),
constraint visible_fk2 foreign key(PostVOID, CreateDateTime)
	references post(VOID, CreateDateTime)
);

create table if not exists a_organize
(
VOID int not null,
Name varchar(100) not null,
Date date not null,
constraint a_organize_pk primary key (VOID, Name, Date),
constraint a_organize_fk1 foreign key (VOID)
	references vo(VOID),
constraint a_organize_fk2 foreign key (Name, Date)
	references activity(Name, Date)
);

create table if not exists act_category
(
Name varchar(100) not null,
Date date not null,
Category varchar(30) not null,
constraint act_category_pk primary key (Name, Date, Category),
constraint act_categoty_fk1 foreign key (Name, Date)
	references activity(Name, Date)
);

create table if not exists course
(
ID varchar(10) not null,
Name varchar(50) not null,
Description varchar(150) not null,
constraint course_pk primary key (ID)
);

create table if not exists run
(
ID varchar(10) not null,
RunID varchar(10) not null,
StartDate date not null,
EndDate date not null,
NoOfHours int not null,
constraint run_pk primary key(ID, RunID),
constraint run_fk1 foreign key(ID)
	references course(ID)
);

create table if not exists c_organize
(
ID varchar(10) not null,
VOID int not null,
constraint c_organize_pk primary key (ID, VOID),
constraint c_organize_fk1 foreign key(ID)
	references course(ID),
constraint c_organize_fk2 foreign key (VOID)
	references vo(VOID)
);

create table if not exists user 
(
AcctName varchar(30) not null,
Name varchar(30) not null,
Password varchar(15) not null,
PrimaryTel int not null,
PrimaryTelType varchar(15) not null,
UserType char(5) not null,
constraint user_pk primary key (AcctName)
);

create table if not exists extra_contact
(
AcctName varchar(30) not null,
Tel int not null,
TelType varchar(15) not null,
constraint extra_contact_pk primary key (AcctName, Tel),
constraint extra_contact_fk1 foreign key (AcctName)
	references user(AcctName)
);

create table if not exists sa
(
AcctName varchar(30) not null,
JobGrade varchar(5) not null,
ExtraPwd varchar(15) not null,
constraint sa_pk primary key (AcctName),
constraint sa_fk1 foreign key (AcctName)
	references user(AcctName)
);

create table if not exists voa
(
AcctName varchar(30),
ApptTitle varchar(30) not null,
TokenSNo bigint not null,
VOID int not null,
constraint voa_pk primary key (AcctName),
constraint voa_fk1 foreign key (VOID)
	references vo(VOID),
constraint voa_fk2 foreign key (AcctName)
	references user (AcctName)
);

create table if not exists endorsement
(
Endorser varchar(30) not null,
ID varchar(10) not null,
Date date not null,
UnEndorseDate date,
UnEndorser varchar(30),
constraint endorsement_pk primary key (Endorser, ID),
constraint endorsement_fk1 foreign key (Endorser)
	references voa(AcctName),
constraint endorsement_fk2 foreign key (ID)
	references course(ID),
constraint endorsement_fk3 foreign key (UnEndorser)
	references voa(AcctName)
);

create table if not exists ru
(
AcctName varchar(30) not null primary key,
HighestEdQual varchar(20) not null,
constraint ru_fk1 foreign key (AcctName) 
	references user(AcctName)
);

create table if not exists interest
(
AcctName varchar(30) not null,
Category varchar(20) not null,
constraint interest_pk primary key (AcctName, Category),
constraint interest_fk1 foreign key (AcctName)
	references ru(AcctName)
);

create table if not exists given
(
AcctName varchar(30) not null,
VOID int not null,
Name varchar(30) not null,
Date date not null,
constraint given_pk primary key (AcctName, VOID, Name, Date),
constraint given_fk1 foreign key (AcctName)
	references ru(AcctName),
constraint given_fk2 foreign key (VOID, Name, Date)
	references award(VOID, Name, Date)
);

create table if not exists affiliation
(
VOID int not null,
AcctName varchar(30) not null,
DateOfAffiliation date not null,
constraint aff_pk primary key (VOID, AcctName),
constraint aff_fk1 foreign key (VOID)
	references vo(VOID),
constraint aff_fk2 foreign key (AcctName)
	references ru(AcctName)
);

create table if not exists register
(
VOID int not null,
AcctName varchar(30) not null,
Name varchar(100) not null,
Date date not null,
Accepted tinyint,
Completed tinyint,
NumHrs int,
constraint register_pk primary key (VOID, AcctName, Name, Date),
constraint register_fk1 foreign key (Name, Date)
	references activity(Name, Date),
constraint register_fk2 foreign key (VOID, AcctName)
	references affiliation (VOID, AcctName)
);

# 2. Injest Data

SET GLOBAL local_infile=1;
SET FOREIGN_KEY_CHECKS=1;

# path: /Users/minghaooo/Documents/Term 4/Data Management/project/G1-T1/Data/filaname
# replace with your own path
LOAD DATA LOCAL INFILE '/Users/minghaooo/Documents/Term 4/Data Management/project/G1-T1/Data/vo.txt' INTO TABLE vo LINES TERMINATED BY '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/minghaooo/Documents/Term 4/Data Management/project/G1-T1/Data/activity.txt' INTO TABLE activity LINES TERMINATED BY '\r\n' IGNORE 1 LINES;
# AMEND THE WRONG 'NULL' STRING IN MinReqEd
UPDATE ACTIVITY SET MINREQED = NULL WHERE MINREQED = 'NULL';

LOAD DATA LOCAL INFILE '/Users/minghaooo/Documents/Term 4/Data Management/project/G1-T1/Data/vo_parent.txt' INTO TABLE vo_parent LINES TERMINATED BY '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/minghaooo/Documents/Term 4/Data Management/project/G1-T1/Data/award.txt' INTO TABLE award LINES TERMINATED BY '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/minghaooo/Documents/Term 4/Data Management/project/G1-T1/Data/post.txt' INTO TABLE post LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE '/Users/minghaooo/Documents/Term 4/Data Management/project/G1-T1/Data/visible.txt' INTO TABLE visible LINES TERMINATED BY '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/minghaooo/Documents/Term 4/Data Management/project/G1-T1/Data/a_organize.txt' INTO TABLE a_organize LINES TERMINATED BY '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/minghaooo/Documents/Term 4/Data Management/project/G1-T1/Data/act_category.txt' INTO TABLE act_category LINES TERMINATED BY '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/minghaooo/Documents/Term 4/Data Management/project/G1-T1/Data/course.txt' INTO TABLE course LINES TERMINATED BY '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/minghaooo/Documents/Term 4/Data Management/project/G1-T1/Data/run.txt' INTO TABLE run LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE '/Users/minghaooo/Documents/Term 4/Data Management/project/G1-T1/Data/c_organize.txt' INTO TABLE c_organize LINES TERMINATED BY '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/minghaooo/Documents/Term 4/Data Management/project/G1-T1/Data/user.txt' INTO TABLE user LINES TERMINATED BY '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/minghaooo/Documents/Term 4/Data Management/project/G1-T1/Data/extra_contact.txt' INTO TABLE extra_contact LINES TERMINATED BY '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/minghaooo/Documents/Term 4/Data Management/project/G1-T1/Data/sa.txt' INTO TABLE sa LINES TERMINATED BY '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/minghaooo/Documents/Term 4/Data Management/project/G1-T1/Data/voa.txt' INTO TABLE voa LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE '/Users/minghaooo/Documents/Term 4/Data Management/project/G1-T1/Data/endorsement.txt' INTO TABLE endorsement LINES TERMINATED BY '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/minghaooo/Documents/Term 4/Data Management/project/G1-T1/Data/ru.txt' INTO TABLE ru LINES TERMINATED BY '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/minghaooo/Documents/Term 4/Data Management/project/G1-T1/Data/interest.txt' INTO TABLE interest LINES TERMINATED BY '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/minghaooo/Documents/Term 4/Data Management/project/G1-T1/Data/given.txt' INTO TABLE given LINES TERMINATED BY '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/minghaooo/Documents/Term 4/Data Management/project/G1-T1/Data/affiliation.txt' INTO TABLE affiliation LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE '/Users/minghaooo/Documents/Term 4/Data Management/project/G1-T1/Data/register.txt' INTO TABLE register LINES TERMINATED BY '\r\n' IGNORE 1 LINES;



# for deleting data
/*
DELETE FROM REGISTER;
DELETE FROM AFFILIATION;
DELETE FROM GIVEN;
DELETE FROM INTEREST;
DELETE FROM RU;
DELETE FROM award;
DELETE FROM endorsement;
DELETE FROM voa;
DELETE FROM extra_contact;
DELETE FROM sa;
DELETE FROM user;
DELETE FROM run;
DELETE FROM c_organize;
DELETE FROM course;
DELETE FROM a_organize;
DELETE FROM vo_parent;
DELETE FROM visible;
DELETE FROM post;
DELETE FROM act_category;
DELETE FROM activity;
DELETE FROM vo;
*/