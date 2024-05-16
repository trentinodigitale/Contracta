USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CARRELLO_ADDFROM_CATALOGO]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[CARRELLO_ADDFROM_CATALOGO] as
select  --pr.*

		pr.idRow
		, pr.idHeader
		, pr.Progressivo
		, pr.Marca
		, pr.Codice
		, pr.Descrizione
		, pr.Merceologia
		, pr.QtMin
		, pr.QtMax
		, pr.IVA
		, pr.TipoProdotto
		, pr.PrezzoUnitario
		, pr.Nota
		, pr.PercSconto
		--, CoefCorr
		, pr.CostoComplessivo
		, pr.UnitMis
		, pr.Immagine 
		, pr.Brochure
	    , '' as Plant 
--		,pl.Plant  
--		,cast( pr.idRow as varchar ) + '_' + cast( pl.idRow as varchar ) as indrow 
--		,cast( pr.idRow as varchar ) + '_' + cast( pl.idRow as varchar ) as Id_Convenzione
		,cast( pr.idRow as varchar ) as indrow 
		,cast( c.id as varchar ) as Id_Convenzione
		,cast( AZI_Dest as int ) as Fornitore
		,  AZI_Dest as RDP_Fornitore


		, id
		,Codice as RDP_CodArtProd 
		,Descrizione as RDP_Desc
		, PrezzoUnitario as RDP_Importo
		,QtMin as RDP_Qt
		, pr.idRow as Id_Product
		
	 , case when TipoOrdine in ( 'S' , 'C' ) then ' Descrizione  PrezzoUnitario RDP_Desc RDP_Importo ' else '' end as NonEditabili
	 , 1 as CoefCorr
	 , c.TipoOrdine
	 , ImportoCompenso 
	 , RicPreventivo
	from  Document_Convenzione c
	inner join Document_Convenzione_Product pr on c.ID = pr.idHeader
--	inner join Document_Convenzione_Plant pl on c.ID = pl.idHeader

GO
