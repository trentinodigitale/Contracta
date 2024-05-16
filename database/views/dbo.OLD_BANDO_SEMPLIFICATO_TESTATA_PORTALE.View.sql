USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_BANDO_SEMPLIFICATO_TESTATA_PORTALE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





create view [dbo].[OLD_BANDO_SEMPLIFICATO_TESTATA_PORTALE] as

select  d.* ,

	s.idRow, s.idHeader, s.SoggettiAmmessi, s.ImportoBando, s.MaxNumeroIniziative, s.MaxFinanziabile, s.dataCreazione, s.DataEstenzioneInizio, s.DataEstenzioneFine, s.FAX, s.DataRiferimentoInizio, s.DataRiferimentoFine, s.DataPresentazioneRisposte, s.StatoBando, s.Ufficio, s.NumeroBUR, s.DataBUR, s.dgrN, s.dgrDel, s.TipoBando, s.TipoAppalto, s.RichiestaQuesito, s.ReceivedQuesiti, s.RecivedIstanze, s.MotivoEstensionePeriodo, s.ClasseIscriz, s.RichiediProdotti, s.ProceduraGara, s.TipoBandoGara, s.CriterioAggiudicazioneGara, s.ImportoBaseAsta, s.Iva, s.ImportoBaseAsta2, s.Oneri, s.CriterioFormulazioneOfferte, s.CalcoloAnomalia, s.OffAnomale, s.NumeroIndizione, s.DataIndizione, s.gg_QuesitiScadenza, s.DataTermineQuesiti, s.ClausolaFideiussoria, s.VisualizzaNotifiche, s.CUP, s.CIG, s.GG_OffIndicativa, s.HH_OffIndicativa, s.MM_OffIndicativa, s.DataScadenzaOffIndicativa, s.GG_Offerta, s.HH_Offerta, s.MM_Offerta, s.DataScadenzaOfferta, s.GG_PrimaSeduta, s.HH_PrimaSeduta, s.MM_PrimaSeduta, s.DataAperturaOfferte, s.TipoAppaltoGara, s.ProtocolloBando, s.DataRevoca, s.Conformita, s.Divisione_lotti, s.NumDec, s.DirezioneEspletante, s.DataProtocolloBando, s.ModalitadiPartecipazione, s.TipoIVA, s.EvidenzaPubblica, s.Opzioni, s.Complex, s.RichiestaCampionatura, s.TipoGiudizioTecnico, s.TipoProceduraCaratteristica, s.GeneraConvenzione, s.ListaAlbi, s.Appalto_Verde, s.Acquisto_Sociale, s.Motivazione_Appalto_Verde, s.Motivazione_Acquisto_Sociale, s.Riferimento_Gazzetta, s.Data_Pubblicazione_Gazzetta, s.BaseAstaUnitaria, s.IdentificativoIniziativa, s.DataTermineRispostaQuesiti, s.TipoSceltaContraente, s.TipoAccordoQuadro, s.TipoAggiudicazione, s.RegoleAggiudicatari, s.TipologiaDiAcquisto, s.Merceologia, s.CPV 

	,	b.Body as DescrizioneRichiesta
	, v2.Value as UserRUP
	,BS.RichiediProdotti as  RichiediProdottiSDA
	, 
		case 
			when d.StatoFunzionale='InApprove'  then
				case 
					when s.gg_QuesitiScadenza <> 0 then ' DataTermineQuesiti  DataScadenzaOfferta  DataAperturaOfferte  DataScadenzaOffIndicativa TipoIVA DataTermineQuesiti  Altro '
					else '  DataScadenzaOfferta  DataAperturaOfferte DataScadenzaOffIndicativa TipoIVA DataTermineQuesiti Altro '
				end 
			when d.StatoFunzionale='ProntoPerInviti' then '  DataTermineQuesiti  DataScadenzaOffIndicativa  '
			else '' 
		end 

		+ case when isnull(s.IdentificativoIniziativa,'') = '9999' and pu.pfuIdAzi <> 35152001 then ' IdentificativoIniziativa ' else '' end

		as NotEditable

	, pda.id as idpda
	
	,case
		when d.statofunzionale = 'Revocato' then 'chiuso'
		when d.statodoc = 'Saved' then ''

		when getdate() <= s.DataScadenzaOfferta and d.TipoDoc = 'BANDO_GARA' then 'aperto'
		when getdate() <= s.DataScadenzaOffIndicativa and d.TipoDoc = 'BANDO_SEMPLIFICATO' then 'aperto'

		when getdate() > s.DataScadenzaOfferta and getdate() <= isnull( DataAggiudicazione , '3000-12-31' ) and  d.TipoDoc = 'BANDO_GARA'  then 'incorso'
		when getdate() > s.DataScadenzaOffIndicativa and getdate() <= isnull( DataAggiudicazione , '3000-12-31' ) and  d.TipoDoc = 'BANDO_SEMPLIFICATO'  then 'incorso'

		when getdate() > isnull( s.DataChiusura , '3000-12-31' ) then 'chiuso'
		else ''
	end as StatoProcedura

	--,'' as StatoProcedura

	, case 		when d.statofunzionale = 'Revocato' and s.DataChiusura is null then rev.DataInvio
				when d.statofunzionale = 'InEsame' and s.DataChiusura is null then DataAggiudicazione
				else s.DataChiusura  
	   end as DataChiusura

	, d.Azienda as StazioneAppaltante
	,case when ISNULL(rev2.statofunzionale,'') = 'Approved' then 'si' else 'no' end as BANDO_REVOCATO

	,coalesce(am.value,cod.Value,'')  as Ambito

	,cvcat.value as elenco_categorie_sda
	, criterio_scelt.value as Criteriio_scelta_fornitori
	, elenco_cat.value as Categorie_Merceologiche
	,s.Num_max_lotti_offerti

