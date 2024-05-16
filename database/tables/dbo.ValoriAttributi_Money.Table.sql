USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[ValoriAttributi_Money]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ValoriAttributi_Money](
	[IdVat] [int] NOT NULL,
	[vatValore] [money] NOT NULL,
	[vatIdSdv] [int] NULL,
 CONSTRAINT [PK_ValoriAttributi_Money] PRIMARY KEY NONCLUSTERED 
(
	[IdVat] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ValoriAttributi_Money] ADD  CONSTRAINT [DF_ValoriAttributi_Money_vatIdSdv]  DEFAULT (1) FOR [vatIdSdv]
GO
ALTER TABLE [dbo].[ValoriAttributi_Money]  WITH CHECK ADD  CONSTRAINT [FK_ValoriAttributi_Money_ValoriAttributi] FOREIGN KEY([IdVat])
REFERENCES [dbo].[ValoriAttributi] ([IdVat])
GO
ALTER TABLE [dbo].[ValoriAttributi_Money] CHECK CONSTRAINT [FK_ValoriAttributi_Money_ValoriAttributi]
GO
