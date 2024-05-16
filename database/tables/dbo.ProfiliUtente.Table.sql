USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[ProfiliUtente]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProfiliUtente](
	[IdPfu] [int] IDENTITY(1,1) NOT NULL,
	[pfuTs] [timestamp] NOT NULL,
	[pfuIdAzi] [int] NOT NULL,
	[pfuNome] [nvarchar](530) NULL,
	[pfuLogin] [nvarchar](200) NULL,
	[pfuRuoloAziendale] [nvarchar](200) NULL,
	[pfuPassword] [nvarchar](250) NULL,
	[pfuPrefissoProt] [nvarchar](3) NULL,
	[pfuAdmin] [bit] NOT NULL,
	[pfuAcquirente] [bit] NOT NULL,
	[pfuVenditore] [bit] NOT NULL,
	[pfuInvRdO] [bit] NOT NULL,
	[pfuRcvOff] [bit] NOT NULL,
	[pfuInvOff] [bit] NOT NULL,
	[pfuIdPfuBCopiaA] [int] NULL,
	[pfuIdPfuSCopiaA] [int] NULL,
	[pfuCopiaRdo] [bit] NOT NULL,
	[pfuCopiaOffRic] [bit] NOT NULL,
	[pfuImpMaxRdO] [money] NOT NULL,
	[pfuImpMaxOff] [money] NOT NULL,
	[pfuImpMaxRdoAnn] [money] NOT NULL,
	[pfuImpMaxOffAnn] [money] NOT NULL,
	[pfuIdLng] [int] NOT NULL,
	[pfuParametriBench] [varchar](20) NULL,
	[pfuSkillLevel1] [int] NULL,
	[pfuSkillLevel2] [int] NULL,
	[pfuSkillLevel3] [int] NULL,
	[pfuSkillLevel4] [int] NULL,
	[pfuSkillLevel5] [int] NULL,
	[pfuSkillLevel6] [int] NULL,
	[pfuE_Mail] [nvarchar](1000) NULL,
	[pfuTestoSollecito] [ntext] NULL,
	[pfuDeleted] [smallint] NOT NULL,
	[pfuBizMail] [nvarchar](50) NULL,
	[pfuCatalogo] [bit] NOT NULL,
	[pfuProfili] [varchar](20) NULL,
	[pfuFunzionalita] [varchar](1000) NULL,
	[pfuopzioni] [varchar](50) NOT NULL,
	[pfuTel] [nvarchar](30) NULL,
	[pfuCell] [nvarchar](30) NULL,
	[pfuSIM] [nvarchar](50) NULL,
	[pfuIdMpMod] [smallint] NULL,
	[pfuToken] [varchar](50) NULL,
	[pfuCodiceFiscale] [varchar](50) NULL,
	[pfuLastLogin] [datetime] NULL,
	[pfuAlgoritmoPassword] [varchar](2) NULL,
	[pfuDataCambioPassword] [datetime] NULL,
	[pfuStato] [nchar](20) NULL,
	[pfuTentativiLogin] [int] NULL,
	[pfuResponsabileUtente] [int] NULL,
	[pfuTitolo] [nvarchar](200) NULL,
	[pfuCognome] [nvarchar](255) NULL,
	[pfunomeutente] [nvarchar](255) NULL,
	[pfuDataCreazione] [datetime] NULL,
	[UtenteFedera] [bit] NULL,
	[PasswordScaduta] [bit] NULL,
	[pfuUserID] [nvarchar](255) NULL,
	[pfuSessionID] [varchar](4000) NULL,
	[pfuIpServerLogin] [varchar](100) NULL,
	[Nazione] [varchar](200) NULL,
	[pfuLastLogout] [datetime] NULL,
	[UseOTP] [bit] NOT NULL,
	[TelTrusted] [bit] NOT NULL,
 CONSTRAINT [PK_ProfiliUtente_1] PRIMARY KEY CLUSTERED 
(
	[IdPfu] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProfiliUtente] ADD  CONSTRAINT [DF_ProfiliUtente_pfuPrefissoProt]  DEFAULT ('XXX') FOR [pfuPrefissoProt]
GO
ALTER TABLE [dbo].[ProfiliUtente] ADD  CONSTRAINT [DF_ProfiliUtente_pfuAdmin]  DEFAULT ((0)) FOR [pfuAdmin]
GO
ALTER TABLE [dbo].[ProfiliUtente] ADD  CONSTRAINT [DF_ProfiliUtente_pfuAcquirente]  DEFAULT ((0)) FOR [pfuAcquirente]
GO
ALTER TABLE [dbo].[ProfiliUtente] ADD  CONSTRAINT [DF_ProfiliUtente_pfuVenditore]  DEFAULT ((0)) FOR [pfuVenditore]
GO
ALTER TABLE [dbo].[ProfiliUtente] ADD  CONSTRAINT [DF_ProfiliUtente_pfuInvRdO]  DEFAULT ((0)) FOR [pfuInvRdO]
GO
ALTER TABLE [dbo].[ProfiliUtente] ADD  CONSTRAINT [DF_ProfiliUtente_pfuRcvOff]  DEFAULT ((0)) FOR [pfuRcvOff]
GO
ALTER TABLE [dbo].[ProfiliUtente] ADD  CONSTRAINT [DF_ProfiliUtente_pfuInvOff]  DEFAULT ((0)) FOR [pfuInvOff]
GO
ALTER TABLE [dbo].[ProfiliUtente] ADD  CONSTRAINT [DF_ProfiliUtente_pfuCopiaRdo]  DEFAULT ((0)) FOR [pfuCopiaRdo]
GO
ALTER TABLE [dbo].[ProfiliUtente] ADD  CONSTRAINT [DF_ProfiliUtente_pfuCopiaOffRic]  DEFAULT ((0)) FOR [pfuCopiaOffRic]
GO
ALTER TABLE [dbo].[ProfiliUtente] ADD  CONSTRAINT [DF_ProfiliUtente_pfuImpMaxRdO]  DEFAULT ((0)) FOR [pfuImpMaxRdO]
GO
ALTER TABLE [dbo].[ProfiliUtente] ADD  CONSTRAINT [DF_ProfiliUtente_pfuImpMaxOff]  DEFAULT ((0)) FOR [pfuImpMaxOff]
GO
ALTER TABLE [dbo].[ProfiliUtente] ADD  CONSTRAINT [DF_ProfiliUtente_pfuImpMaxRdoAnn]  DEFAULT ((0)) FOR [pfuImpMaxRdoAnn]
GO
ALTER TABLE [dbo].[ProfiliUtente] ADD  CONSTRAINT [DF_ProfiliUtente_pfuImpMaxOffAnn]  DEFAULT ((0)) FOR [pfuImpMaxOffAnn]
GO
ALTER TABLE [dbo].[ProfiliUtente] ADD  CONSTRAINT [DF_ProfiliUtente_pfuIdLng]  DEFAULT ((1)) FOR [pfuIdLng]
GO
ALTER TABLE [dbo].[ProfiliUtente] ADD  CONSTRAINT [DF_ProfiliUtente_pfuDeleted]  DEFAULT ((0)) FOR [pfuDeleted]
GO
ALTER TABLE [dbo].[ProfiliUtente] ADD  CONSTRAINT [DF_ProfiliUtente_pfuCatalogo]  DEFAULT ((0)) FOR [pfuCatalogo]
GO
ALTER TABLE [dbo].[ProfiliUtente] ADD  CONSTRAINT [DF_PROFILIUTENTE_PFUFUNZIONALITA]  DEFAULT ('0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000') FOR [pfuFunzionalita]
GO
ALTER TABLE [dbo].[ProfiliUtente] ADD  CONSTRAINT [DF_ProfiliUtente_pfuopzioni]  DEFAULT ('11010010000000000000000000000000000000000000000000') FOR [pfuopzioni]
GO
ALTER TABLE [dbo].[ProfiliUtente] ADD  CONSTRAINT [DF_profiliutente_pfuAlgoritmoPassword]  DEFAULT (N'0') FOR [pfuAlgoritmoPassword]
GO
ALTER TABLE [dbo].[ProfiliUtente] ADD  CONSTRAINT [DF_ProfiliUtente_pfuDataCreazione]  DEFAULT (getdate()) FOR [pfuDataCreazione]
GO
ALTER TABLE [dbo].[ProfiliUtente] ADD  CONSTRAINT [DF_ProfiliUtente_UtenteFedera]  DEFAULT ((0)) FOR [UtenteFedera]
GO
ALTER TABLE [dbo].[ProfiliUtente] ADD  CONSTRAINT [DF_ProfiliUtente_PasswordScaduta]  DEFAULT ((0)) FOR [PasswordScaduta]
GO
ALTER TABLE [dbo].[ProfiliUtente] ADD  CONSTRAINT [DF_UseOTP]  DEFAULT ((1)) FOR [UseOTP]
GO
ALTER TABLE [dbo].[ProfiliUtente] ADD  CONSTRAINT [DF_TelTrusted]  DEFAULT ((0)) FOR [TelTrusted]
GO
ALTER TABLE [dbo].[ProfiliUtente]  WITH NOCHECK ADD  CONSTRAINT [FK_ProfiliUtente_Aziende] FOREIGN KEY([pfuIdAzi])
REFERENCES [dbo].[Aziende] ([IdAzi])
GO
ALTER TABLE [dbo].[ProfiliUtente] CHECK CONSTRAINT [FK_ProfiliUtente_Aziende]
GO
