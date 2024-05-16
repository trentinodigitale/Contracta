USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_ControlliGara]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_ControlliGara](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[DataCreazione] [datetime] NULL,
	[ID_MSG_PDA] [int] NULL,
	[ID_MSG_BANDO] [int] NULL,
	[StatoEsclusione] [varchar](20) NULL,
	[Oggetto] [ntext] NULL,
	[DataAperturaOfferte] [datetime] NULL,
	[DataIISeduta] [datetime] NULL,
	[Segretario] [nvarchar](50) NULL,
	[Protocol] [varchar](50) NULL,
	[idAggiudicatrice] [int] NULL,
	[importoBaseAsta] [float] NULL,
	[NRDeterminazione] [varchar](50) NULL,
	[DataDetermina] [datetime] NULL,
	[ValutazioneEconomica] [float] NULL,
	[Responsabile] [nvarchar](50) NULL,
	[ResponsabileContratto] [nvarchar](50) NULL,
	[StatoGara] [varchar](20) NULL,
 CONSTRAINT [PK_Document_ControlliGara] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_ControlliGara] ADD  CONSTRAINT [DF__Document___DataC__4C495F36]  DEFAULT (getdate()) FOR [DataCreazione]
GO
ALTER TABLE [dbo].[Document_ControlliGara] ADD  CONSTRAINT [DF__Document___Stato__4D3D836F]  DEFAULT ('Saved') FOR [StatoEsclusione]
GO
