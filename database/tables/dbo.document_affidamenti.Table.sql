USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[document_affidamenti]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[document_affidamenti](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[protocollobando] [varchar](50) NULL,
	[ReceivedDataMsg] [datetime] NOT NULL,
	[iddestinatario] [int] NULL,
	[idmittente] [int] NULL,
	[idaziendamittente] [int] NOT NULL,
	[valoreofferta] [float] NOT NULL,
	[IdMsgSource] [int] NULL
) ON [PRIMARY]
GO
