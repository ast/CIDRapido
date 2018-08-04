create temp table cid_t(type TEXT, first TEXT, last TEXT, sort, INTEGER, desc TEXT);
create virtual table search_en_us using fts4(code, desc, tokenize=unicode61);