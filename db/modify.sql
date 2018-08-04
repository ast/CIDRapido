-- temp tables
create temp table capitulos_t as select first, last, sort, desc from cid_t where type is "cap";
create temp table grupos_t as select first, last, sort, desc from cid_t where type is "grp";
create temp table categorias_t as select first, sort, desc from cid_t where type is "cat";
create temp table subcategorias_t as select first, sort, desc from cid_t where type is "sub";

create virtual table search_pt_br using fts4(code, desc, tokenize=unicode61);

insert into search_pt_br select first, desc from categorias_t union select first, desc from subcategorias_t;

-- counts
create temp table capc_t as select capitulos_t.rowid as rowid, count() as c from capitulos_t, grupos_t where grupos_t.first between capitulos_t.first and capitulos_t.last group by capitulos_t.first;

create temp table grpc_t as select grupos_t.rowid as rowid, count() as c from grupos_t, categorias_t where categorias_t.first between grupos_t.first and grupos_t.last group by grupos_t.first;

create temp table catc_t as select subcategorias_t.rowid as rowid, count() as c from categorias_t, subcategorias_t where subcategorias_t.first like categorias_t.first||"%" group by subcategorias_t.first;

create table capitulos(first TEXT, last TEXT, c INTEGER DEFAULT 0, sort INTEGER, desc TEXT);
create table grupos(first TEXT, last TEXT, c INTEGER DEFAULT 0, sort INTEGER, desc TEXT);
create table categorias(first TEXT, c INTEGER DEFAULT 0, sort INTEGER, desc TEXT);
create table subcategorias(first TEXT, sort INTEGER, desc TEXT);

insert into capitulos select first, last, c, sort, desc from capitulos_t left join capc_t on capitulos_t.rowid == capc_t.rowid;
insert into grupos select first, last, c, sort, desc from grupos_t left join grpc_t on grupos_t.rowid == grpc_t.rowid;
insert into categorias select first, c, sort, desc from categorias_t left join catc_t on categorias_t.rowid == catc_t.rowid;
insert into subcategorias select first, sort, desc from subcategorias_t;

-- indices
create index grupos_index on grupos(first);
create index categorias_index on categorias(first);
create index subcategorias_index on subcategorias(first);