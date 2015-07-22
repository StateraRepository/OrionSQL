USE [TheHunter]
GO

/****** Object:  View [dbo].[CombinedAuditAuditors]    Script Date: 7/22/2015 2:37:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



















CREATE VIEW [dbo].[CombinedAuditAuditors]
AS

Select distinct aat2.AuditId,
							substring(
							(
								Select distinct ', '+aat1.AuditorName AS [text()]
								From AuditorAuditTransmittal aat1
								Where aat1.AuditId = aat2.AuditId
								ORDER BY ', '+aat1.AuditorName
								For XML PATH ('')
							), 2, 1000) AuditorName
							From ClientAuditTransmittal aat2





GO

