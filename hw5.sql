-- 1. Напишіть SQL запит, який буде відображати таблицю order_details 
-- та поле customer_id з таблиці orders відповідно для кожного поля запису з таблиці order_details.

SELECT
	od.*,
	(SELECT customer_id FROM orders o WHERE o.id = od.order_id) AS customer_id
FROM	order_details od;
    
-- 2. Напишіть SQL запит, який буде відображати таблицю order_details. 
-- Відфільтруйте результати так, щоб відповідний запис із таблиці orders виконував умову shipper_id=3.

SELECT 
	od.id, 
	od.order_id, 
	od.product_id, 
	od.quantity,
	o.shipper_id
FROM 	order_details od
JOIN 	orders o ON od.order_id = o.id
WHERE 	o.shipper_id IN (SELECT shipper_id FROM orders WHERE shipper_id = 3)
;

-- 3. Напишіть SQL запит, вкладений в операторі FROM, який буде обирати рядки з умовою quantity>10 з таблиці order_details. 
-- Для отриманих даних знайдіть середнє значення поля quantity — групувати слід за order_id.

SELECT
	od.order_id,
	AVG(od.quantity) AS average_quantity
FROM 	(SELECT * FROM order_details WHERE quantity>10) od
GROUP BY 1;

-- 4. Розв’яжіть завдання 3, використовуючи оператор WITH для створення тимчасової таблиці temp. 

WITH temp as (
	SELECT 	id, 
		order_id, 
            	product_id, 
            	quantity 
	FROM 	order_details 
    	WHERE 	quantity>10
)
SELECT
	order_id,
        AVG(quantity) as avg_quantity
FROM 	temp
GROUP BY 1
;

-- 5. Створіть функцію з двома параметрами, яка буде ділити перший параметр на другий. 
-- Обидва параметри та значення, що повертається, повинні мати тип FLOAT. Використайте конструкцію DROP FUNCTION IF EXISTS. 

DROP FUNCTION IF EXISTS DivisionOperation;

DELIMITER //

CREATE FUNCTION DivisionOperation(dividend FLOAT, divisor FLOAT)
RETURNS FLOAT
DETERMINISTIC 
READS SQL DATA
BEGIN
	DECLARE result FLOAT;
    	SET result = dividend / NULLIF(divisor, 0); -- UPD: added NULLIF() to override ZeroDivision Error
    	RETURN result;
END //

DELIMITER ;

SELECT DivisionOperation(10, 2) -- simple example for testing -> 5
;

-- Застосуйте функцію до атрибута quantity таблиці order_details. Другим параметром може бути довільне число на ваш розсуд.
-- У якості числа для другого параметру використала загальну кількість певного товару у всіх замовленнях.
-- Таким чином, отримуємо співвідношення (пропорцію) кількості товару у певному замовленні до загальної кількості цього замовленого товару.

WITH product_total_quantity AS (
	SELECT 	product_id,
		SUM(quantity) as total_quantity
	FROM 	order_details
    	GROUP BY 1
)

SELECT
	od.order_id,
	od.product_id,
	od.quantity,
	p.total_quantity,
	DivisionOperation(od.quantity, p.total_quantity) AS quantity_ratio_by_order
FROM 	order_details od 
JOIN 	product_total_quantity p ON od.product_id = p.product_id
