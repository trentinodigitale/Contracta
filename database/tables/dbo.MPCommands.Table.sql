USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MPCommands]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MPCommands](
	[IdMpc] [int] IDENTITY(1,1) NOT NULL,
	[mpcIdGroup] [int] NOT NULL,
	[mpcIType] [smallint] NOT NULL,
	[mpcISubType] [smallint] NOT NULL,
	[mpcName] [char](101) NULL,
	[mpcTypeCommand] [smallint] NOT NULL,
	[mpcSystem] [smallint] NOT NULL,
	[mpcUserFunz] [int] NOT NULL,
	[mpcIcon] [varchar](30) NOT NULL,
	[mpcParam1] [int] NULL,
	[mpcParam2] [varchar](50) NULL,
	[mpcOrdine] [smallint] NOT NULL,
	[mpcDeleted] [bit] NOT NULL,
	[mpcUltimaMod] [datetime] NOT NULL,
	[mpcLink] [varchar](2000) NULL,
	[mpcSelection] [smallint] NULL,
	[mpc_Module] [varchar](100) NULL,
 CONSTRAINT [PK_MPCommands] PRIMARY KEY NONCLUSTERED 
(
	[IdMpc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MPCommands] ADD  CONSTRAINT [DF_MPCommands_mpcDeleted]  DEFAULT (0) FOR [mpcDeleted]
GO
ALTER TABLE [dbo].[MPCommands] ADD  CONSTRAINT [DF_MPCommands_mpcUltimaMod]  DEFAULT (getdate()) FOR [mpcUltimaMod]
GO
