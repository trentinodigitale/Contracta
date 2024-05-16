USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[v_protgen_dati]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[v_protgen_dati](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[IdHeader] [int] NULL,
	[DZT_Name] [varchar](200) NULL,
	[Value] [varchar](max) NULL,
	[data] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[v_protgen_dati] ADD  CONSTRAINT [DF_v_protgen_dati_data]  DEFAULT (getdate()) FOR [data]
GO
