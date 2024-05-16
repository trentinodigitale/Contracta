USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BANDO_AQ_LISTA_OFFERTE]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[BANDO_AQ_LISTA_OFFERTE] AS
select EL.*
	from BANDO_SDA_LISTA_OFFERTE EL
		inner join CTL_DOC PDA with(nolock) on PDA.LinkedDoc=EL.LinkedDoc and PDA.Deleted=0 and PDA.TipoDoc = 'PDA_MICROLOTTI'
		inner join Document_PDA_OFFERTE OFFERTE with(nolock) on OFFERTE.IdHeader=PDA.id and EL.Id=OFFERTE.IdMsg 					
	--PRENDIAMO LE AMMESSE , AMMESSE CON RISERVA E Ammessa ex art. 133 comma 8
	where StatoPDA IN ('2','22','222')

GO
