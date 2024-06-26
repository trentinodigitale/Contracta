USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MPCampiReg]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MPCampiReg](
	[IdMpcr] [int] IDENTITY(1,1) NOT NULL,
	[mpcrIdMp] [int] NOT NULL,
	[mpcrCampo] [varchar](50) NOT NULL,
	[mpcrObbl] [bit] NOT NULL,
	[mpcrLungh] [smallint] NOT NULL,
	[mpcrTipo] [varchar](20) NOT NULL,
	[mpcrTipoHtml] [varchar](20) NOT NULL,
	[mpcrPos] [smallint] NOT NULL,
	[mpcrNomeColonna] [varchar](50) NULL,
	[mpcrShadow] [bit] NOT NULL,
	[mpcrOrder] [smallint] NOT NULL,
	[mpcrLunghMin] [smallint] NULL,
	[regExp] [varchar](500) NULL,
 CONSTRAINT [PK_MPCampiReg] PRIMARY KEY NONCLUSTERED 
(
	[IdMpcr] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MPCampiReg] ADD  CONSTRAINT [DF_MPCampiReg_mpcrObbl]  DEFAULT (0) FOR [mpcrObbl]
GO
ALTER TABLE [dbo].[MPCampiReg] ADD  CONSTRAINT [DF_MPCampiReg_mpcrShadow]  DEFAULT (0) FOR [mpcrShadow]
GO
ALTER TABLE [dbo].[MPCampiReg]  WITH CHECK ADD  CONSTRAINT [FK_MPCampiReg_MarketPlace] FOREIGN KEY([mpcrIdMp])
REFERENCES [dbo].[MarketPlace] ([IdMp])
GO
ALTER TABLE [dbo].[MPCampiReg] CHECK CONSTRAINT [FK_MPCampiReg_MarketPlace]
GO
