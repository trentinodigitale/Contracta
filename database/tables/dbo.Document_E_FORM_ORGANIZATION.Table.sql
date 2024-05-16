USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_E_FORM_ORGANIZATION]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_E_FORM_ORGANIZATION](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[idAzi] [int] NULL,
	[recordType] [varchar](100) NOT NULL,
	[PartyIdentification] [varchar](100) NULL,
	[fiscalNumber] [varchar](100) NULL,
	[PartyName] [nvarchar](2000) NULL,
	[CityName] [nvarchar](1000) NULL,
	[Country] [varchar](100) NULL,
	[Telephone] [varchar](500) NULL,
	[ElectronicMail] [nvarchar](1000) NULL,
	[telefax] [varchar](500) NULL,
	[formaGiuridica] [varchar](100) NULL,
	[attivitaAmm] [varchar](100) NULL,
	[postalCode] [varchar](100) NULL,
	[BuyerProfileURI] [nvarchar](2000) NULL,
	[ContactName] [nvarchar](1000) NULL,
	[idOfferta] [int] NULL,
	[Ruolo_Impresa] [varchar](100) NULL,
	[TENDERING_PARTY_ID] [varchar](10) NULL,
	[idaziRTI] [int] NULL,
	[RagSocRTI] [nvarchar](2000) NULL,
	[RTI] [int] NULL,
	[operationGuid] [varchar](100) NULL
) ON [PRIMARY]
GO
