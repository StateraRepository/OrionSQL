USE [TheHunter]
GO

/****** Object:  View [dbo].[CombinedAuditLocationNames]    Script Date: 7/22/2015 2:38:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO























CREATE VIEW [dbo].[CombinedAuditLocationNames]
AS


Select distinct cat2.AuditId,
							substring(
							(
								Select distinct ', '+ CASE WHEN cat1.ClientLocInactive = 0 THEN cat1.ClientLocationName ELSE cat1.ClientLocationName + '(***Inactive***)' END  AS [text()]
								From ClientAuditTransmittal cat1
								Where cat1.AuditId = cat2.AuditId								
								ORDER BY ', '+ CASE WHEN cat1.ClientLocInactive = 0 THEN cat1.ClientLocationName ELSE cat1.ClientLocationName + '(***Inactive***)' END 
								For XML PATH ('')
							), 2, 4000) LocationNames
							From ClientAuditTransmittal cat2










GO

