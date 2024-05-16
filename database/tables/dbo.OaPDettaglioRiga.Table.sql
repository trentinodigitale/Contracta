USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[OaPDettaglioRiga]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OaPDettaglioRiga](
	[IdDettRig] [int] IDENTITY(1,1) NOT NULL,
	[IdDett] [int] NOT NULL,
	[NumOrd] [nvarchar](7) NULL,
	[SottoTipoRiga] [varchar](20) NOT NULL,
	[DataScad] [datetime] NULL,
	[QO] [float] NULL,
	[Modify] [varchar](10) NOT NULL,
	[QTAOrdPrec] [float] NULL,
	[SottoTipoRigaOrdPrec] [varchar](20) NULL,
	[QtaProgCons] [float] NULL,
	[DataScadProp] [datetime] NULL,
	[QOProp] [float] NULL,
	[QtaProgConsProp] [float] NULL,
	[Send] [int] NULL,
	[InsForn] [bit] NOT NULL,
	[ChiaveRigaDett] [int] NULL,
	[PrevisionalDateCrudeDelivery] [datetime] NULL,
	[EffectiveDateCrudeDelivery] [datetime] NULL,
	[EffectiveQtyCrudeDelivery] [float] NULL,
	[PlannedDeliveryDate] [datetime] NULL,
 CONSTRAINT [PK_OaPDettaglioRiga] PRIMARY KEY CLUSTERED 
(
	[IdDettRig] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OaPDettaglioRiga] ADD  CONSTRAINT [DF_OAPDettaglioRiga_Modify]  DEFAULT (0) FOR [Modify]
GO
ALTER TABLE [dbo].[OaPDettaglioRiga] ADD  CONSTRAINT [DF_OaPDettaglioRiga_InsForn]  DEFAULT (0) FOR [InsForn]
GO
