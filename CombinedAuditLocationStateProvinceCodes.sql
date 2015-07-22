USE [TheHunter]
GO

/****** Object:  View [dbo].[CombinedAuditLocationStateProvinceCodes]    Script Date: 7/22/2015 2:39:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[CombinedAuditLocationStateProvinceCodes]
AS


Select distinct cat2.AuditId,
							substring(
							(
								Select distinct ', '+ sp.StateProvinceCode AS [text()]
								From ClientAuditTransmittal cat1
								left join StateProvince sp on sp.StateProvinceId=cat1.PhysicalAddressStateProvinceId
								Where cat1.AuditId = cat2.AuditId
								ORDER BY ', '+ sp.StateProvinceCode
								For XML PATH ('')
							), 2, 4000) StateProvinceCodes
							From ClientAuditTransmittal cat2









GO

