USE [TheHunter]
GO

/****** Object:  StoredProcedure [Report].[ActiveCertificates]    Script Date: 7/22/2015 2:40:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [Report].[ActiveCertificates]
(
	@IsInactive						bit = 0
	,@IsSuspended					bit = null
	,@ClientLocationId				int = -1
	,@ClientId						int = -1
	,@AuditId						int = -1
	,@CertifiedYear					int = -1
	,@StandardId					int = null
)
AS
BEGIN
			  


	SET NOCOUNT ON;

	WITH AuditIdList AS	(Select distinct CLTLOC2.ClientLocationId
							,ALSR2.StandardId
							,AUD2.AuditId
							,substring(
							 (Select distinct ', '+Cast(AUD.AuditId as varchar(10)) AS [text()]
												FROM [TheHunter].[dbo].[NearestCertExpiration] NCE
														LEFT JOIN [dbo].[AuditLocationStandardRollup] ALSR ON ALSR.auditlocationstandardid = NCE.lastalswithexpirationdate and ALSR.IsInactive=@IsInactive
														LEFT JOIN [dbo].[Client] CLT ON CLT.[ClientId] = ALSR.[ClientId] and CLT.isinactive=@IsInactive
														LEFT JOIN [dbo].[AuditLocation] AL ON AL.AuditLocationId = ALSR.AuditLocationId and AL.IsInactive=@IsInactive
														LEFT JOIN [dbo].[ClientLocation] CLTLOC ON CLTLOC.ClientLocationId=AL.ClientLocationId and CLTLOC.IsInactive=@IsInactive
														LEFT JOIN [dbo].[Audit] AUD ON AUD.[AuditId] = ALSR.[AuditId] and AUD.IsInactive=@IsInactive
												Where CLTLOC.ClientLocationId = CLTLOC2.ClientLocationId and ALSR.StandardId=ALSR2.StandardId and ALSR.[CertificateExpirationDate] is not null 
												ORDER BY ', '+Cast(AUD.AuditId as varchar(10))
												For XML PATH ('')
							 ), 2, 1000) AuditIds
					 From  [TheHunter].[dbo].[NearestCertExpiration] NCE2
							LEFT JOIN [dbo].[AuditLocationStandardRollup] ALSR2 ON ALSR2.auditlocationstandardid = NCE2.lastalswithexpirationdate and ALSR2.IsInactive=@IsInactive
							LEFT JOIN [dbo].[Client] CLT2 ON CLT2.[ClientId] = ALSR2.[ClientId] and CLT2.isinactive=@IsInactive
							LEFT JOIN [dbo].[AuditLocation] AL2 ON AL2.AuditLocationId = ALSR2.AuditLocationId and AL2.IsInactive=@IsInactive
							LEFT JOIN [dbo].[ClientLocation] CLTLOC2 ON CLTLOC2.ClientLocationId=AL2.ClientLocationId and CLTLOC2.IsInactive=@IsInactive
							LEFT JOIN [dbo].[Audit] AUD2 ON AUD2.[AuditId] = ALSR2.[AuditId] and AUD2.IsInactive=@IsInactive
					 Where ALSR2.[CertificateExpirationDate] is not null 
					)

	, CombinedTypes AS	(Select distinct AuditIdList.ClientLocationId,AuditIdList.StandardId,AuditIdList.AuditIds,
							substring(
							(
								Select distinct ', '+cat1.AuditTypeCode AS [text()]
								From ClientAuditTransmittal cat1
								Where AuditIdList.AuditIds+',' like ('% '+cast(cat1.AuditId as varchar(10))+',%') --and cat1.ClientLocationId=AuditIdList.ClientLocationId and cat1.StandardId=AuditIdList.StandardId
								ORDER BY ', '+cat1.AuditTypeCode
								For XML PATH ('')
							), 2, 1000) AuditTypes
						 From AuditIdList
						)

	SELECT distinct
			 PRT.[PartnerCode] AS [Partner]
			 --, ALSR.AuditId AS [Audit ID]
			 --, CALT.AuditType AS AuditType
			 , CombinedTypes.AuditIds as [Audit ID]
			 , CombinedTypes.AuditTypes AS AuditType
			 , year(AUD.[CertifierDecisionDate]) AS AuditCertifiedYear
			 , CLT.[ClientName] AS [Client Name]
			 , CLT.[ClientId] AS [Client Id]
			 , CLTLOC.[ClientLocationId] AS [Location Id]
			 , CLTLOC.[ClientLocationName] AS [Location Name]
			 , CLTLOC.[PhysicalAddressCity] AS [City]
			 , SP.[StateProvinceCode] AS [State]
			 , CTRY.[CountryName] AS [Country]
			 , max(AUD.[CertifierDecisionDate]) AS [Certifier Decision]
			 , max(AUD.[AuditCompleteDate]) AS [Audit Complete]
			 , ALSR.[CertificateExpirationDate] AS [Expiration Date]
			 , STD.StandardName AS [Standard]  
			 , STD.StandardId AS StandardId 
			 , CLS.IsSuspended AS IsSuspended
	FROM	[TheHunter].[dbo].[NearestCertExpiration] NCE
			LEFT JOIN [dbo].[AuditLocationStandardRollup] ALSR on ALSR.auditlocationstandardid = NCE.lastalswithexpirationdate and ALSR.IsInactive=@IsInactive
			LEFT JOIN [dbo].[Client] CLT ON CLT.[ClientId] = ALSR.[ClientId] and CLT.isinactive=@IsInactive
			LEFT JOIN [dbo].[Partner] PRT ON PRT.PartnerId = CLT.PartnerId and PRT.isinactive=@IsInactive
			LEFT JOIN [dbo].[AuditLocation] AL ON AL.AuditLocationId = ALSR.AuditLocationId and AL.IsInactive=@IsInactive
			LEFT JOIN [dbo].[ClientLocation] CLTLOC ON CLTLOC.ClientLocationId=AL.ClientLocationId and CLTLOC.IsInactive=@IsInactive
			LEFT JOIN [dbo].[StateProvince] SP ON SP.StateProvinceId = CLTLOC.PhysicalAddressStateProvinceId and SP.IsInactive=@IsInactive
			LEFT JOIN [dbo].[Country] CTRY ON CTRY.CountryId = SP.CountryId and CTRY.IsInactive=@IsInactive
			LEFT JOIN [dbo].[Standard] STD ON STD.[StandardId] = ALSR.[StandardId] and STD.IsInactive=@IsInactive
			LEFT JOIN [dbo].[Audit] AUD ON AUD.[AuditId] = ALSR.[AuditId] and AUD.IsInactive=@IsInactive
			LEFT JOIN AuditIdList on AuditIdList.ClientLocationId=CLTLOC.ClientLocationId and AuditIdList.StandardId=ALSR.StandardId
			LEFT JOIN CombinedTypes on CombinedTypes.ClientLocationId=CLTLOC.ClientLocationId and CombinedTypes.StandardId=ALSR.StandardId
			LEFT JOIN [dbo].[ClientLocationStandard] CLS on CLS.StandardId=ALSR.StandardId and CLS.ClientLocationId=CLTLOC.ClientLocationId and CLS.IsInactive=@IsInactive
	where ALSR.[CertificateExpirationDate] is not null 
		   and (CLS.IsSuspended=@IsSuspended or (CLS.IsSuspended is null and @IsSuspended=0) or @IsSuspended is null)
		   and (CLT.ClientId = @ClientId or @ClientId=-1)
		   and (CLTLOC.ClientLocationId = @ClientLocationId or @ClientLocationId=-1)
		   and (ALSR.auditid = @AuditId or @AuditId=-1)
		   and (year(AUD.[CertifierDecisionDate])=@CertifiedYear or @CertifiedYear=-1)
		   and (STD.StandardId=@StandardId or @StandardId is null)

	group by  PRT.[PartnerCode]
			 --, ALSR.AuditId
			 --, CALT.AuditType
			 , CombinedTypes.AuditIds
			 , CombinedTypes.AuditTypes
			 , year(AUD.[CertifierDecisionDate])
			 , CLT.[ClientName]
			 , CLT.[ClientId]
			 , CLTLOC.[ClientLocationId]
			 , CLTLOC.[ClientLocationName]
			 , CLTLOC.[PhysicalAddressCity]
			 , SP.[StateProvinceCode]
			 , CTRY.[CountryName]
			 , CLT.[ClientName]
			 , CLTLOC.[ClientLocationId]
			 , CLTLOC.[ClientLocationName]
			 , CLTLOC.[PhysicalAddressCity]
			 , SP.[StateProvinceCode]
			 , CTRY.[CountryName]
			 , ALSR.[CertificateExpirationDate]
			 , STD.StandardName
			 , STD.StandardId 
			 , CLS.IsSuspended
	order by CLT.[ClientName]
			 
END






GO

