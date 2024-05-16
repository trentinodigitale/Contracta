USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[ModPesiRatingForn]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ModPesiRatingForn](
	[IdMprf] [int] NOT NULL,
	[mprfIdPfu] [int] NOT NULL,
	[mprfDesc] [char](30) NOT NULL,
	[mprfValid] [tinyint] NOT NULL,
	[mprfDI] [datetime] NOT NULL,
	[mprfDF] [datetime] NOT NULL,
 CONSTRAINT [PK_ModPesiRatingForn] PRIMARY KEY NONCLUSTERED 
(
	[IdMprf] ASC,
	[mprfIdPfu] ASC,
	[mprfDI] ASC,
	[mprfDF] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ModPesiRatingForn] ADD  CONSTRAINT [DF_ModPesiRatingForn_mprfDI]  DEFAULT (getdate()) FOR [mprfDI]
GO
ALTER TABLE [dbo].[ModPesiRatingForn] ADD  CONSTRAINT [DF_ModPesiRatingForn_mprfDF]  DEFAULT ('99991231') FOR [mprfDF]
GO
