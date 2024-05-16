USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_ACCESS_BARRIER]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_ACCESS_BARRIER](
	[guid] [varchar](50) NOT NULL,
	[idpfu] [int] NULL,
	[sessionid] [varchar](4000) NULL,
	[data] [datetime] NOT NULL,
	[PKCE_code_challenge] [nvarchar](max) NULL,
	[PKCE_code_verifier] [nvarchar](max) NULL,
	[id_token] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_ACCESS_BARRIER] ADD  CONSTRAINT [DF_CTL_ACCESS_BARRIER_data]  DEFAULT (getdate()) FOR [data]
GO
