USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[FormRegistrazione]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FormRegistrazione](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[sessionid] [varchar](250) NULL,
	[codice_fiscale] [varchar](250) NULL,
	[nome_campo] [varchar](150) NULL,
	[valore] [nvarchar](4000) NULL,
	[data] [datetime] NULL,
	[sessionidasp] [varchar](4000) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FormRegistrazione] ADD  CONSTRAINT [DF_FormRegistrazione_data]  DEFAULT (getdate()) FOR [data]
GO
