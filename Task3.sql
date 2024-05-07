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

