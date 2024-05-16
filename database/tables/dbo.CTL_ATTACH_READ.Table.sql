USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_ATTACH_READ]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_ATTACH_READ](
	[ATR_IdRow] [int] IDENTITY(1,1) NOT NULL,
	[ATR_Hash] [nvarchar](250) NULL,
	[ATR_IdPfu] [int] NULL,
	[ATR_DataInsert] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_ATTACH_READ] ADD  CONSTRAINT [DF_CTL_ATTACH_READ_ATR_DataInsert]  DEFAULT (getdate()) FOR [ATR_DataInsert]
GO
