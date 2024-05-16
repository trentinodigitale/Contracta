USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_BANDO_ASTA_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view [dbo].[OLD2_BANDO_ASTA_TESTATA_VIEW] as 

select 
	 
	b.idRow, b.idHeader, b.SoggettiAmmessi, b.ImportoBando, b.MaxNumeroIniziative, b.MaxFinanziabile, b.dataCreazione, b.DataEstenzioneInizio, b.DataEstenzioneFine, b.FAX, b.DataRiferimentoInizio, b.DataRiferimentoFine, b.DataPresentazioneRisposte, b.StatoBando, b.Ufficio, b.NumeroBUR, b.DataBUR, b.dgrN, b.dgrDel, b.TipoBando, b.TipoAppalto, b.RichiestaQuesito, b.ReceivedQuesiti, b.RecivedIstanze, b.MotivoEstensionePeriodo, b.ClasseIscriz, b.RichiediProdotti, b.ProceduraGara, b.TipoBandoGara, b.CriterioAggiudicazioneGara, b.ImportoBaseAsta, b.Iva, b.ImportoBaseAsta2, b.Oneri, b.CriterioFormulazioneOfferte, b.CalcoloAnomalia, b.OffAnomale, b.NumeroIndizione, b.DataIndizione, b.gg_QuesitiScadenza, b.DataTermineQuesiti, b.ClausolaFideiussoria, b.VisualizzaNotifiche, b.CUP, b.CIG, b.GG_OffIndicativa, b.HH_OffIndicativa, b.MM_OffIndicativa, b.DataScadenzaOffIndicativa, b.GG_Offerta, b.HH_Offerta, b.MM_Offerta, b.DataScadenzaOfferta, b.GG_PrimaSeduta, b.HH_PrimaSeduta, b.MM_PrimaSeduta, b.DataAperturaOfferte, b.TipoAppaltoGara, b.ProtocolloBando, b.DataRevoca, b.Conformita, b.Divisione_lotti, b.NumDec, b.DirezioneEspletante, b.DataProtocolloBando, b.ModalitadiPartecipazione, b.TipoIVA, b.EvidenzaPubblica, b.Opzioni, b.Complex, b.RichiestaCampionatura, b.TipoGiudizioTecnico, b.TipoProceduraCaratteristica, b.GeneraConvenzione, b.ListaAlbi, b.Appalto_Verde, b.Acquisto_Sociale, b.Motivazione_Appalto_Verde, b.Motivazione_Acquisto_Sociale, b.Riferimento_Gazzetta, b.Data_Pubblicazione_Gazzetta, b.BaseAstaUnitaria, b.IdentificativoIniziativa, b.DataTermineRispostaQuesiti, b.TipoSceltaContraente, b.TipoAccordoQuadro, b.TipoAggiudicazione, b.RegoleAggiudicatari, b.TipologiaDiAcquisto, b.Merceologia, b.CPV

	, d.Azienda 
	, d.StrutturaAziendale
	, d.Body
	, v1.Value as ArtClasMerceologica 
	, v2.Value as UserRUP
	, d.Fascicolo
	, case when TipoBandoGara = '3' then '' else ' EvidenzaPubblica ' end
		+ case when mpidazimaster is null and b.TipoProceduraCaratteristica = 'RDO'  then ' GeneraConvenzione ' else '' end
		as Not_Editable
	,d.LinkedDoc
	,d.protocollogenerale
	, pda.id as idpda
	,case
		when d.statofunzionale = 'Revocato' then 'chiuso'
		when d.statodoc = 'Saved' then ''

		when getdate() <= b.DataScadenzaOfferta and d.TipoDoc = 'BANDO_GARA' then 'aperto'
		when getdate() <= b.DataScadenzaOffIndicativa and d.TipoDoc = 'BANDO_SEMPLIFICATO' then 'aperto'

		when getdate() > b.DataScadenzaOfferta and getdate() <= isnull( DataAggiudicazione , '3000-12-31' ) and  d.TipoDoc = 'BANDO_GARA'  then 'incorso'
		when getdate() > b.DataScadenzaOffIndicativa and getdate() <= isnull( DataAggiudicazione , '3000-12-31' ) and  d.TipoDoc = 'BANDO_SEMPLIFICATO'  then 'incorso'

		when getdate() > isnull( DataAggiudicazione , '3000-12-31' ) then 'chiuso'
		else ''
	end as StatoProcedura
	--, case 
	--	when d.statofunzionale = 'Revocato' then rev.DataInvio
	--	else DataAggiudicazione 
	--	end as DataChiusura
	,d.Azienda as StazioneAppaltante
	, case 
		when d.TipoDoc = 'BANDO_SEMPLIFICATO'   then  b.DataScadenzaOffIndicativa 
		when d.TipoDoc = 'BANDO_GARA'   then  b.DataScadenzaOfferta 
		else  b.DataScadenzaOfferta 
		end as 	ScadenzaTerminiBando
	,dbo.getclassiIscrizListaAlbi(ListaAlbi) as ClasseIscriz_Bando

	--, h1.Value as BaseCalcolo
	--, h2.Value as RilancioMinimo
	--, h3.Value as AutoExt
	--, h4.Value as Ext
	--, h5.Value as TipoExt
	--, h6.Value as TipoAsta
	
	
	, asta.BaseCalcolo
	, asta.RilancioMinimo
	, asta.AutoExt
	, asta.Ext
	, asta.TipoExt
	, asta.TipoAsta
	
	,asta.StatoAsta
	,asta.DataScadenzaAsta
	,asta.DataInizio
	,asta.DataScadOrig as DataChiusura

