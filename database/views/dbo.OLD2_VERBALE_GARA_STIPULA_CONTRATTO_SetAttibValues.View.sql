USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_VERBALE_GARA_STIPULA_CONTRATTO_SetAttibValues]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE VIEW [dbo].[OLD2_VERBALE_GARA_STIPULA_CONTRATTO_SetAttibValues] as
	select
		
		CONTR.id
		,GARA.id as IdBando
		, GARA_DETT.cig as Gara_CIG
		, cast(ISNULL(GARA.Body,'') as nvarchar(MAX)) as Gara_Body
		, GARA_DETT.CUP as Gara_CUP 
		, GARA_DETT.Divisione_lotti
		, A.aziRagioneSociale as NomeEnteAggiudicatrice
		, A.aziRagioneSociale
		--, replace(a.aziPartitaIVA,'IT','') as CodiceFiscaleAggiudicatrice
		, isnull(A1.vatValore_FV,'') as  CodiceFiscaleAggiudicatrice
		--, GARA_DETT.IdentificativoIniziativa as  NomeUfficio
		, A.aziIndirizzoLeg + ' ' + A.aziProvinciaLeg  as IndirizzoUfficio
		, A.aziTelefono1 + ' / ' + A.azifax as TelefonoFaxUfficio
		, isnull(C1.value,'') as CodiceUnivocoUfficio
		, p1.pfuNome as RupProponente
		 --C2.value  as RupEspletante
		, P2.pfuNome as RupEspletante
		, isnull(C3.value,'') as FirmatarioContratto
		--, OE.idazi 
		, isnull(OD.Value , OE.aziRagioneSociale) as RagioneSociale_OE
		, replace(OE.aziPartitaIVA,'IT','')  as  PartitaIva_OE
		, isnull(OE1.vatValore_FV,'') as  CodiceFiscale_OE
		, OE.aziIndirizzoLeg + ' ' + OE.aziProvinciaLeg  as  SedeLegale_OE
		, OE.aziTelefono1 as Telefono_OE
		, OE.aziE_Mail as  PostaElettronica_OE
		, FormaSoc.dscTesto as TipologiaImpresa_OE
		, isnull(OE2.vatValore_FV,'') as NumeroIscrizioneRea
		, isnull(OE3.vatValore_FV,'')  as AnnoIscrizioneRea
		, isnull(OE4.vatValore_FV,'')  as SedeIscrizioneRea
		, isnull(C4.value,'') as ProtocolloOfferta
		, convert( varchar(19), cast( isnull(C5.value,'') as datetime) ,103) +  ' ' + convert( varchar(19), cast( isnull(C5.value,'') as datetime) ,108)  as DataOfferta
		, convert( varchar(19), getdate() ,103)  as GiornoCorrente
		, case 
				when CriterioFormulazioneOfferte = '15537' then 'Ribasso  (%)' 
				when CriterioFormulazioneOfferte = '15536' then 'Valore Economico (Euro)'
		  end as FormulazioneOfferta
		, isnull(C6.value,'') as PresenzaListino 
		, CriterioFormulazioneOfferte
		, isnull(C7.Value,'') as Subappalto_dichiarato_in_offerta
		, case isnull(C8.Value,'')
			when '' then ''
			else dbo.FormatFloat_Virgola ( isnull(C8.Value,'') )  
		  end as Parti_Subappaltabili
		 , case isnull(C9.Value,'')
			when '' then ''
			else dbo.FormatFloat_Virgola ( isnull(C9.Value,'') )  
		  end as Valore_Contratto
	from 
		ctl_doc CONTR with(nolock) 
			inner join CTL_DOC COM with(nolock)   on COM.id=CONTR.LinkedDoc and COM.Deleted =0
			inner join ctl_doc PDA with (nolock)  on PDA.id=COM.LinkedDoc and PDA.TipoDoc='PDA_MICROLOTTI' and PDA.Deleted=0
			inner join  CTL_DOC GARA with(nolock) on GARA.id=PDA.LinkedDoc and GARA.TipoDoc in ('BANDO_GARA' , 'BANDO_SEMPLIFICATO')
			inner join CTL_DOC_VALUE C2 with(nolock) on C2.IdHeader = GARA.id and C2.dse_id='InfoTec_comune' and C2.DZT_Name ='UserRUP'
			inner join profiliutente P2 with (nolock) on C2.value=P2.idpfu 
			inner join  Document_bando GARA_DETT with(nolock) on GARA_DETT.idHeader=GARA.id
			inner join profiliutente P1 with (nolock) on GARA_DETT.RupProponente=P1.idpfu 
			inner join Aziende A with(nolock) on A.IdAzi=CONTR.Azienda
			left join DM_ATTRIBUTI A1 with(nolock) on A1.lnk = A.IdAzi and A1.dztNome = 'codicefiscale'
			left join CTL_DOC_VALUE C1 with(nolock) on C1.IdHeader = CONTR.id and C1.dse_id='CONTRATTO' and c1.DZT_Name ='CodiceIPA'
			left join CTL_DOC_VALUE C3 with(nolock) on C3.IdHeader = CONTR.id and C3.dse_id='CONTRATTO' and c3.DZT_Name ='firmatario'
			left join CTL_DOC_VALUE C4 with(nolock) on C4.IdHeader = CONTR.id and C4.dse_id='DOCUMENT' and C4.DZT_Name ='ProtocolloOfferta'
			
			left join ctl_doc O with (nolock) on O.Protocollo = C4.value and O.TipoDoc ='OFFERTA'
			left join CTL_DOC_Value OD with (nolock) on OD.idheader=O.Id and OD.DSE_ID='TESTATA_RTI' and OD.DZT_Name ='DenominazioneATI'

			left join CTL_DOC_VALUE C5 with(nolock) on C5.IdHeader = CONTR.id and C5.dse_id='DOCUMENT' and C5.DZT_Name ='DataRisposta'
			left join CTL_DOC_VALUE C6 with(nolock) on C6.IdHeader = CONTR.id and C6.dse_id='CONTRATTO' and C6.DZT_Name ='PresenzaListino'
			left join CTL_DOC_VALUE C7 with(nolock) on C7.IdHeader = CONTR.id and C7.dse_id='CONTRATTO' and C7.DZT_Name ='Sub_Dichiarato_InOfferta'
			left join CTL_DOC_VALUE C8 with(nolock) on C8.IdHeader = CONTR.id and C8.dse_id='CONTRATTO' and C8.DZT_Name ='Parti_Subappaltabili'
			left join CTL_DOC_VALUE C9 with(nolock) on C9.IdHeader = CONTR.id and C9.dse_id='CONTRATTO' and C9.DZT_Name ='NewTotal'

			inner join Aziende OE with(nolock) on OE.IdAzi=CONTR.Destinatario_Azi
			inner join tipidatirange with(nolock) on tdridtid = 131 and tdrCodice =  OE.aziIdDscFormaSoc
			inner join DescsI FormaSoc with(nolock) on  tdrIdDsc= IdDsc
			left join DM_ATTRIBUTI OE1 with(nolock) on OE1.lnk = OE.IdAzi and OE1.dztNome = 'codicefiscale'
			left join DM_ATTRIBUTI OE2 with(nolock) on OE2.lnk = OE.IdAzi and OE2.dztNome = 'IscrCCIAA'
			left join DM_ATTRIBUTI OE3 with(nolock) on OE3.lnk = OE.IdAzi and OE3.dztNome = 'AnnoIscrCCIAA'
			left join DM_ATTRIBUTI OE4 with(nolock) on OE4.lnk = OE.IdAzi and OE4.dztNome = 'SedeCCIAA'

	where
		CONTR.tipodoc='CONTRATTO_GARA' and CONTR.Deleted =0
GO
