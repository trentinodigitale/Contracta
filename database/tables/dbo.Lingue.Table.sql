USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Lingue]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lingue](
	[IdLng] [int] IDENTITY(1,1) NOT NULL,
	[lngIdDsc] [int] NOT NULL,
	[lngSuffisso] [varchar](5) NOT NULL,
	[lngUltimaMod] [datetime] NOT NULL,
	[lngDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_Lingua] PRIMARY KEY NONCLUSTERED 
(
	[IdLng] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Lingue] ADD  CONSTRAINT [DF_Lingue_lngUltimaModifica]  DEFAULT (getdate()) FOR [lngUltimaMod]
GO
ALTER TABLE [dbo].[Lingue] ADD  CONSTRAINT [DF_Lingue_lngDeleted]  DEFAULT (0) FOR [lngDeleted]
GO
ALTER TABLE [dbo].[Lingue]  WITH CHECK ADD  CONSTRAINT [FK_Lingue_DescsI] FOREIGN KEY([lngIdDsc])
REFERENCES [dbo].[DescsI] ([IdDsc])
GO
ALTER TABLE [dbo].[Lingue] CHECK CONSTRAINT [FK_Lingue_DescsI]
GO
