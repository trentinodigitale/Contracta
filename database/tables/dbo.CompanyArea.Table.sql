USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CompanyArea]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CompanyArea](
	[IdCa] [int] IDENTITY(1,1) NOT NULL,
	[caIdCt] [int] NOT NULL,
	[caType] [char](1) NOT NULL,
	[caIdMpMod] [int] NOT NULL,
	[caOrder] [int] NOT NULL,
	[caIdMultiLng] [char](101) NOT NULL,
	[caRange] [varchar](20) NULL,
	[caDeleted] [bit] NOT NULL,
	[caUltimaMod] [datetime] NOT NULL,
	[caIdGrp] [int] NULL,
	[caAreaName] [varchar](50) NULL,
 CONSTRAINT [PK_CompanyArea] PRIMARY KEY CLUSTERED 
(
	[IdCa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CompanyArea] ADD  CONSTRAINT [DF_CompanyArea_caDeleted]  DEFAULT (0) FOR [caDeleted]
GO
ALTER TABLE [dbo].[CompanyArea] ADD  CONSTRAINT [DF__CompanyAr__caUlt__5EE9FC26]  DEFAULT (getdate()) FOR [caUltimaMod]
GO
ALTER TABLE [dbo].[CompanyArea]  WITH NOCHECK ADD  CONSTRAINT [FK_CompanyArea_CompanyTab] FOREIGN KEY([caIdCt])
REFERENCES [dbo].[CompanyTab] ([IdCt])
GO
ALTER TABLE [dbo].[CompanyArea] CHECK CONSTRAINT [FK_CompanyArea_CompanyTab]
GO
