USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Com_DPE_Fornitori]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Com_DPE_Fornitori](
	[IdComFor] [int] IDENTITY(1,1) NOT NULL,
	[IdCom] [int] NULL,
	[IdAzi] [int] NULL,
	[CodiceFornitore] [varchar](10) NULL,
	[StatoComFor] [varchar](50) NULL,
	[Accetta] [varchar](1) NULL,
	[DataAccettazione] [datetime] NULL,
	[Rimanda] [varchar](1) NULL,
	[aziragionesociale] [nvarchar](1000) NULL,
	[Indirizzo] [nvarchar](1000) NULL,
	[Allegato] [varchar](255) NULL,
	[codicefiscale] [varchar](255) NULL,
	[FORNITORIGrid_ID_DOC] [int] NULL,
	[InviataMail] [char](1) NULL,
	[DataProtocolloGenerale] [datetime] NULL,
	[ProtocolloGenerale] [varchar](50) NULL,
 CONSTRAINT [PK_Document_Com_DPE_Fornitori] PRIMARY KEY CLUSTERED 
(
	[IdComFor] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 85, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Com_DPE_Fornitori] ADD  CONSTRAINT [DF_Document_Com_DPE_Fornitori_StatoComFor]  DEFAULT ('Da Confermare') FOR [StatoComFor]
GO
ALTER TABLE [dbo].[Document_Com_DPE_Fornitori] ADD  CONSTRAINT [DF_Document_Com_DPE_DataAccettazione]  DEFAULT (NULL) FOR [DataAccettazione]
GO
ALTER TABLE [dbo].[Document_Com_DPE_Fornitori] ADD  CONSTRAINT [DF_Document_Com_DPE_Fornitori_FORNITORIGrid_ID_DOC]  DEFAULT ((0)) FOR [FORNITORIGrid_ID_DOC]
GO
ALTER TABLE [dbo].[Document_Com_DPE_Fornitori] ADD  CONSTRAINT [DF_Document_Com_DPE_Fornitori_InviataMail]  DEFAULT ('') FOR [InviataMail]
GO
