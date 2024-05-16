USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_CommissionePda_Credenziali]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_CommissionePda_Credenziali](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[IdHeader] [int] NOT NULL,
	[UtenteCommissione] [int] NOT NULL,
	[RuoloCommissione] [nvarchar](200) NOT NULL,
	[Login] [nvarchar](200) NULL,
	[Pwd] [nvarchar](200) NULL
) ON [PRIMARY]
GO
