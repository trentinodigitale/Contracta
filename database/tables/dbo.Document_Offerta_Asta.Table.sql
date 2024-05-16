USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Offerta_Asta]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Offerta_Asta](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[Comodo] [float] NULL,
	[DataRilancio] [datetime] NULL
) ON [PRIMARY]
GO
