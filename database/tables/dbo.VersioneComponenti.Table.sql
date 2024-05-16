USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[VersioneComponenti]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VersioneComponenti](
	[vcSO] [nvarchar](50) NOT NULL,
	[vcObject] [nvarchar](50) NOT NULL,
	[vcVersion] [smallint] NOT NULL,
	[vcStato] [smallint] NOT NULL,
	[vcSito] [nvarchar](300) NOT NULL,
	[vcDescr] [nvarchar](50) NULL,
	[IdVc] [int] IDENTITY(1,1) NOT NULL,
	[vcUltimaMod] [datetime] NOT NULL,
	[vcDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_VersioneComponenti] PRIMARY KEY CLUSTERED 
(
	[IdVc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VersioneComponenti] ADD  CONSTRAINT [DF_VersioneComponenti_vcUltimaMod]  DEFAULT (getdate()) FOR [vcUltimaMod]
GO
ALTER TABLE [dbo].[VersioneComponenti] ADD  CONSTRAINT [DF_VersioneComponenti_vcDeleted]  DEFAULT (0) FOR [vcDeleted]
GO
