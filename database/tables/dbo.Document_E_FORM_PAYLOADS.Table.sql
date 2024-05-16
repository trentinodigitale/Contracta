USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_E_FORM_PAYLOADS]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_E_FORM_PAYLOADS](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NOT NULL,
	[operationDate] [datetime] NOT NULL,
	[operationType] [varchar](150) NULL,
	[idpfu] [int] NULL,
	[payload] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_E_FORM_PAYLOADS] ADD  CONSTRAINT [DF_Document_E_FORM_PAYLOADS_operationDate]  DEFAULT (getdate()) FOR [operationDate]
GO
