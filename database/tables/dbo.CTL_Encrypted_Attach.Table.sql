USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_Encrypted_Attach]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_Encrypted_Attach](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[att_idRow] [int] NULL,
	[att_obj] [image] NULL,
	[data] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_Encrypted_Attach] ADD  DEFAULT (getdate()) FOR [data]
GO
