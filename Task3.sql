declare @UserCredit table (
Id int IDENTITY(1,1),
UserId int,
Credit numeric(18,2)
);

insert into @UserCredit
values (1, 20), (2, 25);
  
declare @UserPurchase table (
Id int IDENTITY(1,1),
UserId int,
Cost numeric(18,2), 
DT date, 
Name varchar(50)
);
	
insert into @UserPurchase 
values
 (1, 5, '24.04.2016', 'sku1'),
 (1, 6, '19.04.2016', 'sku2'),
 (1, 7, '22.04.2016', 'sku3'),
 (1, 8, '04.04.2016', 'sku4'),
 (1, 4, '18.04.2016', 'sku5'),
 (1, 5, '18.04.2016', 'sku6'),
 (1, 2, '29.04.2016', 'sku7');
 insert into @UserPurchase 
values
 (2, 5, '24.04.2016', 'sku1'),
 (2, 6, '19.04.2016', 'sku2'),
 (2, 7, '22.04.2016', 'sku3'),
 (2, 8, '04.04.2016', 'sku4'),
 (2, 4, '18.04.2016', 'sku5'),
 (2, 2, '29.04.2016', 'sku7');

SELECT
	UserId,
	DT,
	Name,
	CASE 
		WHEN LEAD(UserId) OVER (PARTITION BY UserId ORDER BY DT DESC) = UserId
		THEN Cost
		ELSE Credit - SumCost + Cost
	END AS [Purchase/Rest]
FROM (
	SELECT
		UP.UserId,
		UP.Cost,
		UP.DT,
		UP.Name,
		UC.Credit,
		SUM(UP.Cost) OVER(PARTITION BY UP.UserId ORDER BY UP.DT DESC, UP.Name DESC) AS SumCost
	FROM @UserPurchase UP
	JOIN @UserCredit UC ON UP.UserId = UC.UserId
) AS UserData
WHERE SumCost - Cost <= Credit
ORDER BY UserId, DT DESC;

