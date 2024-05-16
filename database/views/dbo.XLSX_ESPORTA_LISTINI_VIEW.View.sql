USE [AFLink_TND]
GO
/****** Object:  View [dbo].[XLSX_ESPORTA_LISTINI_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[XLSX_ESPORTA_LISTINI_VIEW] AS
	select  
		DC.ID as idConvenzione
		, model.value as idModello
		, isnull(C.protocollogenerale,'') as rspic
		--, C.Dataprotocollogenerale as dataRspic
		, DC.Macro_Convenzione
		, DC.NumOrd as numeroConvenzioneCompleta
		, azi.aziRagioneSociale as ragioneSociale
		, dm1.vatValore_FT as codiceFiscale

		, c.titolo as DOC_Name
		, c.StatoFunzionale
		, year (DC.DataInizio) as AnnoPubConvenzione
		, year (dc.datafine) as AnnoScadConvenzione
		, DC.AZI_Dest
		, DC.NumOrd
		, DC.IdentificativoIniziativa
		, DC.Ambito
		, year(DC.DataInizio) as Anno_inizio_convenzione
	from ctl_doc c with(nolock) 
		inner join Document_Convenzione DC with(nolock) on C.id=DC.id
		inner join CTL_DOC_Value model with(nolock) ON model.IdHeader = c.id and model.dse_id = 'TESTATA_PRODOTTI' and model.DZT_Name = 'id_modello' and isnull(model.value,'') <> ''

		left join aziende azi with(nolock) on azi.idazi = dc.Mandataria and azi.aziDeleted = 0
		left join DM_Attributi dm1 with(nolock) on dm1.lnk = azi.idazi and dm1.dztNome = 'codicefiscale'
		--left join profiliUtente P  with(nolock) on P.idpfu=c.idpfu and P.pfudeleted=0

	where DC.Deleted = 0 and C.Deleted = 0 and C.tipodoc='CONVENZIONE'
		and dc.StatoConvenzione ='pubblicato'
			
GO
