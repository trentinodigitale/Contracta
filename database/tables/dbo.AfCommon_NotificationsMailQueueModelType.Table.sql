USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[AfCommon_NotificationsMailQueueModelType]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AfCommon_NotificationsMailQueueModelType](
	[id] [varchar](450) NOT NULL,
	[mpmevento] [varchar](max) NULL,
	[tipoevento] [int] NOT NULL,
	[creationdate] [datetime] NOT NULL,
	[idpfu] [varchar](max) NULL,
	[sessionid] [varchar](max) NULL,
	[source] [varchar](max) NULL,
	[message] [varchar](max) NULL,
	[nomecliente] [varchar](max) NULL,
	[ambiente] [varchar](max) NULL,
	[codazi] [varchar](max) NULL,
	[userip] [varchar](max) NULL,
	[contestoapplicativo] [varchar](max) NULL,
	[errornumber] [varchar](max) NULL,
	[ipserver] [varchar](max) NULL,
	[errorsource] [varchar](max) NULL,
	[errorcause] [varchar](max) NULL,
	[paginachiamante] [varchar](max) NULL,
	[mollicadipane] [varchar](max) NULL,
	[paginarichiesta] [varchar](max) NULL,
	[querystring] [varchar](max) NULL,
	[sent] [bit] NULL,
	[send_date] [datetime] NULL,
	[send_error] [varchar](max) NULL,
	[job_id] [varchar](max) NULL,
 CONSTRAINT [PK_AfCommon_NotificationsMailQueueModelType] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
