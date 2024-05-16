USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Aziende_RTI]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Aziende_RTI](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idDoc] [int] NULL,
	[idAziPartecipante] [int] NULL,
	[Ruolo_Impresa] [varchar](50) NULL,
	[DataInizio] [datetime] NULL,
	[DataFine] [datetime] NULL,
	[PIVA_CF] [nvarchar](50) NULL,
	[DataCreazione] [datetime] NULL,
	[isOld] [int] NULL,
	[idAziRTI] [int] NULL,
 CONSTRAINT [PK_Document_Aziende_RTI] PRIMARY KEY CLUSTERED 
(
	[idRow] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Aziende_RTI] ADD  CONSTRAINT [DF_Document_Aziende_RTI_DataCreazione]  DEFAULT (getdate()) FOR [DataCreazione]
GO
ALTER TABLE [dbo].[Document_Aziende_RTI] ADD  CONSTRAINT [DF_Document_Aziende_RTI_isOld]  DEFAULT (0) FOR [isOld]
GO
