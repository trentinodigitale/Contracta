USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_INIPEC]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_INIPEC](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[idAzi] [int] NULL,
	[codiceFiscale] [varchar](50) NULL,
	[eMailPec] [varchar](319) NULL,
	[dataInserimento] [datetime] NULL,
	[dataUltimoControllo] [datetime] NULL,
	[statoInipec] [varchar](20) NULL,
	[idRichiestaINIPEC] [varchar](50) NULL,
	[descrizioneEsitoInipec] [nvarchar](max) NULL,
	[IdCom] [int] NULL,
	[IsCambiato] [bit] NULL,
	[DataCambiamento] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_INIPEC] ADD  CONSTRAINT [DF_Document_INIPEC_idHeader]  DEFAULT ((0)) FOR [idHeader]
GO
