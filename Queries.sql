-- Query 1: Show the total “Amount” of “Type = 0” transactions at “ATM Code = 21” of the last 10 minutes. 
-- Repeat as new events keep flowing in (use a sliding window).

SELECT
    SUM (CAST([input].[AMOUNT] AS BIGINT)) as Total,
    System.Timestamp as Time
INTO
    [output]
FROM
    [input]
Where CAST([input].[TYPE] AS BIGINT) = 0 AND CAST([input].[ATMCode] AS BIGINT) = 21
GROUP BY Slidingwindow(minute,10)

-- Query 2: Show the total “Amount” of “Type = 1” transactions at “ATM Code = 21” of the last hour. 
-- Repeat once every hour (use a tumbling window).

SELECT
    SUM (CAST([input].[AMOUNT] AS BIGINT)) as Total,
    System.Timestamp as Time
INTO
    [output]
FROM
    [input]
Where CAST([input].[TYPE] AS BIGINT) = 1 AND CAST([input].[ATMCode] AS BIGINT) = 21
GROUP BY Tumblingwindow(hour,1)

-- Query 3: Show the total “Amount” of “Type = 1” transactions at “ATM Code = 21” of the last hour. 
-- Repeat once every 30 minutes (use a hopping window).

SELECT
    SUM (CAST([input].[AMOUNT] AS BIGINT)) as Total,
    System.Timestamp as Time
INTO
    [output]
FROM
    [input]
Where CAST([input].[TYPE] AS BIGINT) = 1 AND CAST([input].[ATMCode] AS BIGINT) = 21
GROUP BY Hoppingwindow(minute,60,30)

-- Query 4: Show the total “Amount” of “Type = 1” transactions per “ATM Code” of the last one hour (use a sliding window).

SELECT
	CAST([input].[ATMCode] AS BIGINT) as Atm,
    SUM (CAST([input].[AMOUNT] AS BIGINT)) as Total,
    System.Timestamp as Time
INTO
    [output]
FROM
    [input]
Where CAST([input].[TYPE] AS BIGINT) = 1
GROUP BY CAST([input].[ATMCode] AS BIGINT), Slidingwindow(hour,1)

-- Query 5: Show the total “Amount” of “Type = 1” transactions per “Area Code” of the last hour. 
-- Repeat once every hour (use a tumbling window).

SELECT
	CAST([inputatm].[area_code] AS BIGINT) as Area,
    SUM (CAST([input].[AMOUNT] AS BIGINT)) as Total,
    System.Timestamp as Time
INTO
    [output]
FROM
    [input]
INNER JOIN [inputatm] ON CAST([input].[ATMCode] AS BIGINT) = CAST([inputatm].[atm_code] AS BIGINT)
Where CAST([input].[TYPE] AS BIGINT) = 1
GROUP BY CAST([inputatm].[area_code] AS BIGINT), Tumblingwindow(hour,1)

-- Query 6: Show the total “Amount” per ATM’s “City” and Customer’s “Gender” of the last hour. 
-- Repeat once every hour (use a tumbling window).

SELECT
	[inputarea].[area_city] as Area,
	[inputcust].[gender] as Gender,
    SUM (CAST([input].[AMOUNT] AS BIGINT))as Total,
    System.Timestamp as Time
INTO
    [output]
FROM
    [input]
INNER JOIN [inputcust] ON CAST([input].[CardNumber] AS BIGINT) = CAST([inputcust].[card_number] AS BIGINT)
INNER JOIN [inputatm] ON CAST([input].[ATMCode] AS BIGINT) = CAST([inputatm].[atm_code] AS BIGINT)
INNER JOIN [inputarea] ON CAST([inputarea].[area_code] AS BIGINT) = CAST([inputatm].[area_code] AS BIGINT)
Where CAST([input].[TYPE] AS BIGINT) = 1
GROUP BY [inputarea].[area_city] , [inputcust].[gender], Tumblingwindow(hour,1)

-- Query 7: Alert (SELECT “1”) if a Customer has performed two transactions of “Type = 1” in a window of an hour (use a sliding window).

SELECT
	[inputcust].[first_name] as Name,
	[inputcust].[last_name] as Surname,
    CAST([inputcust].[card_number] AS BIGINT) as CardNumber,
	COUNT(*) as Times,
    System.Timestamp as Time
INTO
    [output]
FROM
    [input]
INNER JOIN [inputcust] ON CAST([inputcust].[card_number] AS BIGINT) = CAST([input].[CardNumber] AS BIGINT)
Where CAST([input].[TYPE] AS BIGINT) = 1
GROUP BY  CAST([inputcust].[card_number] AS BIGINT),[inputcust].[first_name],[inputcust].[last_name],Slidingwindow(hour,1)
HAVING Times = 2


-- Query 8: Alert (SELECT “1”) if the “Area Code” of the ATM of the transaction is not the same as the “Area Code” of the “Card Number” (Customer’s Area Code) - (use a sliding window)
 
SELECT
	CAST([inputatm].[area_code] AS BIGINT)as Atm_area_Code,
	CAST([inputcust].[area_code] AS BIGINT) as Customers_area_Code,
	COUNT(*),
    System.Timestamp as Time
INTO
    [output]
FROM
    [input]
INNER JOIN [inputcust] ON CAST([inputcust].[card_number] AS BIGINT) = CAST([input].[CardNumber] AS BIGINT)
INNER JOIN [inputatm] ON CAST([inputatm].[atm_code] AS BIGINT) = CAST([input].[ATMCode] AS BIGINT)
WHERE CAST([inputatm].[area_code] AS BIGINT) != CAST([inputcust].[area_code] AS BIGINT)
GROUP BY  CAST([inputatm].[area_code] AS BIGINT),CAST([inputcust].[area_code] AS BIGINT), Slidingwindow(hour,1)


