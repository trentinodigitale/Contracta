USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[ModelliGruppi]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ModelliGruppi](
	[IdMgr] [int] IDENTITY(1,1) NOT NULL,
	[mgrIdMdl] [int] NOT NULL,
	[mgrNome] [nvarchar](20) NOT NULL,
	[mgrPosizione] [tinyint] NOT NULL,
 CONSTRAINT [PK_ModelliGruppi] PRIMARY KEY NONCLUSTERED 
(
	[IdMgr] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ModelliGruppi] ADD  CONSTRAINT [DF_ModelliGruppi_mgrPosizione]  DEFAULT (0) FOR [mgrPosizione]
GO
ALTER TABLE [dbo].[ModelliGruppi]  WITH CHECK ADD  CONSTRAINT [FK_ModelliGruppi_Modelli] FOREIGN KEY([mgrIdMdl])
REFERENCES [dbo].[Modelli] ([IdMdl])
GO
ALTER TABLE [dbo].[ModelliGruppi] CHECK CONSTRAINT [FK_ModelliGruppi_Modelli]
GO
