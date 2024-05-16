USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Schemi]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Schemi](
	[IdSc] [int] IDENTITY(1,1) NOT NULL,
	[scName] [varchar](100) NOT NULL,
	[scTag] [varchar](100) NOT NULL,
	[scIdDsc] [int] NOT NULL,
	[scIdTypeDoc] [int] NULL,
	[scIsOpen] [bit] NOT NULL,
	[scDate] [datetime] NOT NULL,
	[scVersion] [varchar](20) NULL,
 CONSTRAINT [PK_Schemi] PRIMARY KEY NONCLUSTERED 
(
	[IdSc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Schemi] ADD  CONSTRAINT [DF_Schemi_scModel]  DEFAULT (0) FOR [scIsOpen]
GO
ALTER TABLE [dbo].[Schemi] ADD  CONSTRAINT [DF_Schemi_scData]  DEFAULT (getdate()) FOR [scDate]
GO
ALTER TABLE [dbo].[Schemi]  WITH CHECK ADD  CONSTRAINT [FK_Schemi_DescsI] FOREIGN KEY([scIdDsc])
REFERENCES [dbo].[DescsI] ([IdDsc])
GO
ALTER TABLE [dbo].[Schemi] CHECK CONSTRAINT [FK_Schemi_DescsI]
GO
