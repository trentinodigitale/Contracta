USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[DocumentSend]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocumentSend](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Type] [smallint] NOT NULL,
	[SubType] [smallint] NOT NULL,
	[KeyEntity] [varchar](50) NOT NULL,
	[SediDest] [char](255) NOT NULL,
	[IdPfuMitt] [int] NOT NULL,
	[IdAziDest] [int] NOT NULL,
	[EsitoMail] [smallint] NOT NULL,
	[EsitoFax] [smallint] NOT NULL,
	[Stato] [smallint] NOT NULL,
	[DescrErrorMail] [varchar](255) NOT NULL,
	[DescrErrorFax] [varchar](255) NOT NULL,
	[Note] [varchar](255) NOT NULL,
	[DataIns] [datetime] NOT NULL,
	[Canale] [tinyint] NOT NULL,
	[Address] [varchar](255) NULL,
	[NumRetry] [int] NULL,
	[email] [varchar](255) NULL,
	[FAX] [varchar](255) NULL,
	[URL] [varchar](2000) NULL,
	[Formato] [varchar](50) NULL,
	[Oggetto] [varchar](500) NULL,
	[NomeAllegato] [varchar](500) NULL,
	[Body] [varchar](8000) NULL,
	[MailFROM] [varchar](255) NULL,
 CONSTRAINT [PK_DocumentSend] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DocumentSend] ADD  CONSTRAINT [DF__DocumentS__IdPfu__37E3A2C1]  DEFAULT (0) FOR [IdPfuMitt]
GO
ALTER TABLE [dbo].[DocumentSend] ADD  CONSTRAINT [DF__DocumentS__Esito__38D7C6FA]  DEFAULT ((-1)) FOR [EsitoMail]
GO
ALTER TABLE [dbo].[DocumentSend] ADD  CONSTRAINT [DF__DocumentS__Esito__39CBEB33]  DEFAULT ((-1)) FOR [EsitoFax]
GO
ALTER TABLE [dbo].[DocumentSend] ADD  CONSTRAINT [DF__DocumentS__Stato__3AC00F6C]  DEFAULT (1) FOR [Stato]
GO
ALTER TABLE [dbo].[DocumentSend] ADD  CONSTRAINT [DF__DocumentS__DataI__3BB433A5]  DEFAULT (getdate()) FOR [DataIns]
GO
ALTER TABLE [dbo].[DocumentSend] ADD  CONSTRAINT [DF__DocumentS__Canal__3CA857DE]  DEFAULT (0) FOR [Canale]
GO
ALTER TABLE [dbo].[DocumentSend] ADD  CONSTRAINT [DF__DocumentS__NumRe__3D9C7C17]  DEFAULT (0) FOR [NumRetry]
GO
