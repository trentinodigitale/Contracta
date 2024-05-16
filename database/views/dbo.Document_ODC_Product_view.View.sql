USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_ODC_Product_view]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE view [dbo].[Document_ODC_Product_view]  as
--Versione=2&data=2012-06-28&Attivita=38848&Nominativo=Sabato
select 
-- case when TipoOrdine in ( 'S' , 'C' ) 
--		then ' RDP_Desc RDP_Importo ' 
--		else isnull( p.NonEditabili,'') 
--	end as NonEditabili
-- , 
--   RDP_idRow, RDP_RDA_ID, RDP_VDS, RDP_Merceologia, RDP_Progetto, RDP_Fornitore, RDP_CodArtProd, RDP_Commessa, RDP_Importo, RDP_Qt, 
--                      p.RDP_DataPrevCons, RDP_Desc, RDP_Allegato, RDP_TiketBudget, RDP_InBudget, RDP_ResidualBudget, RDP_TipoInvestimento, RDP_UMNonCod, 
--                      RDP_Stato, RDP_NotEditable, RDP_cpi, RDP_rprot, RDP_DescCod, RDP_BDD_ID, ValEuroDtCons, ValEuroDtConsMd, ValCambioAziDtCons, 
--                      ValCambioAziDtConsMd, RDA_SOCRic, RDA_PlantRic, Marca, QtMin, p.Id_Convenzione, Nota, PercSconto, CoefCorr, CostoComplessivo, DataUtilizzo, 
--                      Id_Product, ImportoCompenso,QtMax,TipoProdotto,UnitMis,p.IVA , QTDisp , Evidenzia
D.*
from 
	--Document_ODC_Product p
	ctl_doc C inner join
		document_microlotti_dettagli D on C.id = D.idheader
	--inner join Document_ODC on RDA_ID = RDP_RDA_ID
where
	C.tipodoc='ODC' and D.Tipodoc='ODC'
GO
