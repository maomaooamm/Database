drop table myGPA cascade constraints;
create table myGPA(
	gradeEarn number(2,1),
	creditEarn number(1)
);
set serveroutput on

create or replace procedure totalGPA (id in varchar2, average out number) as
cursor c1 is
	select grade, credit from takes, section, course 
	where takes.userid = id and section.courseno = course.courseno and takes.sequid = section.seqid
	order by grade desc;
gradeEarn number(2,1);
creditEarn number(1);
qualitypoint number (3);
totalcredit number (3);
totalgpa number (2,1);
begin
	delete from myGPA;
	commit;
  	qualitypoint := 0;
  	totalcredit := 0;
 	totalgpa := 0;

  	open c1;
  	for i in 1..50 loop
		fetch c1 into gradeEarn, creditEarn;
		exit when c1%notfound; 
		dbms_output.put_line('grade: ' || gradeEarn || '  ' || 'credit: ' || creditEarn);
		insert into myGPA values(gradeEarn, creditEarn);
		commit;

    		if gradeEarn != 0 then
			totalcredit := totalcredit + creditEarn;
			qualitypoint := qualitypoint + (creditEarn * gradeEarn);
		end if;
	end loop;
	totalgpa := qualitypoint / totalcredit;
	dbms_output.put_line('quality points: ' || qualitypoint || ' ' || 'total credit hours: ' || totalcredit || ' ' || 'total GPA: ' || totalgpa);
	close c1;

average := totalgpa;
end;
/
