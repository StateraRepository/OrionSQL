USE [TheHunter]
GO

/****** Object:  View [dbo].[CombinedAuditLocationCountryNames]    Script Date: 7/22/2015 2:38:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[CombinedAuditLocationCountryNames]
AS


Select distinct cat2.AuditId,
							substring(
							(
								Select distinct ', '+ c.CountryName AS [text()]
								From ClientAuditTransmittal cat1
								left join Country c on c.CountryId=cat1.PhysicalAddressCountryId
								Where cat1.AuditId = cat2.AuditId
								ORDER BY ', '+ c.CountryName
								For XML PATH ('')
							), 2, 4000) CountryNames
							From ClientAuditTransmittal cat2








GO

