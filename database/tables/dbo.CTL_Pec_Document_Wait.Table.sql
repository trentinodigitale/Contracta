USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_Pec_Document_Wait]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_Pec_Document_Wait](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[IdDoc] [int] NULL,
	[IdPfu] [int] NULL,
	[TypeDoc] [varchar](255) NULL,
	[ProcessName] [varchar](255) NULL,
	[DataIns] [datetime] NULL,
	[DataUpdate] [datetime] NULL,
	[Status] [varchar](50) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_Pec_Document_Wait] ADD  CONSTRAINT [DF_CTL_Pec_Document_Wait_DataIns]  DEFAULT (getdate()) FOR [DataIns]
GO
