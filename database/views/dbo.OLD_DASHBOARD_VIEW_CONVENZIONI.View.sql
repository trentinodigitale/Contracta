USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_CONVENZIONI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE   view [dbo].[OLD_DASHBOARD_VIEW_CONVENZIONI] as


--select  
--	DC.ID, 
--	ISNULL(DC.DOC_Owner,C.idpfu) as DOC_Owner, 
--	c.titolo as DOC_Name, 
--	DC.DataCreazione, 
--	c.protocollo as Protocol, 
--	cast(DC.DescrizioneEstesa as nvarchar(max)) AS DescrizioneEstesa,
--	DC.StatoConvenzione, 
--	DC.AZI, 
--	DC.Plant, 
--	DC.Deleted, 
--	DC.AZI_Dest, 
--	DC.NumOrd, 
--	DC.Imballo, 
--	DC.Resa, 
--	DC.Spedizione, 
--	DC.Pagamento, 
--	DC.Valuta, 
--	DC.Total, 
--	DC.Completo,
--	DC.Allegato, 
--	DC.Telefono, 
--	DC.Compilatore, 
--	DC.RuoloCompilatore, 
--	DC.TipoOrdine, 
--	DC.SendingDate, 
--	DC.ProtocolloBando, 
--	DC.DataInizio, 
--	DC.DataFine, 
--	DC.Merceologia, 
--	DC.TotaleOrdinato, 
--	DC.IVA, 
--	DC.NewTotal, 
--	DC.RicPropBozza, 
--	DC.ConvNoMail, 
--	DC.QtMinTot, 
--	DC.RicPreventivo, 
--	DC.TipoImporto, 
--	DC.TipoEstensione, 
--	'1' as RichiediFirmaOrdine	,
--	--DC.ID as LinkedDoc, 
--	c.LinkedDoc,
--	isnull( DC.Total , 0 ) - isnull( DC.TotaleOrdinato , 0 ) as BDG_TOT_Residuo
--	,isnull( DC.Total , 0 ) - ISNULL(AL2.ImportoAllocabile,0) as ImportoAllocabile
--	, DC.IdRow
--	,DC.DataProtocolloBando
--	,CAST(DC.OggettoBando AS nvarchar(max)) as OggettoBando
--	,DC.Mandataria
--	,DC.ProtocolloListino
--	,DC.dataListino
--	,DC.statoListino
--	,DC.ProtocolloContratto
--	,DC.ReferenteFornitore
--	,DC.CodiceFiscaleReferente
--	,DC.ReferenteFornitoreHide
--	,DC.Ambito
--	,DC.GestioneQuote
--	,ISNULL(DC.NotEditable,'') as NotEditable
--	,DC.DataContratto
--	,DC.StatoContratto
--	,c.idpfu
--	,c.titolo
--	,c.protocollo
--	,c.datainvio
--	,c.StatoFunzionale 
--	,c.tipodoc
--	,DC.IdentificativoIniziativa
--	,cast(DC.DescrizioneIniziativa as nvarchar(max)) as DescrizioneIniziativa
--	,DC.DataStipulaConvenzione
--	,DC.RichiestaFirma
--	,DC.CIG_MADRE
--	,C.protocollogenerale
--	,C.Dataprotocollogenerale
--	,DC.TipoConvenzione
--	,DC.ConAccessori
--	,DC.ImportoMinimoOrdinativo
--	,DC.OrdinativiIntegrativi
--	,DC.TipoScadenzaOrdinativo
--	,DC.NumeroMesi
--	,DC.DataScadenzaOrdinativo
--	,year(DC.DataInizio) as Anno_inizio_convenzione
--	,c1.value as Appalto_Verde
--	,c2.value as Acquisto_Sociale
--	,DC.Macro_Convenzione
--	,C.JumpCheck
--	, case DC.Total
--		when 0 then null
--		else (DC.TotaleOrdinato/DC.Total)*100 
--	  end
--		as PercErosione
--	, 'CONVENZIONE_IMPORTI' as OPEN_DOC_NAME
--	--, year (c.datainvio) as AnnoPubConvenzione
--	, year (DC.DataInizio) as AnnoPubConvenzione
--	, year (dc.datafine) as AnnoScadConvenzione
--	,p.pfuidazi as azienda
--	,DC.mandataria as destinatario_azi
--	,c.Note  
--	,'' as DataChiusuraTecnical
--	,'' as Object
	
