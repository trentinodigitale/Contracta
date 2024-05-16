USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_REPORT_LISTA_RDO_ENTE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD_DASHBOARD_VIEW_REPORT_LISTA_RDO_ENTE]  as 

	SELECT 
		ow.idpfu as Owner
		,d.id  
		--  dmstrLiv1.DMV_DescML + ' / ' + dmstrLiv2.DMV_DescML              AS [TipodiAmministrazione]
		--, a.aziRagioneSociale                                                AS Ente 
		--, a.aziRagioneSociale                                                
		, d.azienda  as AZI_Ente

		, p.pfuLogin                                                         AS pfuLogin
	 
		, REPLACE(REPLACE(d.Titolo , ';', ' '), CHAR(13) + CHAR(10) , '')  AS Titolo
		, REPLACE(REPLACE(CAST(d.Body AS nVARCHAR(max)), ';', ' '), CHAR(13) + CHAR(10), '')		
																	AS Oggetto 
		--, CAST(ml_Description AS VARCHAR(MAX))                             AS [CriterioAggiudicazione]
		--,isnull( V.CriterioAggiudicazioneGara ,db.CriterioAggiudicazioneGara ) as CriterioAggiudicazioneGara
		,isnull( V.value ,db.CriterioAggiudicazioneGara ) as CriterioAggiudicazioneGara

		, ni.NUmeroInvitati                                                AS [NumeroInvitati]
		, d.StatoFunzionale                                                AS StatoFunzionale
		, d.Protocollo                                                     AS Registro 
		, d.Fascicolo
		, REPLACE(REPLACE(CAST(d.Note AS  VARCHAR(150)), ';', ' '), CHAR(13) + CHAR(10), '')
																	AS Note 
		, d.DataInvio                                                      AS [DataInvio]
		, convert( varchar(10) , d.DataInvio , 121 )						AS [DataInvioAl]
		, DataScadenzaOfferta                                              AS [DataScadenzaOfferta]
		, convert( varchar(10) , DataScadenzaOfferta , 121 )				AS [DataScadenzaA]
		, ImportoBaseAsta2                                                 AS [ImportoBaseAsta2]
		, CASE 
			WHEN sp.Fascicolo IS NOT NULL --or ( db.Divisione_lotti = '0' and sp.id is not null )
				THEN 'Stipula Contratto'
			WHEN ed.Fascicolo IS NOT NULL --or ( db.Divisione_lotti = '0' and ed.id is not null )
				THEN 'Esito Definitivo'
				ELSE ''
			END                                                             AS [Aggiudicazione]
		, case when ed.Fascicolo IS NOT NULL then 1 else 0 end as IsAggiudicato
		, isnull( lb.NumeroLotto , '0' )									AS [NumeroLotto]
		--, COALESCE(dsp.NumeroLotto, ced.Numerolotto, '0')                 AS [NumeroLotto]
      
		--, REPLACE(ISNULL(NULLIF(dbo.MDTGetDesrFromClasseIScriz(ClasseIscriz), ''), 'Tutte le Classi'), ';', ' ')

		--, CI1.value AS [ClassiMerceologiche]
		--, REPLACE(ISNULL(NULLIF(dbo.MDTGetDesrFromClasseIScrizILiv(ClasseIscriz), ''), ''), ';', ' ')
		--, CI2.value AS [ClassiMerceologicheLiv]

		--      , d.Id	
		--, /*dmstrLiv1.DMV_Cod*/ LEFT(dmstr.vatValore_FT, CHARINDEX('-', dmstr.vatValore_FT) - 1)  as PrimoLivelloStruttura
		--, dmstr.vatValore_FT as TIPO_AMM_ER
		, db.CIG
		, lb.CIG as CIG_LOTTO
		, rup.Value as UserRup
		,db.RecivedIstanze
		,isnull( lb.ValoreImportoLotto , ImportoBaseAsta2 ) as ValoreImportoLotto  -- base asta
		,o.ValoreImportoLotto as ImportoAggiudicato
		,db.TipoProceduraCaratteristica 
		,db.ProceduraGara
		,d.TipoDoc

		-- , case 
		--	when d.Tipodoc = 'BANDO_SEMPLIFICATO' then 'Bando Semplificato'
		--	when TipoProceduraCaratteristica = 'RDO' then 'RDO' 
		--	--when TipoProceduraCaratteristica = 'Cottimo' then 'Cottimo Fiduciario' 
		--	when ProceduraGara = '15476' then 'Aperta'
		--	when ProceduraGara = '15477' then 'Ristretta'
		--	when ProceduraGara = '15478' then 'Negoziata'
		--end as Descrizione
		, dbo.GetDescTipoProcedura ( d.Tipodoc , TipoProceduraCaratteristica , ProceduraGara )  as Descrizione
		,db.TipoAppaltoGara

		, o.aziRagioneSociale
		, az.aziE_Mail
		, az.aziPartitaIVA
		,d.Body
				
