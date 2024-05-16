USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CountersRules]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CountersRules](
	[IdCr] [int] IDENTITY(1,1) NOT NULL,
	[crScript] [text] NOT NULL,
	[crSystem] [bit] NOT NULL,
	[crIdDsc] [int] NOT NULL,
	[crDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_CountersRules] PRIMARY KEY CLUSTERED 
(
	[IdCr] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CountersRules] ADD  CONSTRAINT [DF_CountersRules_crSystem]  DEFAULT (0) FOR [crSystem]
GO
ALTER TABLE [dbo].[CountersRules] ADD  CONSTRAINT [DF_CountersRules_crDeleted]  DEFAULT (0) FOR [crDeleted]
GO
ALTER TABLE [dbo].[CountersRules]  WITH CHECK ADD  CONSTRAINT [FK_CountersRules_DescsI] FOREIGN KEY([crIdDsc])
REFERENCES [dbo].[DescsI] ([IdDsc])
GO
ALTER TABLE [dbo].[CountersRules] CHECK CONSTRAINT [FK_CountersRules_DescsI]
GO
