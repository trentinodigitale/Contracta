USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[EgdEvent]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EgdEvent](
	[IdEvent] [int] IDENTITY(1,1) NOT NULL,
	[EvDescr] [varchar](101) NOT NULL,
	[EvTipoSez] [varchar](1000) NULL,
	[EvUtilizzo] [varchar](50) NOT NULL,
	[EvDataUltimaMod] [datetime] NOT NULL,
	[EvDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_Event_mik] PRIMARY KEY CLUSTERED 
(
	[IdEvent] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EgdEvent] ADD  CONSTRAINT [DF_Event_mik_EvDataUltimaMod]  DEFAULT (getdate()) FOR [EvDataUltimaMod]
GO
ALTER TABLE [dbo].[EgdEvent] ADD  CONSTRAINT [DF_Event_mik_EvDeleted]  DEFAULT (0) FOR [EvDeleted]
GO
