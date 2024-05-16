USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Temp_PDA]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Temp_PDA](
	[pdaIdMsg] [int] NOT NULL,
	[pdaStatus] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Temp_PDA] ADD  CONSTRAINT [DF__Temp_PDA__pdaSta__0B5DDED5]  DEFAULT ((-1)) FOR [pdaStatus]
GO
