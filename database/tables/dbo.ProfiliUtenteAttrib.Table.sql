USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[ProfiliUtenteAttrib]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProfiliUtenteAttrib](
	[IdUsAttr] [int] IDENTITY(1,1) NOT NULL,
	[IdPfu] [int] NOT NULL,
	[dztNome] [varchar](50) NOT NULL,
	[attValue] [varchar](255) NOT NULL,
	[DataUltimaMod] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProfiliUtenteAttrib] ADD  DEFAULT (getdate()) FOR [DataUltimaMod]
GO
