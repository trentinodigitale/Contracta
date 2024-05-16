USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[ConAziende]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConAziende](
	[Conta] [int] NULL,
	[AtvAtecord] [varchar](25) NULL,
	[UltimaModifica] [datetime] NULL,
	[ConIdMP] [int] NULL,
	[ConProfilo] [char](1) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ConAziende] ADD  CONSTRAINT [DF__ConAziend__Ultim__1EA62536]  DEFAULT (getdate()) FOR [UltimaModifica]
GO
