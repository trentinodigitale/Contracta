USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[ValoriAttributi_Image]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ValoriAttributi_Image](
	[IdVat] [int] NOT NULL,
	[vatValore] [image] NOT NULL,
 CONSTRAINT [PK_ValoriAttributi_Image] PRIMARY KEY CLUSTERED 
(
	[IdVat] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ValoriAttributi_Image]  WITH CHECK ADD  CONSTRAINT [FK_ValoriAttributi_Image_ValoriAttributi] FOREIGN KEY([IdVat])
REFERENCES [dbo].[ValoriAttributi] ([IdVat])
GO
ALTER TABLE [dbo].[ValoriAttributi_Image] CHECK CONSTRAINT [FK_ValoriAttributi_Image_ValoriAttributi]
GO
