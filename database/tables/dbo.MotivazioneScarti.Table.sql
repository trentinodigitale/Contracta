USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MotivazioneScarti]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MotivazioneScarti](
	[IdMts] [int] IDENTITY(1,1) NOT NULL,
	[MtsIdDsc] [int] NOT NULL,
	[MtsUltimaMod] [datetime] NOT NULL,
	[MtsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_MotivazioneScarti] PRIMARY KEY NONCLUSTERED 
(
	[IdMts] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MotivazioneScarti] ADD  CONSTRAINT [DF_MotivazioneScarti_MtsUltimaMod]  DEFAULT (getdate()) FOR [MtsUltimaMod]
GO
ALTER TABLE [dbo].[MotivazioneScarti] ADD  CONSTRAINT [DF_MotivazioneScarti_MtsDeleted]  DEFAULT (0) FOR [MtsDeleted]
GO
ALTER TABLE [dbo].[MotivazioneScarti]  WITH CHECK ADD  CONSTRAINT [FK_MotivazioneScarti_DescsI] FOREIGN KEY([MtsIdDsc])
REFERENCES [dbo].[DescsI] ([IdDsc])
GO
ALTER TABLE [dbo].[MotivazioneScarti] CHECK CONSTRAINT [FK_MotivazioneScarti_DescsI]
GO
