USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TempElabCatalogo]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempElabCatalogo](
	[IdTmp] [int] IDENTITY(1,1) NOT NULL,
	[Codice] [nvarchar](30) NULL,
	[ClassificazioneSP] [char](10) NULL,
	[DescrizioneI] [nvarchar](300) NULL,
	[DescrizioneUK] [nvarchar](300) NULL,
	[DescrizioneE] [nvarchar](300) NULL,
	[DescrizioneFRA] [nvarchar](300) NULL,
	[UnitaMisura] [nvarchar](200) NULL,
	[WebArticolo] [nvarchar](600) NULL,
	[QMO] [int] NULL,
	[IdDsc] [int] NULL,
	[IdUms] [int] NULL,
	[CspValue] [int] NULL,
 CONSTRAINT [PK_TempElabCatalogo] PRIMARY KEY NONCLUSTERED 
(
	[IdTmp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
