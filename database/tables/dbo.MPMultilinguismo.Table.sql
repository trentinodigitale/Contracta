USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MPMultilinguismo]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MPMultilinguismo](
	[IdMpMlng] [int] IDENTITY(1,1) NOT NULL,
	[mpmlngIdMp] [int] NOT NULL,
	[mpmlngMPKey] [char](101) NOT NULL,
	[mpmlngMlngKey] [char](101) NOT NULL,
	[mpmlngDeleted] [bit] NOT NULL,
	[mpmlngUltimaMod] [datetime] NOT NULL,
 CONSTRAINT [PK_MPMultilinguismo] PRIMARY KEY NONCLUSTERED 
(
	[IdMpMlng] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MPMultilinguismo] ADD  CONSTRAINT [DF_MPMultilinguismo_mpmlngDeleted]  DEFAULT (0) FOR [mpmlngDeleted]
GO
ALTER TABLE [dbo].[MPMultilinguismo] ADD  CONSTRAINT [DF_MPMultilinguismo_mpmlngUltimaMod]  DEFAULT (getdate()) FOR [mpmlngUltimaMod]
GO
ALTER TABLE [dbo].[MPMultilinguismo]  WITH CHECK ADD  CONSTRAINT [FK_MPMultilinguismo_MarketPlace] FOREIGN KEY([mpmlngIdMp])
REFERENCES [dbo].[MarketPlace] ([IdMp])
GO
ALTER TABLE [dbo].[MPMultilinguismo] CHECK CONSTRAINT [FK_MPMultilinguismo_MarketPlace]
GO
