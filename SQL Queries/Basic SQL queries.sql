SELECT *  
FROM `marks`  
WHERE studentid = 'V002';

SELECT a.studentid, a.name, b.total_marks
FROM student a, marks b
WHERE a.studentid = b.studentid
AND b.total_marks >
(SELECT total_marks 
FROM marks 
WHERE studentid = 'V002') t1;

-- Subquery syntax
(SELECT [DISTINCT] subquery_select_argument
FROM {table_name | view_name}
{table_name | view_name} ...
[WHERE search_conditions]
[GROUP BY aggregate_expression [, aggregate_expression] ...]
[HAVING search_conditions])

SELECT column_name [, column_name ]
FROM   table1 [, table2 ]
WHERE  column_name OPERATOR
   (SELECT column_name [, column_name ]
   FROM table1 [, table2 ]
   [WHERE])

-- Write a query to display all the orders from the orders table issued by the salesman 'Paul Adam'. 

SELECT S.name, O.ord_no
FROM Salesman S, Orders O 
WHERE S.salesman_id = O.salesman_id AND S.name = "Paul Adam"
GROUP BY 1;

-- QUERIES
-- City data:
    SELECT *
    FROM city_data
    WHERE city = 'Berlin';

-- Global data:
    SELECT *
    FROM global_data ;