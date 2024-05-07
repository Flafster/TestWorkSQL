SELECT  
	Region.Name AS Region,
	FORMAT(DATEADD(MINUTE, SUM([Plan].[PlanMin]), 0), 'H:mm') AS PlanMin,
	FORMAT(DATEADD(MINUTE, SUM(Fact.FactTo - Fact.FactFrom), 0), 'H:mm') AS FactMin,
	(
	SELECT 
		City.Name AS City,
		FORMAT(DATEADD(MINUTE, SUM([Plan].PlanMin), 0), 'H:mm') AS PlanMin,
		COALESCE(FORMAT(DATEADD(MINUTE, SUM(Fact.FactTo - Fact.FactFrom), 0), 'H:mm'), '0:00') AS FactMin,
		(
		SELECT 
			Network.Name AS Network,
			FORMAT(DATEADD(MINUTE, SUM([Plan].PlanMin), 0), 'H:mm') AS PlanMin,
			COALESCE(FORMAT(DATEADD(MINUTE, SUM(Fact.FactTo - Fact.FactFrom), 0), 'H:mm'), '0:00') AS FactMin
		FROM @Network Network
		JOIN @Shop Shop ON Shop.CityId = City.Id
		JOIN @Plan [Plan] ON [Plan].ShopId = Shop.Id
		LEFT JOIN @Fact Fact ON [Plan].Id = Fact.PlanId
		WHERE Network.Id = Shop.NetworkId
		GROUP BY Network.Name
		FOR XML PATH('item'), ROOT('items'), TYPE
		)
	FROM @Territorys City
	JOIN @Shop Shop ON Shop.CityId = City.Id
	JOIN @Plan [Plan] ON [Plan].ShopId = Shop.Id
	LEFT JOIN @Fact Fact ON [Plan].Id = Fact.PlanId
	WHERE City.ParentID = Region.Id
	GROUP BY City.Name, City.ParentID, City.Id
	FOR XML PATH('item'), ROOT('items'), TYPE
	)
FROM @Territorys Region 
LEFT JOIN @Territorys City ON Region.Id = City.ParentID
LEFT JOIN @Shop Shop ON City.Id = Shop.CityId
LEFT JOIN @Plan [Plan] ON Shop.Id = [Plan].ShopId
LEFT JOIN @Fact Fact ON [Plan].Id = Fact.PlanId
WHERE Region.ParentID IS NULL
GROUP BY Region.Name, Region.Id
ORDER BY Region.Name
FOR XML PATH('item'), ROOT('items'), TYPE
