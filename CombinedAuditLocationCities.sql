USE [TheHunter]
GO

/****** Object:  View [dbo].[CombinedAuditLocationCities]    Script Date: 7/22/2015 2:37:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




















CREATE VIEW [dbo].[CombinedAuditLocationCities]
AS


Select distinct cat2.AuditId,
							substring(
							(
								Select distinct ', '+ cat1.PhysicalAddressCity AS [text()]
								From ClientAuditTransmittal cat1
								Where cat1.AuditId = cat2.AuditId
								ORDER BY ', '+ cat1.PhysicalAddressCity 
								For XML PATH ('')
							), 2, 4000) PhysicalCities
							From ClientAuditTransmittal cat2







GO