from CTL_DOC d
	inner join Document_Bando b on d.id = b.idheader
	inner join Document_asta asta on d.id = asta.idheader
	inner join profiliutente p on d.idpfu = p.idpfu
	left join marketplace m on m.mpidazimaster = p.pfuidazi
	left outer join CTL_DOC_Value v1 on b.idheader = v1.idheader and v1.dzt_name = 'ArtClasMerceologica' and v1.DSE_ID = 'ATTI'
	left outer join CTL_DOC_Value v2 on b.idheader = v2.idheader and v2.dzt_name = 'UserRUP' and v2.DSE_ID = 'InfoTec_comune'
	
	-- PDA
	left outer join CTL_DOC pda on pda.linkeddoc = d.id and pda.deleted = 0 and pda.TipoDoc = 'PDA_MICROLOTTI'

	-- comunicazione di aggiudicazione
	left outer join (  select min(datainvio ) as DataAggiudicazione , LinkedDoc 
							from CTL_DOC 
							where JumpCheck like '%ESITO_DEFINITIVO_MICROLOTTI' and TipoDoc in ('PDA_COMUNICAZIONE_GENERICA') and deleted=0 and StatoFunzionale='Inviato' 
							group by LinkedDoc
					) as dc on dc.LinkedDoc = pda.id

	-- REVOCA
	left outer join ctl_doc rev on rev.tipodoc = 'REVOCA_BANDO' and rev.deleted = 0 and rev.LinkedDoc = d.id

		--left outer join CTL_DOC_Value h1 on b.idheader = h1.idheader and h1.dzt_name = 'BaseCalcolo' and h1.DSE_ID = 'HIDE'
		--left outer join CTL_DOC_Value h2 on b.idheader = h2.idheader and h2.dzt_name = 'RilancioMinimo' and h2.DSE_ID = 'HIDE'
		--left outer join CTL_DOC_Value h3 on b.idheader = h3.idheader and h3.dzt_name = 'AutoExt' and h3.DSE_ID = 'HIDE'
		--left outer join CTL_DOC_Value h4 on b.idheader = h4.idheader and h4.dzt_name = 'Ext' and h4.DSE_ID = 'HIDE'
		--left outer join CTL_DOC_Value h5 on b.idheader = h5.idheader and h5.dzt_name = 'TipoExt' and h5.DSE_ID = 'HIDE'
		--left outer join CTL_DOC_Value h6 on b.idheader = h6.idheader and h6.dzt_name = 'TipoAsta' and h6.DSE_ID = 'HIDE'









GO
