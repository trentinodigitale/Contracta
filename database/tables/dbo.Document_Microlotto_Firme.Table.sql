USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Microlotto_Firme]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Microlotto_Firme](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[F1_DESC] [varchar](50) NULL,
	[F1_SIGN_HASH] [varchar](255) NULL,
	[F1_SIGN_ATTACH] [nvarchar](255) NULL,
	[F1_SIGN_LOCK] [int] NULL,
	[F2_DESC] [varchar](50) NULL,
	[F2_SIGN_HASH] [varchar](255) NULL,
	[F2_SIGN_ATTACH] [nvarchar](255) NULL,
	[F2_SIGN_LOCK] [int] NULL,
	[F3_DESC] [varchar](50) NULL,
	[F3_SIGN_HASH] [varchar](255) NULL,
	[F3_SIGN_ATTACH] [nvarchar](255) NULL,
	[F3_SIGN_LOCK] [int] NULL,
	[F4_DESC] [varchar](50) NULL,
	[F4_SIGN_HASH] [varchar](255) NULL,
	[F4_SIGN_ATTACH] [nvarchar](255) NULL,
	[F4_SIGN_LOCK] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Microlotto_Firme] ADD  DEFAULT ('') FOR [F1_SIGN_HASH]
GO
ALTER TABLE [dbo].[Document_Microlotto_Firme] ADD  DEFAULT ('') FOR [F1_SIGN_ATTACH]
GO
ALTER TABLE [dbo].[Document_Microlotto_Firme] ADD  DEFAULT (0) FOR [F1_SIGN_LOCK]
GO
ALTER TABLE [dbo].[Document_Microlotto_Firme] ADD  DEFAULT ('') FOR [F2_SIGN_HASH]
GO
ALTER TABLE [dbo].[Document_Microlotto_Firme] ADD  DEFAULT ('') FOR [F2_SIGN_ATTACH]
GO
ALTER TABLE [dbo].[Document_Microlotto_Firme] ADD  DEFAULT (0) FOR [F2_SIGN_LOCK]
GO
ALTER TABLE [dbo].[Document_Microlotto_Firme] ADD  DEFAULT ('') FOR [F3_SIGN_HASH]
GO
ALTER TABLE [dbo].[Document_Microlotto_Firme] ADD  DEFAULT ('') FOR [F3_SIGN_ATTACH]
GO
ALTER TABLE [dbo].[Document_Microlotto_Firme] ADD  DEFAULT (0) FOR [F3_SIGN_LOCK]
GO
ALTER TABLE [dbo].[Document_Microlotto_Firme] ADD  DEFAULT ('') FOR [F4_SIGN_HASH]
GO
ALTER TABLE [dbo].[Document_Microlotto_Firme] ADD  DEFAULT ('') FOR [F4_SIGN_ATTACH]
GO
ALTER TABLE [dbo].[Document_Microlotto_Firme] ADD  DEFAULT (0) FOR [F4_SIGN_LOCK]
GO
