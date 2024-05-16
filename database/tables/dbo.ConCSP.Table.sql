USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[ConCSP]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConCSP](
	[Conta] [int] NULL,
	[ConCspCode] [varchar](25) NULL,
	[UltimaModifica] [datetime] NULL,
	[ConIdMP] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ConCSP] ADD  CONSTRAINT [DF__ConCSP__UltimaMo__025E20EC]  DEFAULT (getdate()) FOR [UltimaModifica]
GO
