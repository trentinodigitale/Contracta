USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_Pec_Verify]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_Pec_Verify](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[eMail] [nvarchar](500) NULL,
	[isPEC] [tinyint] NULL,
	[DataIns] [datetime] NULL,
	[DataUpd] [datetime] NULL,
	[Status] [varchar](50) NULL,
	[eMailMittente] [nvarchar](500) NULL,
	[gestore_Emittente] [nvarchar](500) NULL,
	[DataMail] [datetime] NULL,
	[XMLAttach] [nvarchar](3000) NULL,
	[NumSentRetry] [int] NULL,
	[idpfu] [int] NULL,
	[idazi] [int] NULL,
	[tipodoc] [varchar](200) NULL,
	[DataSentNotify] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_Pec_Verify] ADD  CONSTRAINT [DF_CTL_Mail_Pec_isPEC]  DEFAULT (0) FOR [isPEC]
GO
ALTER TABLE [dbo].[CTL_Pec_Verify] ADD  DEFAULT ((0)) FOR [NumSentRetry]
GO
