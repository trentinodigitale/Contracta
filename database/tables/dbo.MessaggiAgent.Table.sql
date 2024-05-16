USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MessaggiAgent]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MessaggiAgent](
	[maIdMsg] [int] NOT NULL,
	[maStato] [smallint] NOT NULL,
 CONSTRAINT [PK_MessaggiAgent] PRIMARY KEY NONCLUSTERED 
(
	[maIdMsg] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MessaggiAgent] ADD  CONSTRAINT [DF_MessaggiAgent_maStato]  DEFAULT ((-1)) FOR [maStato]
GO
