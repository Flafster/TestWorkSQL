/*
Для выполнения данной задачи был использован динамический запрос. 
Поскольку невозможно было использовать предоставленный код для создания временных таблиц в данном контексте, 
была создана база данных TestDB с необходимыми таблицами. За исключением варианта с указанием названий нужных столбцов в SELECT вручную, 
я не увидел другого способа выполнения поставленной задачи.
*/

use TestDB

DECLARE @ColumnsName AS NVARCHAR(MAX)
DECLARE @SQL AS NVARCHAR(MAX)

SELECT @ColumnsName = STUFF(
	(SELECT DISTINCT ',' + QUOTENAME(FORMAT(DT, 'dd.MM.yyyy'))
	FROM [Plan]
	FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')

SET @SQL = '
SELECT 
	FName + '' '' + LName AS Empl, 
	' + @ColumnsName + '
FROM
(
	SELECT 
		[plan].UserId, [user].FName, [user].LName, [plan].DT,
		FORMAT(DATEADD(MINUTE, SUM(ISNULL([plan].PlanMin, 0)), 0), ''H:mm'') + ''/'' + 
		FORMAT(DATEADD(MINUTE, SUM(ISNULL(fact.FactTo - fact.FactFrom, 0)), 0), ''H:mm'') as PlanFact
	FROM [Plan] [plan]
	LEFT JOIN Fact fact ON [plan].Id = fact.PlanId
	LEFT JOIN [User] [user] ON [user].Id = [plan].UserId
	GROUP BY [user].FName, [user].LName, [plan].UserId, [plan].DT
) AS ResultTable
PIVOT
(
	MAX(PlanFact) FOR DT IN (' + @ColumnsName + ')
) AS PivotTable
ORDER BY FName;'

EXEC sp_executesql @SQL

