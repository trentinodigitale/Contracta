USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[ValoriAttributi_Int]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ValoriAttributi_Int](
	[IdVat] [int] NOT NULL,
	[vatValore] [int] NULL,
 CONSTRAINT [PK_ValoriAttributi_Int] PRIMARY KEY NONCLUSTERED 
(
	[IdVat] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ValoriAttributi_Int]  WITH CHECK ADD  CONSTRAINT [FK_ValoriAttributi_Int_ValoriAttributi] FOREIGN KEY([IdVat])
REFERENCES [dbo].[ValoriAttributi] ([IdVat])
GO
ALTER TABLE [dbo].[ValoriAttributi_Int] CHECK CONSTRAINT [FK_ValoriAttributi_Int_ValoriAttributi]
GO
