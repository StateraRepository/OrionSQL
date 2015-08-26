USE [TheHunter]
GO

/****** Object:  StoredProcedure [Report].[AuditActivity]    Script Date: 8/26/2015 8:34:43 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Report].[AuditActivity]
(
	@IsInactive						bit = 0
	,@IsSuspended					bit = null
	,@ClientLocationId				int = -1
	,@ClientId						int = -1
	,@AuditId						int = -1
	,@CertifiedYear					int = -1
	,@Standard						varchar(255) = null
	,@PartnerCode					varchar(5) = null
)
AS
BEGIN

;WITH 
	 mincert AS (SELECT AuditId, Min(CertificateExpirationDate) as CertificateExpirationDate
				FROM dbo.AuditLocationStandard
				LEFT JOIN dbo.AuditLocation on AuditLocation.AuditLocationId=AuditLocationStandard.AuditLocationId and (auditlocation.isInactive=0 )
				GROUP BY AuditID  )
	,AuditDates as (SELECT AuditId, Min(AuditLocationAuditor.StartDate) as StartDate, Max(AuditLocationAuditor.EndDate) as EndDate
				FROM dbo.AuditLocationAuditor
				LEFT JOIN dbo.AuditLocation on AuditLocation.AuditLocationId=AuditLocationAuditor.AuditLocationId and (auditlocation.isInactive=0)
				where dbo.AuditLocationAuditor.isinactive=0 
				GROUP BY AuditID )
	,AuditCert as (SELECT als.AuditLocationId, Max(CAST(IsCertificatable as int)) as IsCertificatable
					FROM AuditType at inner join AuditLocationStandard als on at.AuditTypeId = als.AuditTypeId
					GROUP  BY AuditLocationId)
	,AuditTrans as (SELECT AuditID, Max(TotalWorkEffort) as TotalWorkEffort
				FROM AuditorAuditTransmittal
				GROUP BY AuditID)
	SELECT	distinct dbo.Audit.AuditId 
			, auditor.FullName
			, CertifierContact
			, calc.PhysicalCities 
			, calspc.StateProvinceCodes 
			, calcn.CountryNames 
			, dbo.Audit.ClientInvoiceSentDate AS ClientInvoiceSentDate
			,iif(dbo.Audit.ClientInvoicePaymentDate is null and dbo.Audit.BypassClientPayment = 1
					,'BYP'
					,iif(dbo.Audit.ClientInvoicePaymentDate is null and (dbo.Audit.BypassClientPayment is null or dbo.Audit.BypassClientPayment = 0)
						,''
						,'Yes')) AS ClientInvoicePaidStatus
			, dbo.Audit.ClientInvoicePaymentDate 
			, dbo.Audit.ClientTransmittalSignDate 
			, dbo.Audit.AuditorTransmittalSignDate 
			, dbo.Audit.AuditorPrepCompleteDate 
			, dbo.Audit.CertificateDraftCompleteDate 
			, dbo.Audit.AuditorReportCompleteDate 
			, dbo.Audit.TechReviewCompleteDate 
			, dbo.Audit.NonconformanceProcessDate 
			, dbo.Audit.CertifierDecisionDate
			, dbo.Audit.AuditCompleteDate 
			, mincert.CertificateExpirationDate
			, dbo.Audit.ClientId 
			, dbo.Audit.ReportingAuditorId 
			, dbo.Audit.ClientContactName 
			, dbo.Audit.ClientContact 
			, dbo.Audit.TechReviewerContact
			, dbo.Audit.CertifierContact 
			, dbo.Audit.AuditCompleteDate 
			, client.ClientName 
			, dbo.Audit.AuditReportQuality 
			, dbo.Audit.ClientTransmittalNote
			, dbo.Audit.ClientInvoiceSentDate
			, dbo.Audit.SchedulingCompleteDate 
			, dbo.Audit.IsInactive 
			, dbo.Audit.DeactivatedDate
			, dbo.Audit.DeactivatedBy 
			, dbo.Audit.CreatedDate 
			, dbo.Audit.CreatedBy 
			, dbo.Audit.ModifiedDate
			, dbo.Audit.ModifiedBy 
			, AuditDates.StartDate 
			, AuditDates.EndDate 
			, CASE	WHEN (AuditDates.EndDate) < '2015-01-01' THEN datename(year, (AuditDates.EndDate)) 
					ELSE datename(MONth, (AuditDates.EndDate)) 
					END AS Period
			, AuditCert.IsCertificatable 
			, CAST(report.[Last Step Completed] AS varchar(255)) AS AuditWorkflowStatus
			, iif(dbo.Audit.AuditCompleteDate is not null and dbo.Audit.NonconformanceProcessDate is null
					,'N/A'
					,report.[NCR Process Complete])  as [NCR Process Complete]
			, report.[Draft Verification Complete]
			, report.[Client Payment Received]
			, p.PartnerId 
			, p.PartnerCode 
			, Stds.Standards 
			, AuditTypes.AuditType 
			, AuditTrans.TotalWorkEffort 
			, LocationIds.LocationIds
			, LocationNamesIds.LocationIds as LocationNamesIds
			, LocationNames.LocationNames 
			, auditor.FullName 
			, AuditorNames.AuditorName 
			, CASE	WHEN DateDiff(DAY, AuditDates.EndDate, getdate()) > 14 THEN CAST(1 AS bit) 
					WHEN isnull(report.ClientTransmittalSignDate, '1/1/1900') = '1/1/1900' AND isnull(report.AuditorTransmittalSignDate, '1/1/1900') = '1/1/1900' AND isnull(report.AuditorPrepCompleteDate, '1/1/1900') <> '1/1/1900' THEN CAST(0 AS bit) 
					WHEN substring(report.[Last Step Completed], 0, 1) = 1 AND DateDiff(DAY, report.ClientTransmittalSignDate, getdate()) > 7 AND DateDiff(DAY, report.AuditorTransmittalSignDate, getdate()) > 7 THEN CAST(1 AS bit) 
					WHEN substring(report.[Last Step Completed], 0, 1) = 2 AND DateDiff(DAY, getdate(), AuditDates.StartDate) < 1 THEN CAST(1 AS bit) 
					WHEN substring(report.[Last Step Completed], 0, 1) = 3 AND DateDiff(DAY, AuditDates.EndDate, getdate()) > 7 THEN CAST(1 AS bit) 
					WHEN substring(report.[Last Step Completed], 0, 1) = 4 AND DateDiff(DAY, AuditDates.EndDate, getdate()) > 14 THEN CAST(1 AS bit) 
					WHEN substring(report.[Last Step Completed], 0, 1) = 5 AND DateDiff(DAY, AuditDates.EndDate, getdate()) > 14 THEN CAST(1 AS bit) WHEN substring(report.[Last Step Completed], 0, 1) = 6 AND DateDiff(DAY, AuditDates.EndDate, getdate()) > 14 THEN CAST(1 AS bit) 
					WHEN [NCR Process Complete] = 'No' AND DateDiff(DAY, AuditDates.EndDate, getdate()) > 7 THEN CAST(1 AS bit) 
					WHEN [Draft Verification Complete] = 'No' AND DateDiff(DAY, AuditDates.EndDate, getdate()) > 7 THEN CAST(1 AS bit) 
					WHEN [Client Payment Received] = 'No' AND DateDiff(DAY, AuditDates.EndDate, getdate()) > 7 THEN CAST(1 AS bit) 
					ELSE CAST(0 AS bit) END AS Overdue
			, Auditor.PayImmediate
	FROM	dbo.Audit 			
			INNER JOIN dbo.AuditLocation ON dbo.Audit.AuditId = dbo.AuditLocation.AuditId AND (dbo.AuditLocation.IsInactive = 0 ) 
			INNER JOIN dbo.AuditLocationAuditor ON dbo.AuditLocation.AuditLocationId = dbo.AuditLocationAuditor.AuditLocationId AND (dbo.AuditLocationAuditor.IsInactive = 0 ) 
			INNER JOIN dbo.AuditLocationStandard ON dbo.AuditLocation.AuditLocationId = dbo.AuditLocationStandard.AuditLocationId AND (dbo.AuditLocationStandard.IsInactive = 0 ) 
			INNER JOIN dbo.AuditType ON dbo.AuditLocationStandard.AuditTypeId = dbo.AuditType.AuditTypeId AND (dbo.AuditType.IsInactive = 0 ) 
			INNER JOIN AuditCert ON AuditLocation.AuditLocationId = AuditCert.AuditLocationId
			INNER JOIN ReportAuditStatus AS report ON report.auditid = dbo.Audit.AuditId 
			INNER JOIN dbo.ClientLocation AS clientlocation ON dbo.AuditLocation.ClientLocationId = clientlocation.ClientLocationId 
			INNER JOIN dbo.Client AS client ON clientlocation.ClientId = client.ClientId 
			INNER JOIN dbo.Partner AS p ON p.PartnerID = client.PartnerId and (p.IsInactive = 0) 
			INNER JOIN dbo.Auditor AS auditor ON auditor.AuditorId = dbo.Audit.ReportingAuditorId 
			INNER JOIN CombinedAuditLocationStandards AS Stds ON Stds.AuditId = dbo.Audit.AuditId 
			INNER JOIN CombinedAuditLocationTypes AS AuditTypes ON AuditTypes.AuditId = dbo.Audit.AuditId 
			INNER JOIN CombinedAuditLocationIds AS LocationIds ON LocationIds.AuditId = dbo.Audit.AuditId
			INNER JOIN CombinedAuditLocationNames AS LocationNames on LocationNames.AuditId = dbo.Audit.AuditId 
			LEFT JOIN CombinedAuditLocationIdsNames As LocationNamesIds on LocationNamesIds.AuditID = dbo.Audit.AuditId 
			LEFT JOIN CombinedAuditAuditors AS AuditorNames ON AuditorNames.AuditId = dbo.Audit.AuditId 
			LEFT JOIN dbo.AuditorAuditTransmittal AS aat_1 ON aat_1.AuditId = dbo.Audit.AuditId 
			LEFT JOIN CombinedAuditLocationCities AS calc on calc.AuditId = dbo.Audit.AuditId
			LEFT JOIN CombinedAuditLocationStateProvinceCodes AS calspc on calspc.AuditId = dbo.Audit.AuditId
			LEFT JOIN CombinedAuditLocationCountryNames AS calcn on calcn.AuditId = dbo.Audit.AuditId
			LEFT JOIN mincert on mincert.AuditId=dbo.Audit.AuditId
			LEFT JOIN auditdates on auditdates.AuditId=dbo.Audit.AuditId
			LEFT JOIN AuditTrans on dbo.Audit.AuditId = AuditTrans.AuditId
	where	report.SchedulingCompleteDate is not null 
			and dbo.AuditType.AuditTypeId is not null
			and (client.ClientId = @ClientId or @ClientId=-1)
			and (clientlocation.ClientLocationId = @ClientLocationId or @ClientLocationId=-1)
			and (Audit.auditid = @AuditId or @AuditId=-1)
			and (year(Audit.[CertifierDecisionDate])=@CertifiedYear or @CertifiedYear=-1)
			and (Stds.Standards like ('%'+@Standard+'%') or @Standard is null)
			and (Audit.IsInactive=0 or @IsInactive=1)
			and (Audit.isinactive = @isInactive)--and (Audit.AuditId=@AuditId or @AuditId is null)
			and (p.PartnerCode=@PartnerCode or @PartnerCode is null)
				
END
	

GO


