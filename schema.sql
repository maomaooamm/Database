drop table userflag cascade constraints;
drop table users cascade constraints;
drop table usersession cascade constraints;
drop table section cascade constraints;
drop table course cascade constraints;
drop table prerequisite cascade constraints;
drop table takes cascade constraints;

create table users (
        userid varchar2(8) primary key,
        password varchar2(15),
        type varchar2(15),
        fname varchar2(30) NOT NULL,
        lname varchar2(30) NOT NULL,
        bdate date,
        street varchar2(50),
        city varchar2(30),
        state varchar2(2),
        zip number(5),
        gpa number(2,1) 
);
create table usersession (
	sessionid varchar2(32) primary key,
	userid varchar2(8),
	sessiondate date,
	type varchar2(15),
	foreign key (userid) references users
);
create table course (
        courseno varchar2(15) primary key,
        title varchar2(30),
        credit number(1),
        description varchar2(50)
); 
create table section (
        seqid varchar2(5) primary key,
        courseno varchar2(15),
        semester varchar2(10),
        year number(4),
        starttime varchar2(7),
        endtime varchar2(7),			
        maxseat varchar2(2),
        takenseat varchar2(2),
        deadline date,
        foreign key (courseno) references course (courseno)
);
create table prerequisite (
	courseno varchar2(15),
	prerequisite varchar2(15),
	primary key (courseno, prerequisite),
	foreign key (courseno) references course (courseno), 
	foreign key (prerequisite) references course (courseno)
);
create table takes(
        userid varchar2(8),
        sequid varchar2(5),
        grade number(2,1),
        primary key(userid, sequid),
        foreign key (userid) references users (userid) on delete cascade,
        foreign key (sequid) references section (seqid)
);
create table userflag(
	userid varchar2(8),
	graduation_flag varchar2(1),
	probation_flag varchar2(1),
	foreign key (userid) references users(userid) on delete cascade,
	primary key (userid,probation_flag) 
);

insert into users values('tw000001','student','student','Tom','White','06-Jun-1990','723 well street','Edmon','OK','73034','4');
insert into users values('bg000001','admin','admin','Bill','Gates','01-JAN-1988','938 Good Ave','OKC','OK','73093','2');
insert into users values('nw000001','adminstudent','studentadmin','Nutty','Williams','30-DEC-1992','184 Nice street','Norman','OK','73103','3');

insert into userflag values('tw000001','N','Y');
insert into userflag values('bg000001','Y','Y');
insert into userflag values('nw000001','N','N');

insert into course values('ENGR2033',' Statics','3', 'Statics for engineering major');
insert into course values('HUM2223','General Humanities: Ren-Modern','3','Humanity for modern history');
insert into course values('JAPN1114','Elementary Japanese I','4','Japanese learning for beginners');
insert into course values('MATH1513','College Algebra','3','Basic math skills for college learning');
insert into course values('CMSC2613','Programming II','3','Prerequiste for many high level courses');
insert into course values('MGMT3103',' Principles of Management','3','Basics of management study');
insert into course values('MUS1113','Intro to Basic Music Skills','3','Music learning for interests');
insert into course values('CMSC3103','Object Oriented Programming','3','For application design');

insert into section values('00001','ENGR2033','FALL','2014',  '8:00am','8:50am','30','6','09-AUG-2014');
insert into section values('00002','HUM2223','FALL','2014',  '9:00am','9:50am','30','12','09-AUG-2014');
insert into section values('00003','JAPN1114','FALL','2014',  '10:00am','10:50am','40','26','09-AUG-2014');
insert into section values('00004','MATH1513','FALL','2014',  '11:00am','11:50am','30','2','09-AUG-2014');
insert into section values('00005','CMSC2613','SPRING','2014',  '8:30am','9:45am' ,'30','1','01-JAN-2014');
insert into section values('00006','MGMT3103','SPRING','2014',  '12:00pm','12:50pm' ,'30','7','01-JAN-2014');
insert into section values('00007','MUS1113', 'SPRING','2014',  '4:30pm','5:45pm' ,'30','8','01-JAN-2014');
insert into section values('00008','CMSC3103', 'SPRING','2014',  '7:30am','8:45am' ,'30','29','01-JAN-2014');

insert into prerequisite values('CMSC2613','MATH1513');
insert into prerequisite values('CMSC3103','CMSC2613');
insert into prerequisite values('MGMT3103','MATH1513');

insert into takes values('tw000001','00006','2');
insert into takes values('tw000001','00001','2');
insert into takes values('tw000001','00002','3');
insert into takes values('nw000001','00003','3');
insert into takes values('nw000001','00004','1');

commit;



/*trigger*/
create or replace trigger probation_add
AFTER update of GPA on USERS
FOR EACH ROW
when(new.gpa < 2)
begin
  update userflag
  set probation_flag = 'Y'
  where userid = :new.userid;
end;
/

/*trigger*/
create or replace trigger probation_remove
AFTER update of GPA on USERS
FOR EACH ROW
when(new.gpa >= 2)
begin
  update userflag
  set probation_flag = 'N'
  where userid = :new.userid;
end;
/

set serveroutput on
create or replace procedure seatleft (sequid in varchar2, userid in varchar2, success out varchar2) as
cursor c1 is 
	select maxseat, takenseat from section 
	where seqid=sequid for update;
maxseat number(10);
takenseat number(10);
leftseat number(10);
begin
	leftseat:= 0;
	open c1;
	fetch c1 into maxseat, takenseat;
	leftseat := maxseat-takenseat;
	if leftseat > 0 then
		update section 
		set takenseat=takenseat+1 where seqid=sequid;
		insert into takes values(userid,sequid,0);
		success:='T';
		commit;
		dbms_output.put_line(success);
		dbms_output.put_line('Committed');
	else
		success:='F';
		rollback;
		dbms_output.put_line(success);
		dbms_output.put_line('No seats, rollback');
	end if;
  close c1;
end;
/
