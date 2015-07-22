USE [TheHunter]
GO

/****** Object:  View [dbo].[CombinedAuditLocationStandards]    Script Date: 7/22/2015 2:38:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


















CREATE VIEW [dbo].[CombinedAuditLocationStandards]
AS

Select distinct cat2.AuditId,
				substring(
				(
					Select distinct ', '+cat1.StandardName AS [text()]
					From ClientAuditTransmittal cat1
					Where cat1.AuditId = cat2.AuditId
					ORDER BY ', '+cat1.StandardName
					For XML PATH ('')
				), 2, 1000) Standards
				From ClientAuditTransmittal cat2





GO

