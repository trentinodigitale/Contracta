USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MPOpzioni]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MPOpzioni](
	[IdMpo] [int] IDENTITY(1,1) NOT NULL,
	[mpoTableName] [varchar](255) NOT NULL,
	[mpoColumnName] [varchar](255) NOT NULL,
	[mpoPos] [smallint] NOT NULL,
	[mpoIdDsc] [int] NOT NULL,
 CONSTRAINT [PK_MPOpzioni] PRIMARY KEY CLUSTERED 
(
	[IdMpo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MPOpzioni]  WITH CHECK ADD  CONSTRAINT [FK_MPOpzioni_DescsI] FOREIGN KEY([mpoIdDsc])
REFERENCES [dbo].[DescsI] ([IdDsc])
GO
ALTER TABLE [dbo].[MPOpzioni] CHECK CONSTRAINT [FK_MPOpzioni_DescsI]
GO
