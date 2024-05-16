USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TypesDocumentSend]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TypesDocumentSend](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Type] [smallint] NOT NULL,
	[SubType] [smallint] NOT NULL,
	[CodiceRaccordo] [varchar](10) NOT NULL,
	[Descrizione] [varchar](255) NULL,
	[SendMail] [smallint] NOT NULL,
	[SendFax] [smallint] NOT NULL,
	[TypeMail] [smallint] NOT NULL,
	[TypeFax] [smallint] NOT NULL,
 CONSTRAINT [PK_TypesDocumentSend] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TypesDocumentSend] ADD  CONSTRAINT [DF__TypesDocu__TypeM__322AC96B]  DEFAULT (0) FOR [TypeMail]
GO
ALTER TABLE [dbo].[TypesDocumentSend] ADD  CONSTRAINT [DF__TypesDocu__TypeF__331EEDA4]  DEFAULT (0) FOR [TypeFax]
GO
