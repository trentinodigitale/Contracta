USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[OapUltimaProp]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OapUltimaProp](
	[ProgDett] [tinyint] NULL,
	[IdDettRig] [int] NOT NULL,
	[IdDett] [int] NOT NULL,
	[DataScad] [datetime] NULL,
	[DataScadProp] [datetime] NULL,
	[QO] [float] NULL,
	[QOProp] [float] NULL,
	[QTAProgCons] [float] NULL,
	[QtaProgConsProp] [float] NULL,
	[SottoTipoRiga] [varchar](20) NOT NULL,
	[Send] [int] NULL,
	[InsForn] [bit] NOT NULL,
	[PrevisionalDateCrudeDelivery] [datetime] NULL,
	[EffectiveDateCrudeDelivery] [datetime] NULL,
	[EffectiveQtyCrudeDelivery] [float] NULL,
	[PlannedDeliveryDate] [datetime] NULL
) ON [PRIMARY]
GO
