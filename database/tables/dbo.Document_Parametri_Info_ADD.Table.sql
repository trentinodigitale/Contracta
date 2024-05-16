USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Parametri_Info_ADD]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Parametri_Info_ADD](
	[idrow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NOT NULL,
	[deleted] [int] NULL,
	[modalitaDiScelta] [int] NULL,
	[livelloBloccato] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Parametri_Info_ADD] ADD  CONSTRAINT [DF__Document___delet__60F66677]  DEFAULT ((0)) FOR [deleted]
GO
