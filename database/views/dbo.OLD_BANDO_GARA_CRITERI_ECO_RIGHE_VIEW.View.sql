USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_BANDO_GARA_CRITERI_ECO_RIGHE_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_BANDO_GARA_CRITERI_ECO_RIGHE_VIEW] as

select *  , AttributoBase as CampoTesto_1 , AttributoValore as CampoTesto_2 from  Document_Microlotto_Valutazione_eco


GO
