
{-
Here are some tests taken from the SQL in the postgres manual. Almost
all of the postgres specific syntax has been skipped, this can be
revisited when the dialect support is added.
-}

{-# LANGUAGE OverloadedStrings #-}
module Language.SQL.SimpleSQL.Postgres (postgresTests) where

import Language.SQL.SimpleSQL.TestTypes
import Language.SQL.SimpleSQL.TestRunners
import Data.Text (Text)

postgresTests :: TestItem
postgresTests = Group "postgresTests"

{-
lexical syntax section

TODO: get all the commented out tests working
-}

    [-- "SELECT 'foo'\n\
    -- \'bar';" -- this should parse as select 'foobar'
    -- ,
     t "SELECT name, (SELECT max(pop) FROM cities\n\
     \ WHERE cities.state = states.name)\n\
     \    FROM states;"
    ,t "SELECT ROW(1,2.5,'this is a test');"

    ,t "SELECT ROW(t.*, 42) FROM t;"
    ,t "SELECT ROW(t.f1, t.f2, 42) FROM t;"
    ,t "SELECT getf1(CAST(ROW(11,'this is a test',2.5) AS myrowtype));"

    ,t "SELECT ROW(1,2.5,'this is a test') = ROW(1, 3, 'not the same');"

    -- table is a reservered keyword?
    --,t "SELECT ROW(table.*) IS NULL FROM table;"
    ,t "SELECT ROW(tablex.*) IS NULL FROM tablex;"

    ,t "SELECT true OR somefunc();"

    ,t "SELECT somefunc() OR true;"

-- queries section

    ,t "SELECT * FROM t1 CROSS JOIN t2;"
    ,t "SELECT * FROM t1 INNER JOIN t2 ON t1.num = t2.num;"
    ,t "SELECT * FROM t1 INNER JOIN t2 USING (num);"
    ,t "SELECT * FROM t1 NATURAL INNER JOIN t2;"
    ,t "SELECT * FROM t1 LEFT JOIN t2 ON t1.num = t2.num;"
    ,t "SELECT * FROM t1 LEFT JOIN t2 USING (num);"
    ,t "SELECT * FROM t1 RIGHT JOIN t2 ON t1.num = t2.num;"
    ,t "SELECT * FROM t1 FULL JOIN t2 ON t1.num = t2.num;"
    ,t "SELECT * FROM t1 LEFT JOIN t2 ON t1.num = t2.num AND t2.value = 'xxx';"
    ,t "SELECT * FROM t1 LEFT JOIN t2 ON t1.num = t2.num WHERE t2.value = 'xxx';"

    ,t "SELECT * FROM some_very_long_table_name s\n\
     \JOIN another_fairly_long_name a ON s.id = a.num;"
    ,t "SELECT * FROM people AS mother JOIN people AS child\n\
     \ ON mother.id = child.mother_id;"
    ,t "SELECT * FROM my_table AS a CROSS JOIN my_table AS b;"
    ,t "SELECT * FROM (my_table AS a CROSS JOIN my_table) AS b;"
    ,t "SELECT * FROM getfoo(1) AS t1;"
    ,t "SELECT * FROM foo\n\
     \    WHERE foosubid IN (\n\
     \                        SELECT foosubid\n\
     \                        FROM getfoo(foo.fooid) z\n\
     \                        WHERE z.fooid = foo.fooid\n\
     \                      );"
    {-,t "SELECT *\n\
     \    FROM dblink('dbname=mydb', 'SELECT proname, prosrc FROM pg_proc')\n\
     \      AS t1(proname name, prosrc text)\n\
     \    WHERE proname LIKE 'bytea%';"-} -- types in the alias??

    ,t "SELECT * FROM foo, LATERAL (SELECT * FROM bar WHERE bar.id = foo.bar_id) ss;"
    ,t "SELECT * FROM foo, bar WHERE bar.id = foo.bar_id;"

    {-,t "SELECT p1.id, p2.id, v1, v2\n\
     \FROM polygons p1, polygons p2,\n\
     \     LATERAL vertices(p1.poly) v1,\n\
     \     LATERAL vertices(p2.poly) v2\n\
     \WHERE (v1 <-> v2) < 10 AND p1.id != p2.id;"-} -- <-> operator?

    {-,t "SELECT p1.id, p2.id, v1, v2\n\
     \FROM polygons p1 CROSS JOIN LATERAL vertices(p1.poly) v1,\n\
     \     polygons p2 CROSS JOIN LATERAL vertices(p2.poly) v2\n\
     \WHERE (v1 <-> v2) < 10 AND p1.id != p2.id;"-}

    ,t "SELECT m.name\n\
     \FROM manufacturers m LEFT JOIN LATERAL get_product_names(m.id) pname ON true\n\
     \WHERE pname IS NULL;"


    ,t "SELECT * FROM fdt WHERE c1 > 5"

    ,t "SELECT * FROM fdt WHERE c1 IN (1, 2, 3)"

    ,t "SELECT * FROM fdt WHERE c1 IN (SELECT c1 FROM t2)"

    ,t "SELECT * FROM fdt WHERE c1 IN (SELECT c3 FROM t2 WHERE c2 = fdt.c1 + 10)"

    ,t "SELECT * FROM fdt WHERE c1 BETWEEN \n\
     \    (SELECT c3 FROM t2 WHERE c2 = fdt.c1 + 10) AND 100"

    ,t "SELECT * FROM fdt WHERE EXISTS (SELECT c1 FROM t2 WHERE c2 > fdt.c1)"

    ,t "SELECT * FROM test1;"

    ,t "SELECT x FROM test1 GROUP BY x;"
    ,t "SELECT x, sum(y) FROM test1 GROUP BY x;"
    -- s.date changed to s.datex because of reserved keyword
    -- handling, not sure if this is correct or not for ansi sql
    ,t "SELECT product_id, p.name, (sum(s.units) * p.price) AS sales\n\
     \    FROM products p LEFT JOIN sales s USING (product_id)\n\
     \    GROUP BY product_id, p.name, p.price;"

    ,t "SELECT x, sum(y) FROM test1 GROUP BY x HAVING sum(y) > 3;"
    ,t "SELECT x, sum(y) FROM test1 GROUP BY x HAVING x < 'c';"
    ,t "SELECT product_id, p.name, (sum(s.units) * (p.price - p.cost)) AS profit\n\
     \    FROM products p LEFT JOIN sales s USING (product_id)\n\
     \    WHERE s.datex > CURRENT_DATE - INTERVAL '4 weeks'\n\
     \    GROUP BY product_id, p.name, p.price, p.cost\n\
     \    HAVING sum(p.price * s.units) > 5000;"

    ,t "SELECT a, b, c FROM t"

    ,t "SELECT tbl1.a, tbl2.a, tbl1.b FROM t"

    ,t "SELECT tbl1.*, tbl2.a FROM t"

    ,t "SELECT a AS value, b + c AS sum FROM t"

    ,t "SELECT a \"value\", b + c AS sum FROM t"

    ,t "SELECT DISTINCT select_list t"

    ,t "VALUES (1, 'one'), (2, 'two'), (3, 'three');"

    ,t "SELECT 1 AS column1, 'one' AS column2\n\
     \UNION ALL\n\
     \SELECT 2, 'two'\n\
     \UNION ALL\n\
     \SELECT 3, 'three';"

    ,t "SELECT * FROM (VALUES (1, 'one'), (2, 'two'), (3, 'three')) AS t (num,letter);"

    ,t "WITH regional_sales AS (\n\
     \        SELECT region, SUM(amount) AS total_sales\n\
     \        FROM orders\n\
     \        GROUP BY region\n\
     \     ), top_regions AS (\n\
     \        SELECT region\n\
     \        FROM regional_sales\n\
     \        WHERE total_sales > (SELECT SUM(total_sales)/10 FROM regional_sales)\n\
     \     )\n\
     \SELECT region,\n\
     \       product,\n\
     \       SUM(quantity) AS product_units,\n\
     \       SUM(amount) AS product_sales\n\
     \FROM orders\n\
     \WHERE region IN (SELECT region FROM top_regions)\n\
     \GROUP BY region, product;"

    ,t "WITH RECURSIVE t(n) AS (\n\
     \    VALUES (1)\n\
     \  UNION ALL\n\
     \    SELECT n+1 FROM t WHERE n < 100\n\
     \)\n\
     \SELECT sum(n) FROM t"

    ,t "WITH RECURSIVE included_parts(sub_part, part, quantity) AS (\n\
     \    SELECT sub_part, part, quantity FROM parts WHERE part = 'our_product'\n\
     \  UNION ALL\n\
     \    SELECT p.sub_part, p.part, p.quantity\n\
     \    FROM included_parts pr, parts p\n\
     \    WHERE p.part = pr.sub_part\n\
     \  )\n\
     \SELECT sub_part, SUM(quantity) as total_quantity\n\
     \FROM included_parts\n\
     \GROUP BY sub_part"

    ,t "WITH RECURSIVE search_graph(id, link, data, depth) AS (\n\
     \        SELECT g.id, g.link, g.data, 1\n\
     \        FROM graph g\n\
     \      UNION ALL\n\
     \        SELECT g.id, g.link, g.data, sg.depth + 1\n\
     \        FROM graph g, search_graph sg\n\
     \        WHERE g.id = sg.link\n\
     \)\n\
     \SELECT * FROM search_graph;"

    {-,t "WITH RECURSIVE search_graph(id, link, data, depth, path, cycle) AS (\n\
     \        SELECT g.id, g.link, g.data, 1,\n\
     \          ARRAY[g.id],\n\
     \          false\n\
     \        FROM graph g\n\
     \      UNION ALL\n\
     \        SELECT g.id, g.link, g.data, sg.depth + 1,\n\
     \          path || g.id,\n\
     \          g.id = ANY(path)\n\
     \        FROM graph g, search_graph sg\n\
     \        WHERE g.id = sg.link AND NOT cycle\n\
     \)\n\
     \SELECT * FROM search_graph;"-} -- ARRAY

    {-,t "WITH RECURSIVE search_graph(id, link, data, depth, path, cycle) AS (\n\
     \        SELECT g.id, g.link, g.data, 1,\n\
     \          ARRAY[ROW(g.f1, g.f2)],\n\
     \          false\n\
     \        FROM graph g\n\
     \      UNION ALL\n\
     \        SELECT g.id, g.link, g.data, sg.depth + 1,\n\
     \          path || ROW(g.f1, g.f2),\n\
     \          ROW(g.f1, g.f2) = ANY(path)\n\
     \        FROM graph g, search_graph sg\n\
     \        WHERE g.id = sg.link AND NOT cycle\n\
     \)\n\
     \SELECT * FROM search_graph;"-} -- ARRAY

    ,t "WITH RECURSIVE t(n) AS (\n\
     \    SELECT 1\n\
     \  UNION ALL\n\
     \    SELECT n+1 FROM t\n\
     \)\n\
     \SELECT n FROM t --LIMIT 100;" -- limit is not standard

-- select page reference

    ,t "SELECT f.title, f.did, d.name, f.date_prod, f.kind\n\
     \    FROM distributors d, films f\n\
     \    WHERE f.did = d.did"

    ,t "SELECT kind, sum(len) AS total\n\
     \    FROM films\n\
     \    GROUP BY kind\n\
     \    HAVING sum(len) < interval '5 hours';"

    ,t "SELECT * FROM distributors ORDER BY name;"
    ,t "SELECT * FROM distributors ORDER BY 2;"

    ,t "SELECT distributors.name\n\
     \    FROM distributors\n\
     \    WHERE distributors.name LIKE 'W%'\n\
     \UNION\n\
     \SELECT actors.name\n\
     \    FROM actors\n\
     \    WHERE actors.name LIKE 'W%';"

    ,t "WITH t AS (\n\
     \    SELECT random() as x FROM generate_series(1, 3)\n\
     \  )\n\
     \SELECT * FROM t\n\
     \UNION ALL\n\
     \SELECT * FROM t"

    ,t "WITH RECURSIVE employee_recursive(distance, employee_name, manager_name) AS (\n\
     \    SELECT 1, employee_name, manager_name\n\
     \    FROM employee\n\
     \    WHERE manager_name = 'Mary'\n\
     \  UNION ALL\n\
     \    SELECT er.distance + 1, e.employee_name, e.manager_name\n\
     \    FROM employee_recursive er, employee e\n\
     \    WHERE er.employee_name = e.manager_name\n\
     \  )\n\
     \SELECT distance, employee_name FROM employee_recursive;"

    ,t "SELECT m.name AS mname, pname\n\
     \FROM manufacturers m, LATERAL get_product_names(m.id) pname;"

    ,t "SELECT m.name AS mname, pname\n\
     \FROM manufacturers m LEFT JOIN LATERAL get_product_names(m.id) pname ON true;"

    ,t "SELECT 2+2;"

    -- simple-sql-parser doesn't support where without from
    -- this can be added for the postgres dialect when it is written
    --,t "SELECT distributors.* WHERE distributors.name = 'Westward';"

    ,t "SELECT ''::text;"

    ]
  where
    t :: HasCallStack => Text -> TestItem
    t src = testParseQueryExpr postgres src
