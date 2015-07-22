USE [TheHunter]
GO

/****** Object:  View [dbo].[CombinedAuditLocationIds]    Script Date: 7/22/2015 2:38:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




















CREATE VIEW [dbo].[CombinedAuditLocationIds]
AS


Select distinct cat2.AuditId,
							substring(
							(
								Select distinct ', '+cast(cat1.ClientLocationId as varchar(100))  AS [text()]
								From ClientAuditTransmittal cat1
								Where cat1.AuditId = cat2.AuditId
								ORDER BY ', '+cast(cat1.ClientLocationId as varchar(100)) 
								For XML PATH ('')
							), 2, 4000) LocationIds
							From ClientAuditTransmittal cat2







GO

