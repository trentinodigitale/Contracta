USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_NoTIER_Numerical_CODE]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_NoTIER_Numerical_CODE](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[SCHEME_ID] [varchar](1000) NULL,
	[Numerical_Code] [varchar](1000) NOT NULL,
	[Scheme_agency_name] [varchar](1000) NULL,
	[Deprecated] [bit] NULL,
	[Deprecated_date] [datetime] NULL,
	[bloccaNuovi] [int] NULL
) ON [PRIMARY]
GO