from CTL_DOC  d  with(nolock)
		inner join dbo.Document_Bando s with(nolock) on id = idheader
		left join profiliutente pu  with(nolock) on pu.idpfu = d.idpfu 
		inner join CTL_DOC b  with(nolock) on b.id = d.linkedDoc
		inner join dbo.Document_Bando BS  with(nolock) on BS.idheader=B.id
		left outer join CTL_DOC_Value v2  with(nolock) on s.idheader = v2.idheader and v2.dzt_name = 'UserRUP' and v2.DSE_ID = 'InfoTec_comune'


		-- PDA
		left outer join CTL_DOC pda  with(nolock) on pda.linkeddoc = d.id and pda.deleted = 0 and pda.TipoDoc = 'PDA_MICROLOTTI'

		-- comunicazione di aggiudicazione
		left outer join (  select min(datainvio ) as DataAggiudicazione , LinkedDoc 
								from CTL_DOC 
								where JumpCheck like '%ESITO_DEFINITIVO_MICROLOTTI' and TipoDoc in ('PDA_COMUNICAZIONE_GENERICA') and deleted=0 and StatoFunzionale='Inviato' 
								group by LinkedDoc
						) as dc on dc.LinkedDoc = pda.id

		-- REVOCA SEMP
		left outer join ctl_doc rev  with(nolock) on rev.tipodoc = 'REVOCA_BANDO' and rev.deleted = 0 and rev.LinkedDoc = d.id

		-- REVOCA SDA
		left outer join ctl_doc rev2  with(nolock) on rev2.tipodoc = 'REVOCA_BANDO' and rev2.deleted = 0 and rev2.LinkedDoc = d.linkeddoc and rev2.statofunzionale = 'Approved'

		--- id modello associato al semplificato per recuperare l'ambito
		left outer join CTL_DOC_Value idmod  with(nolock) on idmod.idheader = s.idheader and idmod.dzt_name = 'id_modello' and idmod.DSE_ID = 'TESTATA_PRODOTTI'
		left outer join ctl_doc_value cod  with(nolock) on cod.idHeader = idmod.Value  and  cod.dzt_name = 'MacroAreaMerc' and cod.dse_id = 'AMBITO' 

		--- recupero le categorie merceologiche selezionate sullo sda
		left outer join ctl_doc_value cvcat  with(nolock) on  cvcat.idHeader=d.linkeddoc and  cvcat.dzt_name = 'Categorie_Merceologiche' and cvcat.dse_id = 'TESTATA_PRODOTTI' 
		left outer join CTL_DOC_Value elenco_cat  with(nolock) on s.idheader = elenco_cat.idheader and elenco_cat.dzt_name = 'Categorie_Merceologiche' and elenco_cat.DSE_ID = 'TESTATA_PRODOTTI'
		left outer join CTL_DOC_Value criterio_scelt  with(nolock) on s.idheader = criterio_scelt.idheader and criterio_scelt.dzt_name = 'Criteriio_scelta_fornitori' and criterio_scelt.DSE_ID = 'TESTATA_PRODOTTI'

		left outer join CTL_DOC_Value am  with(nolock) on am.idheader = d.id and am.DSE_ID = 'TESTATA_PRODOTTI' and am.DZT_Name = 'Ambito'










GO
