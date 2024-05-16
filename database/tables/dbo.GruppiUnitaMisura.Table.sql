USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[GruppiUnitaMisura]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GruppiUnitaMisura](
	[IdGum] [int] IDENTITY(1,1) NOT NULL,
	[gumIdDscNome] [int] NOT NULL,
	[gumIdUmsNorm] [int] NULL,
	[gumUltimaMod] [datetime] NOT NULL,
	[gumDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_GruppiUnitaMisura] PRIMARY KEY NONCLUSTERED 
(
	[IdGum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GruppiUnitaMisura] ADD  CONSTRAINT [DF_GruppiUnitaMisura_gumUltimaMod]  DEFAULT (getdate()) FOR [gumUltimaMod]
GO
ALTER TABLE [dbo].[GruppiUnitaMisura] ADD  CONSTRAINT [DF_GruppiUnitaMisura_gumDeleted]  DEFAULT (0) FOR [gumDeleted]
GO
ALTER TABLE [dbo].[GruppiUnitaMisura]  WITH CHECK ADD  CONSTRAINT [FK_GruppiUnitaMisura_DescsI] FOREIGN KEY([gumIdDscNome])
REFERENCES [dbo].[DescsI] ([IdDsc])
GO
ALTER TABLE [dbo].[GruppiUnitaMisura] CHECK CONSTRAINT [FK_GruppiUnitaMisura_DescsI]
GO
