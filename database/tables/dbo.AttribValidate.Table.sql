USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[AttribValidate]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AttribValidate](
	[TipologiaStorico] [char](3) NOT NULL,
	[Data] [datetime] NOT NULL,
 CONSTRAINT [PK_AttribValidate] PRIMARY KEY CLUSTERED 
(
	[TipologiaStorico] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
