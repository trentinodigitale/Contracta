USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Esito_Qualificazione]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Esito_Qualificazione](
	[IdCom] [int] IDENTITY(1,1) NOT NULL,
	[Owner] [int] NULL,
	[Name] [varchar](50) NULL,
	[IdAzienda] [int] NULL,
	[DataCreazione] [datetime] NULL,
	[Protocollo] [varchar](50) NULL,
	[StatoCom] [varchar](50) NULL,
	[Obbligo] [varchar](1) NULL,
	[DataObbligo] [datetime] NULL,
	[BloccoAccesso] [varchar](1) NULL,
	[DataScadenzaCom] [datetime] NULL,
	[TipologiaAllegati] [varchar](50) NULL,
	[Note] [ntext] NULL,
	[TipoComunicazione] [varchar](50) NULL,
	[Deleted] [bit] NULL,
	[idrow] [int] NULL,
 CONSTRAINT [PK_Document_Esito1] PRIMARY KEY CLUSTERED 
(
	[IdCom] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 97, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Esito_Qualificazione] ADD  CONSTRAINT [DF_Document_Esito_Data]  DEFAULT (getdate()) FOR [DataCreazione]
GO
ALTER TABLE [dbo].[Document_Esito_Qualificazione] ADD  CONSTRAINT [DF_Document_Esito_StatoCom]  DEFAULT ('Salvato') FOR [StatoCom]
GO
ALTER TABLE [dbo].[Document_Esito_Qualificazione] ADD  CONSTRAINT [DF_Document_Esito_DataObbligo]  DEFAULT (getdate()+(90)) FOR [DataObbligo]
GO
ALTER TABLE [dbo].[Document_Esito_Qualificazione] ADD  CONSTRAINT [DF_Document_Esito_DataScadenza]  DEFAULT (getdate()) FOR [DataScadenzaCom]
GO
ALTER TABLE [dbo].[Document_Esito_Qualificazione] ADD  CONSTRAINT [DF1_Document_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
