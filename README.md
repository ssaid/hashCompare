# HashCompare

HashCompare is a postgresql extension allowing you to compare data from two different postgres objects.
It automatically removes all fields containing 'id' to make sure only the "raw" data is being compared and not the foreign table ids.

## Installation

Simply drag and drop the files `hashcompare--0.0.1.sql` and `hashcompare.control` in your postgres extentions folder (usually `$PGDATA/share/extension/`).
Once files have been copied run the create extension command from any postgresql client.

```sql
CREATE EXTENSION hashcompare;
```
That's it !

## Alternative Installation
Alternatively if make is installed on the postgresql server you can clone the repo and run the make command.
```bash
git clone https://github.com/greggailly/hashCompare.git
make install
````
Once files have been copied run the create extension command from any postgresql client.

```sql
CREATE EXTENSION hashcompare;
```

## SQL

Get the hash for a single object:
Objects are selected depending on the string given to the get_tabledata_hash function. Any 'LIKE' kind of syntax can be used.
```sql
SELECT get_tabledata_hash('public.test_table'); -- get hash for public.test_table table
SELECT get_tabledata_hash('public.*'); -- get hash for full public schema
SELECT get_tabledata_hash('public.test_%'); -- get hash for full all tables in public schema starting with test_
```

Compare two objects:
Same rules apply as for the get_tabledata_hash function.
The compare_by_hash can return TRUE if data is equal, FALSE if not equal and null if either the first or the second object could not be found.
```sql
SELECT compare_by_hash('public.test_table', 'public.test_table_copy'); -- compare hashes for the two tables
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)