--	,c.id as idConvenzione
--	, model.value as idModello
--	, P2.IdPfu as Owner
--	, dc.EvidenzaPubblica
--	, DC.Stipula_in_forma_pubblica
--	--, GARA.datainvio as DataPubblicazioneBando 
--	, DC.PossibilitaRinnovo
--	, DC.UserRUP
--	, DC.ConvenzioniInUrgenza
--	, DC.AllegatoDetermina 	
--	, DC.StatoListinoOrdini
-- from 
--	ctl_doc c with(nolock) 
--		inner join Document_Convenzione DC with(nolock) on C.id=DC.id	
--		left join CTL_DOC_Value model with(nolock) ON model.IdHeader = c.id and model.dse_id = 'TESTATA_PRODOTTI' and model.DZT_Name = 'id_modello' and isnull(model.value,'') <> ''
	
--		left outer join (

--				Select sum(Importo) as ImportoAllocabile,LinkedDoc
--					from CTL_DOC with(nolock)
--						inner join Document_Convenzione_Quote with(nolock) on id = idheader
--					where StatoDoc = 'Sended' and TipoDoc='QUOTA' 
--					group by (LinkedDoc)

--			) as AL2 on AL2.LinkedDoc = DC.id

--		 left join ctl_doc_value c1  with(nolock) on C1.idheader=c.id and c1.DSE_ID='INFO_AGGIUNTIVE' and c1.DZT_Name='Appalto_Verde'
--		 left join ctl_doc_value c2  with(nolock) on C2.idheader=c.id and c2.DSE_ID='INFO_AGGIUNTIVE' and c2.DZT_Name='Acquisto_Sociale'
--		 left join profiliUtente P  with(nolock) on P.idpfu=c.idpfu --and P.pfudeleted=0
--		 inner join ProfiliUtente P2 with(nolock) on P2.pfuIdAzi=p.pfuidazi and P2.pfudeleted=0

--where DC.Deleted = 0 and C.Deleted = 0 and C.tipodoc='CONVENZIONE'


select 
	S.*,
		p.pfuidazi as azienda ,
		P2.IdPfu as Owner

	from 
		DASHBOARD_VIEW_CONVENZIONI_SUB S
			left join profiliUtente P  with(nolock) on P.idpfu=S.idpfu 
			inner join ProfiliUtente P2 with(nolock) on P2.pfuIdAzi=p.pfuidazi and P2.pfudeleted=0
			--restituisco le convenzioni solo se l'utente ha il profilo GestoreNegoziElettro
			inner join ProfiliUtenteAttrib PU  with (nolock) on PU.dztNome ='Profilo' and
							PU.idpfu = P2.idpfu and PU.attValue ='GestoreNegoziElettro'

union

select 
	S.*,
		p.pfuidazi as azienda ,
		P2.IdPfu as Owner
	from 
		DASHBOARD_VIEW_CONVENZIONI_SUB S
			left join profiliUtente P  with(nolock) on P.idpfu=S.idpfu 
			inner join ProfiliUtente P2 with(nolock) on P2.pfuIdAzi=p.pfuidazi and P2.pfudeleted=0
			--restituisco le convenzioni solo se l'utente ha il profilo GestoreConvenzioni
			inner join ProfiliUtenteAttrib PU  with (nolock) on PU.dztNome ='Profilo' and
							PU.idpfu = P2.idpfu and PU.attValue ='GestoreConvenzioni' 
	
		
union

--per dare la visibilità ai referenti tecnici della convenzione
select  

	S.*,
		p.pfuidazi as azienda ,
		RT.IdPfu as Owner
	from
		DASHBOARD_VIEW_CONVENZIONI_SUB S
			left join profiliUtente P  with(nolock) on P.idpfu=S.idpfu 
			inner join document_bando_riferimenti RT with(nolock) on RT.idHeader = s.id 
													and RT.RuoloRiferimenti ='ReferenteTecnico'
			
			
	 





GO
