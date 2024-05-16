USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Appartenenze]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Appartenenze](
	[IdApp] [int] NOT NULL,
	[appIdDsc] [int] NOT NULL,
	[appDeleted] [bit] NOT NULL,
 CONSTRAINT [PK__Appartenenze__6498B3DB] PRIMARY KEY CLUSTERED 
(
	[IdApp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Appartenenze] ADD  CONSTRAINT [DF_Appartenenze_appDeleted]  DEFAULT (0) FOR [appDeleted]
GO
ALTER TABLE [dbo].[Appartenenze]  WITH CHECK ADD  CONSTRAINT [FK__Appartene__appId__67752086] FOREIGN KEY([appIdDsc])
REFERENCES [dbo].[DescsI] ([IdDsc])
GO
ALTER TABLE [dbo].[Appartenenze] CHECK CONSTRAINT [FK__Appartene__appId__67752086]
GO
