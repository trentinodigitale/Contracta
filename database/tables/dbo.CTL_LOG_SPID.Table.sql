USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_LOG_SPID]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_LOG_SPID](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idpfu] [int] NULL,
	[AspSessionID] [varchar](250) NOT NULL,
	[ipServer] [varchar](1000) NULL,
	[ipChiamante] [varchar](1000) NULL,
	[dataInsRecord] [datetime] NOT NULL,
	[status] [varchar](20) NULL,
	[errorCode] [int] NULL,
	[HTTP_SHIBIDENTITYPROVIDER] [varchar](500) NULL,
	[HTTP_SHIBSESSIONINDEX] [varchar](250) NOT NULL,
	[HTTP_FISCALNUMBER] [varchar](50) NULL,
	[HTTP_SPIDCODE] [varchar](50) NULL,
	[AuthnRequest] [varchar](max) NULL,
	[Response] [varchar](max) NULL,
	[AuthnReq_ID] [varchar](50) NULL,
	[AuthnReq_IssueInstant] [varchar](50) NULL,
	[Resp_ID] [varchar](50) NULL,
	[Resp_IssueInstant] [varchar](50) NULL,
	[Resp_Issuer] [varchar](1000) NULL,
	[Assertion_ID] [varchar](50) NULL,
	[Assertion_subject] [varchar](1000) NULL,
	[Assertion_subject_NameQualifier] [varchar](1000) NULL,
	[aflinkFixation] [varchar](100) NULL,
	[IssueInstant] [varchar](30) NULL,
	[IDP] [varchar](500) NULL,
	[LOA] [varchar](500) NULL,
	[Canale] [varchar](500) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_LOG_SPID] ADD  CONSTRAINT [DF_Table_1_data_1]  DEFAULT (getdate()) FOR [dataInsRecord]
GO
