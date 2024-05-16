USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DWH_Get_ODF_Dettagli]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[OLD2_DWH_Get_ODF_Dettagli]
as

	select 

			c.protocollo as [Id OdF],
			NumeroRiga as [Numero Riga],
			numord as  [Numero Convenzione],
			NumeroLotto as [Numero Lotto],
			[CODICE_REGIONALE] as [Codice Regionale],
			[DESCRIZIONE_CODICE_REGIONALE] as [Descrizione Codice Regionale],
			[CODICE_ARTICOLO_FORNITORE] as [Codice articolo fornitore],
			[DENOMINAZIONE_ARTICOLO_FORNITORE] as [Denominazione articolo fornitore],
			vv1.DMV_CodExt + ' - ' +  vv1.DMV_DescML as  [Area merceologica],
			case when UnitadiMisura like '''%''' then substring( UnitadiMisura , 2 , len( UnitadiMisura ) -2 ) else UnitadiMisura end  as [U.M.],
			qty as [Quantità],
			PREZZO_OFFERTO_PER_UM  as [Prezzo unitario iva esclusa],
			Erosione  as [Flag Erosione],
			DD.Qty*DD.ValoreEconomico   as [Totale Riga Ordine],
			dd.AliquotaIva as [Aliquota IVA riga d'ordine],
			( DD.Qty * DD.ValoreEconomico * dd.AliquotaIva ) / 100  as [Valore IVA riga d'ordine]


	from document_ODC a with(nolock) 

			inner join ctl_doc c with(nolock) on c.id=a.RDA_ID

			inner join Document_Convenzione DC with(nolock) on Id_Convenzione = DC.ID
						
			inner join document_microlotti_dettagli DD with(nolock) on C.id = DD.idheader and DD.Tipodoc='ODC'

			left outer join aziende a1 with(nolock) on a1.idazi = c.azienda

			left outer join aziende a2 with(nolock) on a2.idazi = c.Destinatario_Azi 

			left outer join ProfiliUtente p1  with(nolock) on p1.idpfu = isnull(a.UserRUP ,0)
						
			left outer join LIB_DomainValues VV1 with(nolock) on vv1.DMV_DM_ID = 'CODICE_CPV' and vv1.DMV_Cod = CODICE_CPV

	where c.tipodoc = 'ODC'
		and c.deleted = 0 and RDA_Deleted = 0 and dc.Deleted = 0
		--and c.StatoFunzionale <> 'InLavorazione'
		and c.StatoFunzionale not in ( 'InLavorazione' , 'InApprove' , 'NotApproved' ) 










GO
