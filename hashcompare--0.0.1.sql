\echo Use "CREATE EXTENSION hashcompare" to load this file. \quit
CREATE FUNCTION md5_agg_sfunc(text, anyelement) 
RETURNS text
LANGUAGE plpgsql
AS
$$
  declare
	is_equal text;
  begin
  SELECT md5($1 || $2::text) into is_equal;
  return is_equal;
  
  end;
$$
;
 
CREATE  AGGREGATE md5_agg (ORDER BY anyelement)
(
  STYPE = text,
  SFUNC = md5_agg_sfunc,
  INITCOND = ''
)
;


drop function if exists get_tabledata_hash
;
CREATE OR REPLACE FUNCTION get_tabledata_hash(_table text)
  RETURNS TABLE (tbl_name text, hash text) 
language plpgsql
as $$
declare
	table_r record;
begin
	FOR table_r IN (
		with tables_to_hash as (
			select table_name as tbl_to_hash, table_schema as schema_to_hash
			from information_schema.tables 
			where 1=1
				and table_schema || '.' || table_name like _table
				and table_type = 'BASE TABLE'
		)
		select
			table_schema || '.' || table_name as tbl,
			array_to_string(array_agg(column_name order by column_name), ',') as cols
		from information_schema.columns
			join tables_to_hash on tables_to_hash.tbl_to_hash = columns.table_name and tables_to_hash.schema_to_hash = columns.table_schema
		where 1=1
			and column_name !~ '(id|section_)'
		group by 1
		order by 1
		) LOOP
		raise notice 'Calcul du hash pour la table : %', table_r.tbl;
    	tbl_name := table_r.tbl;
		EXECUTE '
			WITH ordered_table AS (
				SELECT ('||table_r.cols||') as row
				FROM '||table_r.tbl||'
				ORDER BY 1
			)
			SELECT md5_agg() WITHIN GROUP (ORDER BY (row))
			FROM ordered_table' INTO hash;
		return next;
	END LOOP;
end;$$
;

drop function if exists compare_by_hash
;
CREATE OR REPLACE FUNCTION compare_by_hash(_table1 text, _table2 text)
  RETURNS boolean 
language plpgsql
as $$
declare
	is_equal boolean;
begin
	select (select hash from get_tabledata_hash(_table1)) = (select hash from get_tabledata_hash(_table2)) into is_equal;
	return is_equal;
end;$$
;