--d.id ,  d.Fascicolo,sp.* , o.*
  FROM CTL_Doc d WITH (NOLOCK)
	  
	  inner join Document_Bando db WITH (NOLOCK) on d.id = db.idheader
	  inner join aziende a WITH (NOLOCK) on a.idazi = d.Azienda
	  inner join profiliutente ow  WITH (NOLOCK) on ow.pfuIdAzi = a.IdAzi

	  -- apro sui lotti della gara se a lotti
	  LEFT OUTER JOIN Document_Microlotti_Dettagli lb WITH (NOLOCK) ON lb.IdHeader = d.Id and lb.tipodoc = d.Tipodoc and lb.voce = 0 and db.Divisione_lotti <> '0' 

	 -- --recupero i criteri di valutazione espressi sul lotto
	 --LEFT OUTER JOIN BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO V on V.idBando = d.Id and isnull( lb.NumeroLotto , '1' ) = V.N_Lotto

	 --recupero il CriterioAggiudicazioneGara per lotto
	 left outer join Document_Microlotti_DOC_Value V  with (nolock) on V.idheader = lb.id and V.DZT_Name = 'CriterioAggiudicazioneGara'  and V.DSE_ID = 'CRITERI_AGGIUDICAZIONE'

	 -- -- verifico la presenza di una scrittura privata
	 left outer join ( select distinct Fascicolo , dsp.NumeroLotto from  CTL_Doc sp WITH (NOLOCK) 
										LEFT OUTER JOIN Document_Microlotti_Dettagli dsp WITH (NOLOCK) ON dsp.IdHeader = sp.Id and dsp.tipodoc = sp.Tipodoc and dsp.voce = 0 --and dsp.NumeroLotto = lb.NumeroLotto 
								where  sp.TipoDoc = 'SCRITTURA_PRIVATA' AND sp.StatoDoc = 'Sended'and sp.Deleted = 0 
								) as sp
			ON d.Fascicolo = sp.Fascicolo AND (
												(  db.Divisione_lotti <> '0' and sp.NumeroLotto = lb.NumeroLotto )
												or
												(  db.Divisione_lotti = '0' )
											  )

	  -- verifico la presenza di una comunicazione di aggiudicazione
	  --LEFT OUTER JOIN CTL_Doc ed WITH (NOLOCK) ON d.Fascicolo = ed.Fascicolo AND ed.TipoDoc = 'PDA_COMUNICAZIONE_GARA' AND ed.StatoDoc = 'Sended' AND ed.JumpCheck = '0-ESITO_DEFINITIVO_MICROLOTTI'
	  --LEFT OUTER JOIN Document_comunicazione_StatoLotti ced WITH (NOLOCK) ON ced.IdHeader = ed.Id and ced.deleted = 0  
			--													and ( 
			--															( db.Divisione_lotti = '0' and ced.NumeroLotto = '1' )
			--															or
			--															( db.Divisione_lotti <> '0' and ced.NumeroLotto = lb.NumeroLotto )
			--														)
		

	  LEFT OUTER JOIN ( select distinct Fascicolo , NumeroLotto 
							from  CTL_Doc  ed WITH (NOLOCK)
								LEFT OUTER JOIN Document_comunicazione_StatoLotti ced WITH (NOLOCK) ON ced.IdHeader = ed.Id and ced.deleted = 0  
							where ed.deleted = 0 and ed.TipoDoc = 'PDA_COMUNICAZIONE_GARA' AND ed.StatoDoc = 'Sended' AND ed.JumpCheck = '0-ESITO_DEFINITIVO_MICROLOTTI'
					) as ed 	on d.Fascicolo = ed.Fascicolo and ( 
																		( db.Divisione_lotti = '0' /*and ed.NumeroLotto = '1'*/ )
																		or
																		( db.Divisione_lotti <> '0' and ed.NumeroLotto = lb.NumeroLotto )
																	)
		


	  -- RUP
	  LEFT OUTER JOIN CTL_DOC_Value rup WITH (NOLOCK) on rup.idheader = d.id and rup.DZT_Name = 'UserRUP'
	  left outer join ProfiliUtente p WITH (NOLOCK) on p.IdPfu = rup.Value


	  
	  -- numero invitati
	  left outer join (	SELECT COUNT(*) AS NumeroInvitati, IdHEader 
							FROM CTL_DOC WITH (NOLOCK)
								inner join CTL_DOC_Destinatari WITH (NOLOCK) on id = idheader and ( (Tipodoc = 'BANDO_GARA' and Seleziona = 'Includi') or (Tipodoc = 'BANDO_SEMPLIFICATO' ))
							WHERE  Tipodoc in ( 'BANDO_GARA' , 'BANDO_SEMPLIFICATO' )
							GROUP BY IdHEader
					   ) as ni on d.Id = ni.IdHeader

		 -- -- livello struttura ente
	  --   left outer join DM_Attributi dmstr WITH (NOLOCK) on d.azienda  = dmstr.LNK   AND dmstr.dztNome = 'TIPO_AMM_ER'
		 ----inner join LIB_DomainValues dmstrLiv1 WITH (NOLOCK) on  dmstrLiv1.DMV_DM_ID = 'TIPO_AMM_ER' AND LEFT(dmstr.vatValore_FT, CHARINDEX('-', dmstr.vatValore_FT) - 1) = dmstrLiv1.DMV_Cod
		 ----inner join LIB_DomainValues dmstrLiv2 WITH (NOLOCK) on  dmstrLiv2.DMV_DM_ID = 'TIPO_AMM_ER' and dmstr.vatValore_FT = dmstrLiv2.DMV_Cod


	  ---- recupero il lotto aggiudicato se presente
	  left outer join CTL_DOC pda WITH (NOLOCK) on pda.LinkedDoc = d.id and pda.deleted = 0 and pda.TipoDoc = 'PDA_MICROLOTTI'
	  LEFT OUTER JOIN Document_Microlotti_Dettagli pl WITH (NOLOCK) ON pl.IdHeader = pda.Id and pda.tipodoc = pl.Tipodoc and pl.voce = 0 and isnull(lb.NumeroLotto, '1') = pl.NumeroLotto
	  
	  --left outer join Document_PDA_OFFERTE o WITH (NOLOCK) ON o.IdHeader = pda.id and pl.Aggiudicata = o.idAziPartecipante
	  --LEFT OUTER JOIN Document_Microlotti_Dettagli ol WITH (NOLOCK) ON ol.IdHeader = o.idrow and ol.tipodoc = 'PDA_OFFERTE' and ol.voce = 0 and pl.NumeroLotto = ol.NumeroLotto

		left outer join (
			select o.IdHeader , ol.NumeroLotto , o.idAziPartecipante ,ValoreImportoLotto , [aziRagioneSociale]
				from Document_PDA_OFFERTE o WITH (NOLOCK) 
					LEFT OUTER JOIN Document_Microlotti_Dettagli ol WITH (NOLOCK) ON ol.IdHeader = o.idrow and ol.tipodoc = 'PDA_OFFERTE' and ol.voce = 0 
				
		) as o on  o.IdHeader = pda.id and pl.Aggiudicata = o.idAziPartecipante and pl.NumeroLotto = o.NumeroLotto
	   
		
		left outer join aziende az on az.idazi = pl.Aggiudicata 
					   
	   ----classe iscrizione in forma visuale
	   --LEFT OUTER JOIN CTL_DOC_Value CI1 WITH (NOLOCK) on CI1.idheader = d.id and CI1.DZT_Name = 'ClassiMerceologiche' and CI1.dse_id='DESCRIZIONE_CLASSI_ISCRIZIONE'
	   
	   ----classe iscrizione livello 1 in forma visuale
	   --LEFT OUTER JOIN CTL_DOC_Value CI2 WITH (NOLOCK) on CI2.idheader = d.id and CI2.DZT_Name = 'ClassiMerceologicheLiv' and CI2.dse_id='DESCRIZIONE_CLASSI_ISCRIZIONE'

 WHERE d.tipodoc in ( 'bando_gara' ,'BANDO_SEMPLIFICATO')
   AND TipoProceduraCaratteristica in ( 'RDO'  , 'RFQ' )
   AND d.deleted = 0
   AND d.statodoc = 'sended'
      
   
   --AND LIB_DomainValues.DMV_DM_Id = 'Criterio2'
   --AND CriterioAggiudicazioneGara = LIB_DomainValues.DMV_Cod
   --AND LIB_DomainValues.DMV_DescML = ml_Key
   
   
   
   
   
--   AND db.Divisione_Lotti > 0
--   AND d.Fascicolo = 'FE000865'


-- ORDER BY 1, 2, 3, Fascicolo, COALESCE(dsp.NumeroLotto, ced.Numerolotto, '0')












GO
