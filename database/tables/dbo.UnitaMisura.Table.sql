USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[UnitaMisura]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UnitaMisura](
	[IdUms] [int] IDENTITY(1,1) NOT NULL,
	[umsIdGum] [int] NOT NULL,
	[umsIdDscNome] [int] NOT NULL,
	[umsIdDscSimbolo] [int] NOT NULL,
	[umsRapNorm] [float] NOT NULL,
	[umsUltimaMod] [datetime] NOT NULL,
	[umsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_UnitaMisura] PRIMARY KEY NONCLUSTERED 
(
	[IdUms] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UnitaMisura] ADD  CONSTRAINT [DF_UnitaMisura_umsRapNorm]  DEFAULT (1) FOR [umsRapNorm]
GO
ALTER TABLE [dbo].[UnitaMisura] ADD  CONSTRAINT [DF_UnitaMisura_umsUltimaMod]  DEFAULT (getdate()) FOR [umsUltimaMod]
GO
ALTER TABLE [dbo].[UnitaMisura] ADD  CONSTRAINT [DF_UnitaMisura_umsDeleted]  DEFAULT (0) FOR [umsDeleted]
GO
ALTER TABLE [dbo].[UnitaMisura]  WITH CHECK ADD  CONSTRAINT [FK_UnitaMisura_DescsI] FOREIGN KEY([umsIdDscNome])
REFERENCES [dbo].[DescsI] ([IdDsc])
GO
ALTER TABLE [dbo].[UnitaMisura] CHECK CONSTRAINT [FK_UnitaMisura_DescsI]
GO
ALTER TABLE [dbo].[UnitaMisura]  WITH CHECK ADD  CONSTRAINT [FK_UnitaMisura_DescsI1] FOREIGN KEY([umsIdDscSimbolo])
REFERENCES [dbo].[DescsI] ([IdDsc])
GO
ALTER TABLE [dbo].[UnitaMisura] CHECK CONSTRAINT [FK_UnitaMisura_DescsI1]
GO
ALTER TABLE [dbo].[UnitaMisura]  WITH CHECK ADD  CONSTRAINT [FK_UnitaMisura_GruppiUnitaMisura] FOREIGN KEY([umsIdGum])
REFERENCES [dbo].[GruppiUnitaMisura] ([IdGum])
GO
ALTER TABLE [dbo].[UnitaMisura] CHECK CONSTRAINT [FK_UnitaMisura_GruppiUnitaMisura]
GO
