USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_Attivita]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_Attivita](
	[ATV_ID] [int] IDENTITY(1,1) NOT NULL,
	[ATV_Object] [nvarchar](4000) NULL,
	[ATV_DateInsert] [datetime] NOT NULL,
	[ATV_ExpiryDate] [datetime] NULL,
	[ATV_Obbligatory] [char](2) NULL,
	[ATV_Execute] [char](2) NOT NULL,
	[ATV_Url] [varchar](500) NULL,
	[ATV_DocumentName] [varchar](100) NULL,
	[ATV_IdDoc] [int] NOT NULL,
	[ATV_IdAzi] [int] NULL,
	[ATV_IdPfu] [int] NULL,
	[ATV_Allegato] [varchar](500) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_Attivita] ADD  CONSTRAINT [DF_CTL_Attivita_ATV_DateInsert]  DEFAULT (getdate()) FOR [ATV_DateInsert]
GO
ALTER TABLE [dbo].[CTL_Attivita] ADD  CONSTRAINT [DF_CTL_Attivita_ATV_Execute]  DEFAULT ('no') FOR [ATV_Execute]
GO
