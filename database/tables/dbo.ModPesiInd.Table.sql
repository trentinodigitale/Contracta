USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[ModPesiInd]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ModPesiInd](
	[IdMprf] [int] NOT NULL,
	[mpiIdPfu] [int] NOT NULL,
	[mpiIdInd] [int] NOT NULL,
	[mpiPeso] [int] NOT NULL,
	[mpiDI] [datetime] NOT NULL,
	[mpiDF] [datetime] NOT NULL,
 CONSTRAINT [PK_ModPesiInd] PRIMARY KEY NONCLUSTERED 
(
	[IdMprf] ASC,
	[mpiIdPfu] ASC,
	[mpiIdInd] ASC,
	[mpiDI] ASC,
	[mpiDF] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ModPesiInd] ADD  CONSTRAINT [DF_ModPesiInd_mpiDI]  DEFAULT (getdate()) FOR [mpiDI]
GO
ALTER TABLE [dbo].[ModPesiInd] ADD  CONSTRAINT [DF_ModPesiInd_mpiDF]  DEFAULT ('99991231') FOR [mpiDF]
GO
