USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[v_protgen_fascicoli]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[v_protgen_fascicoli](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[data] [datetime] NOT NULL,
	[dataAssegnazione] [datetime] NULL,
	[deleted] [int] NOT NULL,
	[fascicoloOrigine] [varchar](500) NULL,
	[fascicoloNuovo] [varchar](500) NULL,
	[idDoc] [int] NULL,
	[tipoDoc] [varchar](500) NULL,
	[errore] [nvarchar](max) NULL,
	[descFascicolo] [varchar](500) NULL,
	[aoo] [varchar](200) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[v_protgen_fascicoli] ADD  CONSTRAINT [DF_v_protgen_fascicoli_data]  DEFAULT (getdate()) FOR [data]
GO
ALTER TABLE [dbo].[v_protgen_fascicoli] ADD  CONSTRAINT [DF_v_protgen_fascicoli_deleted]  DEFAULT ((0)) FOR [deleted]
GO
