USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[ValoriIndicatori]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ValoriIndicatori](
	[IdVind] [int] NOT NULL,
	[vindIdAzi] [int] NOT NULL,
	[vindIdDsc] [int] NULL,
	[vindValore] [float] NOT NULL,
	[vindDI] [datetime] NOT NULL,
	[vindDF] [datetime] NOT NULL,
 CONSTRAINT [PK_ValoriIndicatori] PRIMARY KEY NONCLUSTERED 
(
	[IdVind] ASC,
	[vindIdAzi] ASC,
	[vindDI] ASC,
	[vindDF] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ValoriIndicatori] ADD  CONSTRAINT [DF_ValoriIndicatori_vindDI]  DEFAULT (getdate()) FOR [vindDI]
GO
ALTER TABLE [dbo].[ValoriIndicatori] ADD  CONSTRAINT [DF_ValoriIndicatori_vindDF]  DEFAULT ('99991231') FOR [vindDF]
GO
ALTER TABLE [dbo].[ValoriIndicatori]  WITH CHECK ADD  CONSTRAINT [FK_ValoriIndicatori_DescsI] FOREIGN KEY([vindIdDsc])
REFERENCES [dbo].[DescsI] ([IdDsc])
GO
ALTER TABLE [dbo].[ValoriIndicatori] CHECK CONSTRAINT [FK_ValoriIndicatori_DescsI]
GO
