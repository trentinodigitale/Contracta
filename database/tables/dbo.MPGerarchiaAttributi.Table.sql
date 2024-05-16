USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MPGerarchiaAttributi]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MPGerarchiaAttributi](
	[IdMpGa] [int] IDENTITY(1,1) NOT NULL,
	[mpgaIdMp] [int] NOT NULL,
	[mpgaContesto] [varchar](50) NOT NULL,
	[mpgaDescr] [char](101) NULL,
	[mpgaIdDzt] [int] NOT NULL,
	[mpgaPath] [varchar](100) NOT NULL,
	[mpgaLivello] [smallint] NOT NULL,
	[mpgaFoglia] [bit] NOT NULL,
	[mpgaLenPathPadre] [smallint] NOT NULL,
	[mpgaDeleted] [bit] NOT NULL,
	[mpgaUltimaMod] [datetime] NOT NULL,
	[mpgaProfili] [varchar](20) NULL,
	[mpgaMultiSel] [bit] NOT NULL,
 CONSTRAINT [PK_MPGerarchiaAttributi] PRIMARY KEY NONCLUSTERED 
(
	[IdMpGa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MPGerarchiaAttributi] ADD  CONSTRAINT [DF_MPGerarchiaAttributi_mpgaIdMp]  DEFAULT (0) FOR [mpgaIdMp]
GO
ALTER TABLE [dbo].[MPGerarchiaAttributi] ADD  CONSTRAINT [DF_MPGerarchiaAttributi_mpgaIdDzt]  DEFAULT ((-1)) FOR [mpgaIdDzt]
GO
ALTER TABLE [dbo].[MPGerarchiaAttributi] ADD  CONSTRAINT [DF_MPGerarchiaAttributi_mpgaFoglia]  DEFAULT (0) FOR [mpgaFoglia]
GO
ALTER TABLE [dbo].[MPGerarchiaAttributi] ADD  CONSTRAINT [DF_MPGerarchiaAttributi_mpgaDeleted]  DEFAULT (0) FOR [mpgaDeleted]
GO
ALTER TABLE [dbo].[MPGerarchiaAttributi] ADD  CONSTRAINT [DF_MPGerarchiaAttributi_mpgaUltimaMod]  DEFAULT (getdate()) FOR [mpgaUltimaMod]
GO
ALTER TABLE [dbo].[MPGerarchiaAttributi] ADD  CONSTRAINT [DF_MPGerarchiaAttributi_mpgaMultiSel]  DEFAULT (1) FOR [mpgaMultiSel]
GO
