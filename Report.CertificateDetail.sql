USE [TheHunter]
GO

/****** Object:  StoredProcedure [Report].[CertificateDetail]    Script Date: 8/26/2015 8:36:31 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Chris Pixler
-- Create date: 8/24/2015
-- Description:Retrieve all active certificates from Hunter
-- =============================================
CREATE PROCEDURE [Report].[CertificateDetail]
	@IsInactive						bit = 0
	,@IsSuspended					bit = 0
	,@ClientLocationId				int = -1
	,@ClientId						int = -1
	,@AuditId						int = -1
	,@CertifiedYear					int = -1
	,@StandardId					int = null
	,@StartDate						date = '1/1/1900'
	,@EndDate						date = '1/1/2200'AS
BEGIN
	SET NOCOUNT ON;

       /* -------------------------------Debug Only --------------------------------
       DECLARE @IsInactive  as bit = 0 -- 0 = don't show row with Client, CL, CLS or Std inactive, a "1" shows the inactive rows with ***Inactive***
       DECLARE @IsSuspended as    bit = 0 -- 0 = don't show suspended or withdrawn, 1 = include suspended and withdrawn
       DECLARE @ClientLocationId as int = -1 -- -1 = show all client locations
       DECLARE @ClientId as int = -1 -- -1 = show all clients
       DECLARE @AuditId as  int = -1 -- -1 = show all audits
       DECLARE @CertifiedYear as int = -1 -- -1 = show all; This applies to the Certificate Effective Date from the CLS
       DECLARE @StandardId  as int = null -- null = show all
       DECLARE @StartDate as date = '1/1/1900' -- date range for Cert Effective Date
       DECLARE @EndDate as  date = '1/1/2200'
	   --*/-------------------------------Debug Only---------------------------
              
       SELECT 
                     PRT.[PartnerCode] AS [Partner]
                     ,ALSCLSC.AuditLocationStandardClientLocationStandardCertificateId AS CertificateId
                     , year(ALSCLSC.CertificateEffectiveDate) AS AuditCertifiedYear
                     , CASE WHEN CLT.IsInactive = 0 THEN CLT.ClientName ELSE CLT.ClientName + '(***Inactive***)' END as [Client Name]
                     , CLT.[ClientId] AS [Client Id]
                     , CL.[ClientLocationId] AS [Location Id]
                     , CASE
                           WHEN CL.IsInactive = 1 THEN CL.ClientLocationName + '(***Inactive***)' 
                            WHEN CLS.IsInactive = 1 THEN CL.ClientLocationName + '(***CLS Inactive***)' 
                            ELSE CL.ClientLocationName 
                            END as [Location Name]
                     , CL.[PhysicalAddressCity] AS [City]
                     , SP.[StateProvinceCode] AS [State]
                     , CTRY.[CountryName] AS [Country]
                     , ALSCLSC.CertificateEffectiveDate 
                     , ALSCLSC.[CertificateExpirationDate] AS [Expiration Date]
                     , CASE WHEN STD.IsInactive = 0 THEN STD.StandardName ELSE STD.StandardName + '(***Inactive***)' END as [Standard]  
                     , STD.StandardId AS StandardId 
                     , CLS.IsSuspended AS IsSuspended
                     , CLS.IsWithdrawn AS IsWithdrawn
                     , CLS.TransferExpirationDate as TransferDate
                     , CASE 
                           WHEN CLS.IsWithdrawn = 1 THEN 'Withdrawn'
                           WHEN CLS.IsSuspended = 1 THEN 'Suspended'
                           ELSE 'Active'
                           END as CertStatus
                     , AUD.[CertifierDecisionDate] AS [Certifier Decision]
                     , AUD.[AuditCompleteDate] AS [Audit Complete]
                     , AUD.[AuditID]
                     , AT.AuditTypeCode
                                                               
       FROM   [dbo].[AuditLocationStandardClientLocationStandardCertificate] ALSCLSC
                     JOIN [dbo].[ClientLocationStandard] CLS on CLS.ClientLocationStandardId = ALSCLSC.ClientLocationStandardId
                     JOIN [dbo].[ClientLocation] CL ON CL.ClientLocationId=CLS.ClientLocationId
                     JOIN [dbo].[Client] CLT ON CLT.[ClientId] = CL.[ClientId]
                     JOIN [dbo].[Partner] PRT ON PRT.PartnerId = CLT.PartnerId
                     LEFT JOIN [dbo].[StateProvince] SP ON SP.StateProvinceId = CL.PhysicalAddressStateProvinceId
                     JOIN [dbo].[Country] CTRY ON CTRY.CountryId = CL.PhysicalAddressCountryId 
                     JOIN [dbo].[Standard] STD ON STD.[StandardId] = CLS.[StandardId]
                     LEFT JOIN [dbo].[AuditLocationStandard] ALS on ALS.AuditLocationStandardID = ALSCLSC.AuditLocationStandardID
                     LEFT JOIN [dbo].[AuditLocation] AL on AL.AuditLocationID = ALS.AuditLocationID
                     LEFT JOIN [dbo].[Audit] AUD on AUD.AuditID = AL.AuditID
                     JOIN [dbo].[AuditType] AT ON AT.[AuditTypeId] = ALS.[AuditTypeId]
                     
       where ALSCLSC.isInactive = 0 and ALSCLSC.IsFinal = 1 
                     and ALSCLSC.CertificateExpirationDate >= GETDATE()
                     and (@IsInactive = 0 or (CLT.IsInactive = 0 and CL.IsInactive = 0 and std.IsInactive = 0 and CLS.IsInactive = 0))
                     and (@IsSuspended = 0 or (CLS.IsSuspended=0 and CLS.IsWithdrawn = 0))
                  and (CLT.ClientId = @ClientId or @ClientId=-1)
                  and (CL.ClientLocationId = @ClientLocationId or @ClientLocationId=-1)
                  and (AUD.auditid = @AuditId or @AuditId=-1)
                  and (year(ALSCLSC.[CertificateEffectiveDate])=@CertifiedYear or @CertifiedYear=-1)
                  and (STD.StandardId=@StandardId or @StandardId is null)
                  and (ALSCLSC.CertificateEffectiveDate >= @StartDate )
                  and (ALSCLSC.CertificateEffectiveDate <= @EndDate)

                     ORDER BY CLT.CLientName


END

GO


