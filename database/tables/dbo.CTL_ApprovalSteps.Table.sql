USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_ApprovalSteps]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_ApprovalSteps](
	[APS_ID_ROW] [int] IDENTITY(1,1) NOT NULL,
	[APS_Doc_Type] [varchar](50) NULL,
	[APS_ID_DOC] [int] NULL,
	[APS_State] [varchar](50) NULL,
	[APS_Note] [ntext] NULL,
	[APS_Allegato] [varchar](255) NULL,
	[APS_UserProfile] [varchar](50) NULL,
	[APS_IdPfu] [varchar](20) NULL,
	[APS_IsOld] [tinyint] NULL,
	[APS_Date] [datetime] NULL,
	[APS_APC_Cod_Node] [varchar](50) NULL,
	[APS_NextApprover] [varchar](20) NULL,
	[APS_ID_DOC_STEP] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_ApprovalSteps] ADD  CONSTRAINT [DF__CTL_Appro__APS_D__7450F1A9]  DEFAULT (getdate()) FOR [APS_Date]
GO
