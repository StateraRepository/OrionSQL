USE [TheHunter]
GO
/****** Object:  StoredProcedure [Report].[AuditActivity_Wrapper]    Script Date: 8/26/2015 8:35:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Report].[AuditActivity_Wrapper]
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

CREATE Table #HunterResults --Holds results of Hunter Audit Status
	(
	AuditId2                         int
	,FullName                        varchar(92)
	,CertifierContact                varchar(100)
	,PhysicalAddressCity             nvarchar(max)
	,StateProvinceCode               nvarchar(max)
	,CountryName                     nvarchar(max)
	,[Client Inv. Sent]              datetime
	,[Client Inv. Paid Status]		 varchar(100)
	,[Client Inv. Paid]              datetime
	,[Client Transmittal Sign]       datetime
	,[Auditor Transmittal Sign]      datetime
	,[Auditor Prep Complete]         datetime
	,[Certificate Draft Complete]    datetime
	,[Auditor Report Complete]       datetime
	,[Tech Review Complete]          datetime
	,[Nonconformance Process]        datetime
	,[Certifier Decision]            datetime
	,[Audit Complete]                datetime
	,[Certificate Expiration]        datetime
	,[ClientId2]                     int
	,[ReportingAuditorId2]           int
	,[ClientContactName2]            varchar(100)
	,[ClientContact2]                varchar(100)
	,[TechReviewerContact2]          varchar(100)
	,[CertifierContact2]             varchar(100)
	,[AuditCompleteDate2]            datetime
	,[Client Name]                   varchar(200)
	,[AuditReportQuality2]           varchar(50)
	,[ClientTransmittalNote2]        varchar(4000)
	,[ClientInvoiceSentDate2]        datetime
	,[SchedulingCompleteDate2]       datetime
	,[IsInactive2]                   bit
	,[DeactivatedDate2]              datetime
	,[DeactivatedBy2]                varchar(100)
	,[CreatedDate2]                  datetime
	,[CreatedBy2]                    varchar(100)
	,[ModifiedDate2]                 datetime
	,[ModifiedBy2]                   varchar(100)
	,[AuditStartDate2]               datetime
	,[AuditEndDate2]                 datetime
	,[Period]                        nvarchar(30)
	,[IsCertificatable2]             int
	,[AuditWorkflowStatus2]          varchar(255)
	,[NCR Process Complete]          varchar(3)
	,[Draft Verification Complete]   varchar(3)
	,[Client Payment Received]       varchar(3)
	,[PartnerId2]                    int
	,[PartnerCode2]                  varchar(20)
	,[Standards2]                    nvarchar(max)
	,[AuditTypes2]                   nvarchar(max)
	,[TotalWorkEffort2]              decimal(38,2)
	,[AuditLocations2]               nvarchar(max)
	,[AuditLocationNameIds2]		 nvarchar(max)
	,[AuditLocationNames2]           nvarchar(max)
	,[LeadAuditor2]                  varchar(92)
	,[AuditorNames]                  nvarchar(max)
	,[Overdue2]                      bit
	,[PayImmediate]                  bit
)

--Capture complete set of Hunter audit activity in temp table
Insert into #HunterResults
Exec [Report].[AuditActivity] @IsInactive, @IsSuspended, @ClientLocationId, @ClientId, @AuditId, @CertifiedYear, @Standard, @PartnerCode

select 
	AuditId2                         
	,FullName                        
	,CertifierContact                
	,PhysicalAddressCity             
	,StateProvinceCode               
	,CountryName                     
	,[Client Inv. Sent]              
	,[Client Inv. Paid Status]		 
	,[Client Inv. Paid]              
	,[Client Transmittal Sign]       
	,[Auditor Transmittal Sign]      
	,[Auditor Prep Complete]         
	,[Certificate Draft Complete]    
	,[Auditor Report Complete]       
	,[Tech Review Complete]          
	,[Nonconformance Process]        
	,[Certifier Decision]            
	,[Audit Complete]                
	,[Certificate Expiration]        
	,[ClientId2]                     
	,[ReportingAuditorId2]           
	,[ClientContactName2]            
	,[ClientContact2]                
	,[TechReviewerContact2]          
	,[CertifierContact2]             
	,[AuditCompleteDate2]            
	,[Client Name]                   
	, NULL AS AuditActivitiesCompleteDate
	, NULL AS AccountingCompleteDate
	, NULL AS PAWSReceivedDate
	, NULL AS AuditReportCompleteDate
	, NULL AS AuditReportReceivedDate
	, NULL AS AuditReportSentToClientDate
	,[AuditReportQuality2]           
	,[ClientTransmittalNote2]        
	, NULL AS ClientTransmittalSentDate
	, NULL AS ClientTransmittalReceivedDate
	,[ClientInvoiceSentDate2]        
	, NULL AS ClientInvoicePaidDate      
	,[SchedulingCompleteDate2]       
	,[IsInactive2]                   
	,[DeactivatedDate2]              
	,[DeactivatedBy2]                
	,[CreatedDate2]                  
	,[CreatedBy2]                    
	,[ModifiedDate2]                 
	,[ModifiedBy2]                   
	,[AuditStartDate2]               
	,[AuditEndDate2]                 
	,[Period]                        
	,[IsCertificatable2]             
	,[AuditWorkflowStatus2]          
	,[NCR Process Complete]          
	,[Draft Verification Complete]   
	,[Client Payment Received]       
	,[PartnerId2]                    
	,[PartnerCode2]                  
	,[Standards2]                    
	,[AuditTypes2]                   
	,[TotalWorkEffort2]             
	,[AuditLocations2]	
	,[AuditLocationNameIds2]
	,[AuditLocationNames2]           
	,[LeadAuditor2]                  
	,[AuditorNames]                  
	,[Overdue2]                      
	,[PayImmediate]                  
from #HunterResults

END
