USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_Profiler]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_Profiler](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Pagina] [nvarchar](500) NULL,
	[DataEsecuzione] [datetime] NULL,
	[Timer] [int] NULL,
	[Url] [nvarchar](max) NULL,
	[IDDOC] [varchar](50) NULL,
	[TIPODOC] [varchar](500) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_Profiler] ADD  CONSTRAINT [DF_Table_1_Data]  DEFAULT (getdate()) FOR [DataEsecuzione]
GO
