USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_E_FORM_CONTRACT_NOTICE]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_E_FORM_CONTRACT_NOTICE](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NOT NULL,
	[cn16_AuctionConstraintIndicator] [varchar](5) NULL,
	[cn16_ContractingSystemTypeCode_framework] [varchar](5) NULL,
	[cn16_FundingProgramCode_eu_funded] [varchar](150) NULL,
	[cn16_FinancingIdentifier] [nvarchar](500) NULL,
	[cn16_FundingProgramCode_eu_programme] [varchar](150) NULL,
	[cn16_Funding_Description] [nvarchar](4000) NULL,
	[cn16_TendererRequirementTypeCode_reserved_proc] [varchar](15) NULL,
	[cn16_ExecutionRequirementCode_reserved_execution] [varchar](15) NULL,
	[cn16_CallForTendersDocumentReference_DocumentType] [varchar](50) NULL,
	[cn16_CallForTendersDocumentReference_ExternalRef] [nvarchar](4000) NULL,
	[CN16_CODICE_APPALTO] [nvarchar](500) NULL,
	[cn16_Funding_FinancingIdentifier] [nvarchar](4000) NULL,
	[cn16_OrgRicorso_Name] [nvarchar](2000) NULL,
	[cn16_OrgRicorso_CompanyID] [varchar](100) NULL,
	[cn16_OrgRicorso_CityName] [nvarchar](1000) NULL,
	[cn16_OrgRicorso_countryCode] [varchar](10) NULL,
	[cn16_OrgRicorso_ElectronicMail] [nvarchar](1000) NULL,
	[cn16_OrgRicorso_Telephone] [varchar](200) NULL,
	[cn16_ProcessJustification_ProcessReason] [nvarchar](4000) NULL,
	[cn16_ProcessJustification_accelerated_procedure] [varchar](10) NULL,
	[cn16_publication_id] [varchar](100) NULL,
	[cn16_FundingProgramCode] [varchar](100) NULL,
	[cn16_FundingProgram_Description] [nvarchar](4000) NULL,
	[cn16_OrgRicorso_codnuts] [varchar](100) NULL,
	[cn16_OrgRicorso_cap] [varchar](100) NULL
) ON [PRIMARY]
GO
