USE [TheHunter]
GO

/****** Object:  View [dbo].[CombinedAuditLocationTypes]    Script Date: 7/22/2015 2:39:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

















CREATE VIEW [dbo].[CombinedAuditLocationTypes]
AS

Select distinct cat2.AuditId,
							substring(
							(
								Select distinct ', '+cat1.AuditTypeCode AS [text()]
								From ClientAuditTransmittal cat1
								Where cat1.AuditId = cat2.AuditId
								ORDER BY ', '+cat1.AuditTypeCode
								For XML PATH ('')
							), 2, 1000) AuditType
							From ClientAuditTransmittal cat2



GO

