USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Aziende_DirTec]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Aziende_DirTec](
	[idrow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[NomeDirTec] [varchar](2550) NULL,
	[CognomeDirTec] [varchar](255) NULL,
	[TelefonoDirTec] [varchar](20) NULL,
	[EmailDirTec] [varchar](50) NULL,
	[RuoloDirTec] [varchar](50) NULL,
	[LocalitaDirTec] [varchar](30) NULL,
	[ProvinciaDirTec] [varchar](30) NULL,
	[DataDirTec] [datetime] NULL,
	[CellulareDirTec] [varchar](20) NULL,
	[CFDirTec] [varchar](40) NULL,
	[isOld] [int] NULL,
	[idAziDirTec] [int] NULL,
	[ResidenzaDirTec] [varchar](70) NULL,
 CONSTRAINT [PK_Document_Aziende_DirTec] PRIMARY KEY CLUSTERED 
(
	[idrow] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Aziende_DirTec] ADD  CONSTRAINT [DF_Document_Aziende_DirTec_isOld]  DEFAULT (0) FOR [isOld]
GO
