USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Com_DPE_Plant]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Com_DPE_Plant](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idCom] [int] NULL,
	[Plant] [varchar](100) NULL,
	[StatoComDir] [varchar](50) NULL,
	[DataAccettazioneDir] [datetime] NULL,
	[PLANTGrid_ID_DOC] [int] NULL,
	[InviataMail] [char](1) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Com_DPE_Plant] ADD  CONSTRAINT [DF_Document_Com_DPE_Plant_StatoComDir]  DEFAULT ('Da Confermare') FOR [StatoComDir]
GO
ALTER TABLE [dbo].[Document_Com_DPE_Plant] ADD  CONSTRAINT [DF_Document_Com_DPE_Plant_PLANTGrid_ID_DOC]  DEFAULT (0) FOR [PLANTGrid_ID_DOC]
GO
ALTER TABLE [dbo].[Document_Com_DPE_Plant] ADD  CONSTRAINT [DF_Document_Com_DPE_Plant_InviataMail]  DEFAULT ('') FOR [InviataMail]
GO
