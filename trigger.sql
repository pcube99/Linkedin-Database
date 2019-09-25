set search_path to mylinkedin_test;
CREATE or replace FUNCTION emp_check()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $is_valid_emp$

   declare
   use_id integer;
   enddate date;
   startdate date;
   pskill varchar(30);
   uskill varchar(30);
   CURS CURSOR is select skill_name from ((select skill_id from user_skill where user_id=new.user_id) as r1 natural join skill);

   begin
   SELECT NEW.end_date INTO enddate;
   SELECT NEW.user_id INTO use_id;
   SELECT NEW.start_date INTO startdate;
   
   if (TG_OP = 'INSERT') then
   if enddate is null then
   update employment set end_date =startdate where user_id=use_id;
   return new;
   end if;
   OPEN CURS;
   SELECT NEW.primary_skill INTO uskill;
	loop
	FETCH CURS INTO pskill;
	raise notice 't %',pskill;
	EXIT WHEN NOT FOUND;
	IF(uskill = pskill ) THEN
               CLOSE CURS;
               return new;
	end if;
	end loop;
	close CURS;
	return null;

   end if;
   END;

$is_valid_emp$;
	
CREATE TRIGGER is_valid_emp
BEFORE INSERT ON employment
FOR each row EXECUTE PROCEDURE
emp_check();	

CREATE or replace FUNCTION chat_check()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $is_valid_chat$

   declare
   usrid integer;
   frdid integer;
   begin
   SELECT NEW.user_id INTO usrid;
   SELECT NEW.friend_id INTO frdid;
   if (TG_OP = 'INSERT') then
  
   if frdid in (select friend_id from friends where user_id=usrid) then 
   return new;
   else return null;
   end if;
   end if;
   END;

$is_valid_chat$;
	
CREATE TRIGGER is_valid_chat
BEFORE INSERT ON chat
FOR EACH ROW EXECUTE PROCEDURE
chat_check();

CREATE FUNCTION age_check()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $is_valid$

   declare
   currage integer;
   bdate date;
   regdate timestamp;
   begin
   SELECT NEW.birthday INTO bdate;
   SELECT NEW.registration_time INTO regdate;
   if (TG_OP = 'INSERT') then
   currage = to_char(age(regdate,bdate),'YYYY');
   raise notice 'n %', currage;
   if currage >= 18 then 
   return new;
   else return null;
   end if;
   end if;
   END;

$is_valid$;
	
CREATE TRIGGER is_valid
BEFORE INSERT ON myuser
FOR EACH ROW EXECUTE PROCEDURE
age_check();

------------------------------------------------------------------------------
