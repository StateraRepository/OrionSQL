USE [TheHunter]
GO

/****** Object:  StoredProcedure [Report].[CertificateDetail_BMS]    Script Date: 8/26/2015 8:37:13 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Dan Lawless
-- Create date: 8/20/2015
-- Description:	Pull all active certificates from BMS
-- =============================================
CREATE PROCEDURE [Report].[CertificateDetail_BMS]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

select * from 
openquery([ORIONSQL], 
'select  replace(replace(replace(location.SiteName,char(9),'' ''),char(10),'' ''),char(13),'' '')  as Name,
		ISNULL(replace(replace(replace(Location.PriCity,char(9),'' ''),char(10),'' ''),char(13),'' ''), '''') as City,
    	
    	ISNULL(region.RegionCode,'''') as StateOrProvince, 
    	country.countryname as Country,  
    	
    	CASE
		WHEN cert.certcomplete = ''1''
		THEN Version.Version
		ELSE RevVersion.Version
		END as Version,
			
		CASE
		WHEN cert.certcomplete = ''1'' then partner.AlphaCode+  RIGHT(''000000''+CONVERT(VARCHAR,cert.CertificateNumber),7)+  ''-''+ CONVERT(VARCHAR,cert.currentrevision)
		else partner.AlphaCode+  RIGHT(''000000''+CONVERT(VARCHAR,cert.CertificateNumber),7)+  ''-''+ CONVERT(VARCHAR,revision.revisionnumber)
		end as CertificateNumber,
		
		CASE
		WHEN cert.certcomplete = ''1'' then CONVERT(VARCHAR(10),cert.ExpirationDate,101)
		else CONVERT(VARCHAR(10),cert.ExpirationDate,101)
		end as CertificateDate
	
from ori.certificate.certificate cert
left join ori.company.company client on client.companyid=cert.companyid
left join ori.company.site Location on Location.siteid=cert.siteid
left join ori.partner.partner partner on partner.partnerid=client.partnerid
left join ori.standard.standard standard on standard.StandardId=cert.StandardID
left join ori.common.region region on region.RegionId=Location.PriRegionID
left join ori.common.country country on country.CountryId=Location.PriCountryID
left join ori.standard.version version on version.VersionId=Cert.VersionId
left join ori.certificate.revision revision on revision.certificateid=Cert.certificateid and revision.RevisionSuperceded=''0''
left join ori.standard.version RevVersion on RevVersion.VersionId=Revision.VersionId 

where	cert.ExpirationDate > getdate()
		and cert.inactive = ''0''
	    and standard.standard = ''R2''
	    and (cert.certcomplete = ''1'' or revision.revisionnumber is not null)
	    	    
ORDER BY CompanyName,location.certsitename, location.pricity')



END

GO


