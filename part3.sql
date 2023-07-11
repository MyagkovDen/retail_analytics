create role administrator with superuser password '123';

create role visitor_grp with nologin;

grant select on all tables in schema public to visitor_grp;

create role visitor_1 with login password '321';

grant visitor_grp to visitor_1;


     