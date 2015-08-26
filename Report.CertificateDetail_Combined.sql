USE [TheHunter]
GO

/****** Object:  StoredProcedure [Report].[CertificateDetail_Combined]    Script Date: 8/26/2015 8:37:59 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Dan Lawless
-- Create date: 8/20/2015
-- Description:	Retrieves active certficate data from both Hunter and BMS
-- =============================================
CREATE PROCEDURE [Report].[CertificateDetail_Combined]
	-- Add the parameters for the stored procedure here
(
	@IsInactive						bit = 0
	,@IsSuspended					bit = 0
	,@ClientLocationId				int = -1
	,@ClientId						int = -1
	,@AuditId						int = -1
	,@CertifiedYear					int = -1
	,@StandardId					int = null
	,@StartDate						date = '1/1/1900'
	,@EndDate						date = '1/1/2200'
)
AS
BEGIN
	SET NOCOUNT ON;

--drop table #HunterCerts
Create table #HunterCerts
(
	[Partner] varchar(5),
	[CertificateID] varchar(200),
	[AuditCertifiedYear] int,
	[Client Name] varchar(200),
	[Client ID] int,
	[Location ID] int,
	[Location Name] varchar(200),
	[City] varchar(200),
	[State] varchar(5),
	[Country] varchar(200),
	[CertificateEffectiveDate] datetime,
	[Expiration Date] datetime,
	[Standard] varchar(200),
	[StandardID] int,
	[IsSuspended] bit,
	[IsWithdrwan] bit,
	[TransferDate] datetime,
	[CertStatus] varchar(20),
	[Certifier Decision] datetime,
	[Audit Complete] datetime,
	[Audit ID] varchar(200),
	[AuditType] varchar(200),
)
--drop table #HunterCerts

Insert into #HunterCerts
exec Report.CertificateDetail @IsInactive, @IsSuspended, @ClientLocationId, @ClientId, @AuditId, @CertifiedYear, @StandardId, @StartDate, @EndDate

--drop table #BMSCerts
Create table #BMSCerts
(
	[Client Name] varchar(200),
	[City] varchar(200),
	[State] varchar(200),
	[Country] varchar(200),
	[Standard] varchar(200),
	[CertificateID] varchar(200),
	[Expiration Date] datetime
) 


--select * from #HunterCerts

Insert into #BMSCerts
exec Report.CertificateDetail_BMS

select 	
	'BMS' as Source,
	'ORI' as [Partner],
	[Client Name],
	[City] ,
	[State] ,
	[Country] ,
	[Standard] ,
	[CertificateID] ,
	[Expiration Date] 
from #BMSCerts
UNION
Select
	'Hunter' as Source,
	[Partner],
	[Client Name],
	[City] ,
	[State] ,
	[Country] ,
	[Standard] ,
	[CertificateID] ,
	[Expiration Date]
From #HunterCerts

END

GO


