USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Report_Periodi]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Report_Periodi](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[TipoAnalisi] [varchar](20) NULL,
	[Descrizione] [nvarchar](100) NULL,
	[DataI] [datetime] NULL,
	[DataF] [datetime] NULL,
	[DataI2] [datetime] NULL,
	[DataF2] [datetime] NULL,
	[deleted] [int] NULL,
	[Used] [int] NULL,
	[Importo] [float] NULL,
 CONSTRAINT [PK_Document_Report_Periodi] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Report_Periodi] ADD  CONSTRAINT [DF_Document_Report_Periodi_deleted]  DEFAULT (0) FOR [deleted]
GO
ALTER TABLE [dbo].[Document_Report_Periodi] ADD  CONSTRAINT [DF_Document_Report_Periodi_Used]  DEFAULT (1) FOR [Used]
GO
