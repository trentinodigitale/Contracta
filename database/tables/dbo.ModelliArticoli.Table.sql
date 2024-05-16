USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[ModelliArticoli]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ModelliArticoli](
	[IdMar] [int] IDENTITY(1,1) NOT NULL,
	[marIdMgr] [int] NOT NULL,
	[marIdArt] [int] NOT NULL,
	[marScore] [smallint] NULL,
 CONSTRAINT [PK_ModelliArticoli] PRIMARY KEY NONCLUSTERED 
(
	[IdMar] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ModelliArticoli]  WITH CHECK ADD  CONSTRAINT [FK_ModelliArticoli_ModelliGruppi] FOREIGN KEY([marIdMgr])
REFERENCES [dbo].[ModelliGruppi] ([IdMgr])
GO
ALTER TABLE [dbo].[ModelliArticoli] CHECK CONSTRAINT [FK_ModelliArticoli_ModelliGruppi]
GO
