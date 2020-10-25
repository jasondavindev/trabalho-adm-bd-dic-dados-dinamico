CREATE OR REPLACE
DIRECTORY user_dir AS '/opt/oracle/product/12.2.0.1/dbhome_1';

GRANT READ ON
DIRECTORY user_dir TO PUBLIC;

GRANT WRITE ON
DIRECTORY user_dir TO PUBLIC;

CREATE OR REPLACE
PROCEDURE dup_tables(source_user varchar, target_user varchar) IS 
	F_LOG utl_file.file_type;
	query_str varchar2(500);
	CURSOR tables_cursor IS
		SELECT
			table_name
		FROM
			user_tables
		WHERE
			USER = source_user;
BEGIN
	F_LOG := utl_file.fopen('USER_DIR', 'arq.txt', 'w');

FOR RESULT IN tables_cursor
LOOP
	SELECT
		fn_dynamic_insert(source_user, target_user, result.table_name)
INTO
	query_str
FROM
	dual;

utl_file.put_line(F_LOG, query_str);
dbms_output.put_line(query_str);
END
LOOP;
utl_file.fclose(F_LOG);
END;
/

CREATE OR REPLACE
FUNCTION fn_dynamic_insert(source_user varchar, target_user varchar, source_table varchar) RETURN varchar2 IS columns_str varchar(255);

query_str varchar2(500);
BEGIN
	SELECT
	LISTAGG(column_name, ', ') WITHIN GROUP (
ORDER BY
	column_name)
INTO
	columns_str
FROM
	user_tab_cols
WHERE
	table_name = source_table
GROUP BY
	table_name;

query_str := 'INSERT INTO ' || target_user || '.' || source_table || '(' || columns_str || ')' || ' SELECT ' || columns_str || ' FROM ' || source_user || '.' || source_table || ';';

RETURN(query_str);
END;
/
