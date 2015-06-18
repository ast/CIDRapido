-- this can be cleaned up quite a bit

create table capitulos as select first, last, desc from cid where type is "cap";
create table grupos as select first, last, desc from cid where type is "grp";
create table categorias as select first, desc from cid where type is "cat";
create table subcategorias as select first, desc from cid where type is "sub";

create virtual table search using fts4(code, desc, tokenize=unicode61);
insert into search select * from categorias union select * from subcategorias;

-- counts
create temp table capc as select capitulos.rowid as rowid, count() as c from capitulos, grupos where grupos.first between capitulos.first and capitulos.last group by capitulos.first;
create temp table grpc as select grupos.rowid as rowid, count() as c from grupos, categorias where categorias.first between grupos.first and grupos.last group by grupos.first;
--create temp table catc as select subcategorias.rowid as rowid, count() as c from categorias, subcategorias where substr(subcategorias.first,1,3) == categorias.first group by categorias.first;
create temp table catc as select subcategorias.rowid as rowid, count() as c from categorias, subcategorias where subcategorias.first like categorias.first||"%" group by subcategorias.first;

create table capitulos2(first TEXT, last TEXT, c INTEGER DEFAULT 0, desc TEXT);
create table grupos2(first TEXT, last TEXT, c INTEGER DEFAULT 0, desc TEXT);
create table categorias2(first TEXT, c INTEGER DEFAULT 0, desc TEXT);
create table subcategorias2(first TEXT, desc TEXT);

insert into capitulos2 select first, last, c, desc from capitulos left join capc on capitulos.rowid == capc.rowid;
insert into grupos2 select first, last, c, desc from grupos left join grpc on grupos.rowid == grpc.rowid;
insert into categorias2 select first, c, desc from categorias left join catc on categorias.rowid == catc.rowid;
insert into subcategorias2 select first, desc from subcategorias;

drop table cid;
drop table capitulos;
drop table grupos;
drop table categorias;
drop table subcategorias;

alter table capitulos2 rename to capitulos;
alter table grupos2 rename to grupos;
alter table categorias2 rename to categorias;
alter table subcategorias2 rename to subcategorias;

-- indices
create index grupos_index on grupos(first);
create index categorias_index on categorias(first);
create index subcategorias_index on subcategorias(first);

vacuum;
