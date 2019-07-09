-- Query 6: Show the total “Amount” per ATM’s “City” and Customer’s “Gender” of the last hour. 
-- Repeat once every hour (use a tumbling window).

SELECT
	[inputarea].[area_city] as Area,
	[inputcust].[gender] as Gender,
    SUM (CAST([input].[AMOUNT] AS BIGINT))as Total,
    System.Timestamp as Time
INTO
    [outputbi]
FROM
    [input]
INNER JOIN [inputcust] ON CAST([input].[CardNumber] AS BIGINT) = CAST([inputcust].[card_number] AS BIGINT)
INNER JOIN [inputatm] ON CAST([input].[ATMCode] AS BIGINT) = CAST([inputatm].[atm_code] AS BIGINT)
INNER JOIN [inputarea] ON CAST([inputarea].[area_code] AS BIGINT) = CAST([inputatm].[area_code] AS BIGINT)
Where CAST([input].[TYPE] AS BIGINT) = 1
GROUP BY [inputarea].[area_city] , [inputcust].[gender], Tumblingwindow(hour,1)
