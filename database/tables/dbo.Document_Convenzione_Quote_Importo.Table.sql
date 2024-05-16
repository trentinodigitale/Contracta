USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Convenzione_Quote_Importo]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Convenzione_Quote_Importo](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NOT NULL,
	[Azienda] [nvarchar](20) NULL,
	[ImportoQuota] [float] NULL,
	[ImportoSpesa] [float] NULL
) ON [PRIMARY]
GO
