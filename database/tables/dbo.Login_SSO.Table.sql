USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Login_SSO]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Login_SSO](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[chiave] [varchar](500) NULL,
	[valore] [nvarchar](4000) NULL,
	[data] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Login_SSO] ADD  CONSTRAINT [DF_Login_SSO_data]  DEFAULT (getdate()) FOR [data]
GO
