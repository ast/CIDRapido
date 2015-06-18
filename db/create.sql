create table cid_temp(type TEXT, first TEXT, last TEXT, sort, INTEGER, desc TEXT);
create virtual table search_pt_br using fts4(code, desc, tokenize=unicode61);
create virtual table search_en_us using fts4(code, desc, tokenize=unicode61);