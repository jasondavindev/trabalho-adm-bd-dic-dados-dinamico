CREATE OR REPLACE PROCEDURE dynamic_insert(table1 varchar, table2 varchar)
IS
	columns_str varchar(255);
	query_str varchar2(500);
BEGIN
	SELECT
	LISTAGG(column_name, ', ') WITHIN GROUP (
ORDER BY
	column_name) INTO columns_str
FROM
	user_tab_cols
WHERE
	table_name = table1
GROUP BY
	table_name;

query_str := 'INSERT INTO ' || table2 || '(' || columns_str || ')'  || 'SELECT ' || columns_str || ' FROM ' || table1 || ';';
dbms_output.put_line(query_str);
END;
/

exec dynamic_insert('EMPLOYEES', 'FUNCIONARIOS');

