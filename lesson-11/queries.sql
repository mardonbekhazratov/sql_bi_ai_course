select @@servername;

select @@IDENTITY;

select @@rowcount;

select @@error;

select @@version;

select @@TRANCOUNT;

begin tran t1
insert into employee
values (1,1,1,1,1,1)

commit tran t1;
rollback tran t1;


