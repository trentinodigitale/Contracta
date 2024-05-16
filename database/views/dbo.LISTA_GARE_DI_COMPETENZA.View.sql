USE [AFLink_TND]
GO
/****** Object:  View [dbo].[LISTA_GARE_DI_COMPETENZA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[LISTA_GARE_DI_COMPETENZA] AS

	----------------------------------------------------------------------------------------------
	-- BANDO_GARA / BANDO_SEMPLIFICATO IN CUI FIGURA COME RUP O COME PRESIDENTE DI COMMISSIONE ---
	----------------------------------------------------------------------------------------------
	select distinct 
				a.id as idDoc, a.tipoDoc,
				--case when a.TipoDoc = 'BANDO_GARA' then dbo.cnv('Avvisi_Bandi_Inviti','I') else dbo.cnv('Bando Semplificato','I') end AS NomeDocumento, 
				ISNULL(cast(ml_description as nvarchar(MAX)),DV.CaptionDoc) AS NomeDocumento,				
				a.protocollo, a.titolo, a.DataInvio, a.StatoFunzionale, cast(rup.Value as int) as UserRUP, us.UtenteCommissione, 0 as userRif , a.Fascicolo
		from ctl_doc a with(nolock)

				left join ctl_doc_value rup with(nolock) on a.id = rup.idHeader and  rup.dzt_name = 'UserRup' and rup.dse_id = 'InfoTec_comune'

				left join ctl_doc co with(nolock) ON co.LinkedDoc = a.ID and co.tipodoc = 'COMMISSIONE_PDA' and co.Deleted = 0 and co.statofunzionale = 'Pubblicato'
				left join Document_CommissionePda_Utenti us with(nolock) ON us.idheader = co.id /*and us.TipoCommissione = 'A'*/ and us.ruolocommissione='15548'
				inner join Document_Bando_Semplificato_view DV on dv.Id=a.id
				left join LIB_Multilinguismo with(nolock) on DV.CaptionDoc=ML_KEY and ML_LNG='I'

		where a.tipodoc in ( 'BANDO_GARA', 'BANDO_SEMPLIFICATO' ) and a.deleted = 0 and a.statofunzionale not in ('InLavorazione','InApprove','Annullato','Rifiutato','NEW_SEMPLIFICATO')

	UNION ALL

	--------------------------------------------------------------------------------------
	-- BANDO_FABBISOGNI / QUESTIONARIO_FABBISOGNI DOVE LUI FIGURA A QUALUNQUE TITOLO  ----
	--------------------------------------------------------------------------------------

	select distinct a.id as idDoc, a.tipoDoc, case when a.tipodoc = 'BANDO_FABBISOGNI' then dbo.cnv('Richiesta Fabbisogni','I')
												   when a.tipodoc = 'QUESTIONARIO_FABBISOGNI' then dbo.cnv('Questionario Fabbisogni','I')
												   when a.tipodoc = 'SUB_QUESTIONARIO_FABBISOGNI' then dbo.cnv('Sub Questionario Fabbisogni','I')
												   when a.tipodoc = 'ANALISI_FABBISOGNI' then dbo.cnv('Analisi Richiesta dei Fabbisogni','I')
											   end  AS NomeDocumento, a.protocollo, a.titolo, a.DataInvio, a.StatoFunzionale, a.idpfu as UserRUP, a.idPfuInCharge as UtenteCommissione, rif.idPfu as userRif , Fascicolo
		from ctl_doc a with(nolock)
			left join Document_Bando_Riferimenti  rif with(nolock) on rif.idHeader = a.id
		--where a.tipodoc in ('BANDO_FABBISOGNI','QUESTIONARIO_FABBISOGNI','SUB_QUESTIONARIO_FABBISOGNI','ANALISI_FABBISOGNI') and a.deleted = 0 and a.statofunzionale not in ('InLavorazione','InApprove','Annullato','Rifiutato')
							-- QUESTIONARIO ?
	   where 
		   (
			 ( a.tipodoc = 'BANDO_FABBISOGNI' and a.statofunzionale not in ('InLavorazione','InApprove','Annullato','Rifiutato') )
			 OR
			 (  a.tipodoc in ('QUESTIONARIO_FABBISOGNI','SUB_QUESTIONARIO_FABBISOGNI','ANALISI_FABBISOGNI') and a.statofunzionale not in ('InApprove','Annullato','Rifiutato') )
		   )
		   and a.deleted = 0 

	UNION ALL

	--------------------------------------------------------------------------------------
	-- CONVENZIONI DOVE LUI FIGURA COME GESTORE DELLA CONVENZIONE ----
	--------------------------------------------------------------------------------------
	select distinct a.id as idDoc, a.tipoDoc,  dbo.cnv('Convenzione','I')  AS NomeDocumento, a.protocollo, a.titolo, a.DataInvio, a.StatoFunzionale, 0 as UserRUP, 0 as UtenteCommissione, a.IdPfu as userRif , a.Fascicolo
		from ctl_doc a with(nolock)
			inner join Document_Convenzione dc with(nolock) on dc.id=a.id
		where a.tipodoc in ( 'CONVENZIONE' ) and a.deleted = 0 and ( a.statofunzionale not in ('InApprove','Annullato','InLavorazione') or ( a.StatoFunzionale='InLavorazione' and ( ISNULL(dc.StatoContratto,'')<>'' or  ISNULL(dc.StatoListino,'')<>'') ) )
	
	UNION ALL

	---select distinct StatoFunzionale from ctl_doc where tipodoc='ODC'-----------------------------------------------------------------------------------
	-- ordinativi dove l'utente figura come PO oppure come compilatore esclusi quelli "in lavorazione" e gli "annullati" ----
	--------------------------------------------------------------------------------------
	select distinct a.id as idDoc, a.tipoDoc,  dbo.cnv('Ordinativo di fornitura','I')  AS NomeDocumento, a.protocollo, a.titolo, a.DataInvio, a.StatoFunzionale, 
			
			
			O.UserRUP as UserRUP, 
			
			0 as UtenteCommissione, 
			
			--se esiste subentro considero l'utente subentrato come titolare del documento
			case 
				when S.IdRow is null then a.IdPfu else S.value
			end as userRif

		, a.Fascicolo
		from ctl_doc a with(nolock)
			inner join Document_ODC O with(nolock) on a.id=O.RDA_ID
			left join ctl_doc_value S with(nolock) on S.idheader=O.RDA_ID and DSE_ID='Subentro' and DZT_Name='Subentro' 
		where a.tipodoc in ( 'ODC' ) and a.deleted = 0 and  a.statofunzionale not in ('Annullato','InLavorazione')
	UNION ALL

	----------------------------------------------------------------------------------------------
	-- ALBI/SDA IN CUI FIGURA COME RUP O COME RIFERIMENTO QUESITI/ISTANZE ---
	----------------------------------------------------------------------------------------------
	select distinct 
			a.id as idDoc, 
			a.tipoDoc, 
			case 
				when a.TipoDoc = 'BANDO' and ISNULL(a.JumpCheck,'') = '' then dbo.cnv('Procedura Iscrizione Albo','I') 				
				when a.TipoDoc = 'BANDO' and ISNULL(a.JumpCheck,'') = 'BANDO_ALBO_LAVORI' then dbo.cnv('Bando Istitutivo Lavori Pubblici','I') 				
				when a.TipoDoc = 'BANDO' and ISNULL(a.JumpCheck,'') = 'BANDO_ALBO_PROFESSIONISTI' then dbo.cnv('Bando Albo Professionisti','I') 				
				when a.TipoDoc = 'BANDO' and ISNULL(a.JumpCheck,'') = 'BANDO_ALBO_FORNITORI' then dbo.cnv('Bando Albo Fornitori','I') 				
				when a.TipoDoc = 'BANDO_SDA'  then dbo.cnv('Bando SDA','I') 	
				else 'Bando'			
			end AS NomeDocumento, 
			a.protocollo, a.titolo, a.DataInvio, a.StatoFunzionale, 
			cast(rup.idpfu as int) as UserRUP, 0 as UtenteCommissione, userRif.idPfu as userRif , a.Fascicolo
		from ctl_doc a with(nolock)
			Inner join Document_Bando_Commissione rup with(nolock) on rup.idHeader=a.id and rup.RuoloCommissione='15550'
			Inner join Document_Bando_Riferimenti userRif with(nolock) on userRif.idHeader=a.id and userRif.RuoloRiferimenti in ('Quesiti','Istanze')				
		where a.tipodoc in ( 'BANDO','BANDO_SDA' ) and a.deleted = 0 and a.statofunzionale not in ('InLavorazione','InApprove','Annullato','Revocato','Variato')

	--UNION ALL

	--LA LASCIO PER RENDERE LA VISTA COMPATIBILE CON EMPULIA
	--select idmsg as idDoc, 'DOCUMENTO_GENERICO' AS tipoDoc, case when f.iSubType = 68 then 'Richiesta di Preventivo' else 'Gare lotto unico' end as NomeDocumento, ProtocolloOfferta as protocollo, name as titolo, ReceivedDataMsg as DataInvio, 'Inviato' as StatoFunzionale, idmittente as UserRUP, 0 as UtenteCommissione, 0 as userRif , ProtocolBG as Fascicolo
	--	from TAB_MESSAGGI_FIELDS f with(nolock)
	--			INNER JOIN TAB_UTENTI_MESSAGGI um WITH(NOLOCK) ON um.umIdMsg  = f.idmsg
	--	where f.iSubType in ( 48, 68, 167 ) and UM.umStato = 0 AND UM.umInput = 0 and F.Stato='2'






GO
