USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[USysColumns]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[USysColumns](
	[IdUsc] [int] IDENTITY(1,1) NOT NULL,
	[uscTableName] [varchar](100) NOT NULL,
	[uscColumnName] [varchar](100) NOT NULL,
	[uscColumnType] [varchar](5) NOT NULL,
	[uscIdDsc] [int] NULL,
 CONSTRAINT [PK_USysColumns] PRIMARY KEY CLUSTERED 
(
	[IdUsc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[USysColumns]  WITH CHECK ADD  CONSTRAINT [FK_USysColumns_DescsI1] FOREIGN KEY([uscIdDsc])
REFERENCES [dbo].[DescsI] ([IdDsc])
GO
ALTER TABLE [dbo].[USysColumns] CHECK CONSTRAINT [FK_USysColumns_DescsI1]
GO
