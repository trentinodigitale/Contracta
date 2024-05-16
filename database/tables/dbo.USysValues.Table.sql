USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[USysValues]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[USysValues](
	[IdUsv] [int] IDENTITY(1,1) NOT NULL,
	[usvIdUsc] [int] NOT NULL,
	[usvValue] [varchar](4000) NOT NULL,
	[usvIdDsc] [int] NOT NULL,
 CONSTRAINT [PK_UsysValues] PRIMARY KEY CLUSTERED 
(
	[IdUsv] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[USysValues]  WITH CHECK ADD  CONSTRAINT [FK_UsysValues_DescsI1] FOREIGN KEY([usvIdDsc])
REFERENCES [dbo].[DescsI] ([IdDsc])
GO
ALTER TABLE [dbo].[USysValues] CHECK CONSTRAINT [FK_UsysValues_DescsI1]
GO
ALTER TABLE [dbo].[USysValues]  WITH CHECK ADD  CONSTRAINT [FK_UsysValues_USysColumns1] FOREIGN KEY([usvIdUsc])
REFERENCES [dbo].[USysColumns] ([IdUsc])
GO
ALTER TABLE [dbo].[USysValues] CHECK CONSTRAINT [FK_UsysValues_USysColumns1]
GO
