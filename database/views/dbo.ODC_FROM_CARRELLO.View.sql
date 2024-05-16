USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ODC_FROM_CARRELLO]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE view [dbo].[ODC_FROM_CARRELLO] as
SELECT distinct  idPfu as ID_FROM 
                    , b.Plant 
					, cast( Id_Convenzione  as int ) as Id_Convenzione
					, NumOrd as NumeroConvenzione
					, AZI_Dest as IdAziDest
					--, IVA
					, c.TipoOrdine
					, c.TipoImporto
FROM         Carrello b
	inner join dbo.Document_Convenzione c on c.ID = cast( b.Id_Convenzione  as int )
GO
