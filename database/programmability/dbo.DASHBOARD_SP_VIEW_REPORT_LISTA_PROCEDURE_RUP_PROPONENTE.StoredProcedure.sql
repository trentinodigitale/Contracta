USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DASHBOARD_SP_VIEW_REPORT_LISTA_PROCEDURE_RUP_PROPONENTE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE proc [dbo].[DASHBOARD_SP_VIEW_REPORT_LISTA_PROCEDURE_RUP_PROPONENTE]
(
 @IdPfu							int,
 @AttrName						varchar(8000),
 @AttrValue						varchar(8000),
 @AttrOp 						varchar(8000),
 @Filter                        varchar(8000),
 @Sort                          varchar(8000),
 @Top                           int,
 @Cnt                           int output
)
as
begin

	declare @Param varchar(8000)
	declare @Profilo as varchar(1500)
	declare @Ambito as varchar(1500)
	declare @Descrizione as varchar(1500)
	
	
	set nocount on

	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp
	--set @Descrizione	= dbo.GetParam( 'Descrizione'	, @Param ,1)
	
	--costruisco select da eseguire
	declare @SQLCmd			varchar(8000)
	declare @SQLWhere		varchar(8000)
	
	--ricavo la condizone di where di base basata sulle colonne della vista  da cui tolgo l'ambito per gestirlo separatamente
	set @SQLWhere = dbo.GetWhere( 'DASHBOARD_VIEW_REPORT_LISTA_PROCEDURE' , 'V',  @AttrName  ,  @AttrValue ,  @AttrOp )


	--select @SQLWhere
	

	--METTO IN UNA TEMP LE PROCEDURE 

	SELECT 
		d.id 
		, a.aziRagioneSociale                                                AS Ente 
		, a.aziRagioneSociale                                                
		, d.azienda  as AZI_Ente
		, REPLACE(REPLACE(d.Titolo , ';', ' '), CHAR(13) + CHAR(10) , '')  AS Titolo
		, REPLACE(REPLACE(CAST(d.Body AS VARCHAR(150)), ';', ' '), CHAR(13) + CHAR(10), '')	 AS Oggetto 	 
		, isnull( V.value ,db.CriterioAggiudicazioneGara ) as CriterioAggiudicazioneGara
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
		, db.CIG
		, lb.CIG as CIG_LOTTO
		,  lb.NumeroLotto 													AS [NumeroLotto]
		, db.RecivedIstanze
		, isnull( lb.ValoreImportoLotto , ImportoBaseAsta2 ) as ValoreImportoLotto  -- base asta
		, db.TipoProceduraCaratteristica 
		, db.ProceduraGara
		, d.TipoDoc
		, db.TipoAppaltoGara
		, dbo.GetDescTipoProcedura ( d.Tipodoc , TipoProceduraCaratteristica , ProceduraGara , TipoBandoGara )  as DescTipoProcedura
		, lb.Descrizione
		, pfuLogin                                      
		, rup.Value as UserRup
		, p.idpfu as IdPfu --idpfu del rup
		, CI1.value AS [ClassiMerceologiche]
      	, CI2.value AS [ClassiMerceologicheLiv]
		, Divisione_lotti
		, ambito.Value as ambito
		, db.Appalto_Verde
		, db.Acquisto_Sociale
		, db.AppaltoInEmergenza
		, db.Appalto_PNRR
		, db.Appalto_PNC
		, db.IdentificativoIniziativa
		, db.GeneraConvenzione

		INTO

			#TempProcedure

		FROM
			
			CTL_Doc d WITH (NOLOCK)	  
				
				INNER JOIN Document_Bando db WITH (NOLOCK) on d.id = db.idheader
				
				INNER JOIN aziende a WITH (NOLOCK) on a.idazi = d.Azienda

			    -- apro sui lotti della gara se a lotti
				LEFT OUTER JOIN Document_Microlotti_Dettagli lb WITH (NOLOCK) ON lb.IdHeader = d.Id and lb.tipodoc = d.Tipodoc and lb.voce = 0 and db.Divisione_lotti <> '0' 
				
				--recupero il CriterioAggiudicazioneGara per lotto
				LEFT OUTER JOIN Document_Microlotti_DOC_Value V  with (nolock) on V.idheader = lb.id and V.DZT_Name = 'CriterioAggiudicazioneGara'  and V.DSE_ID = 'CRITERI_AGGIUDICAZIONE'

				-- RUP
				LEFT OUTER JOIN CTL_DOC_Value rup WITH (NOLOCK) on rup.idheader = d.id and rup.DSE_ID='InfoTec_comune'  and rup.DZT_Name = 'UserRUP'
				LEFT OUTER JOIN ProfiliUtente p WITH (NOLOCK) on p.IdPfu = rup.Value

				--classe iscrizione in forma visuale
				LEFT OUTER JOIN CTL_DOC_Value CI1 WITH (NOLOCK) on CI1.idheader = d.id and CI1.DZT_Name = 'ClassiMerceologiche' and CI1.dse_id='DESCRIZIONE_CLASSI_ISCRIZIONE'
	   
				 --classe iscrizione livello 1 in forma visuale
				LEFT OUTER JOIN CTL_DOC_Value CI2 WITH (NOLOCK) on CI2.idheader = d.id and CI2.DZT_Name = 'ClassiMerceologicheLiv' and CI2.dse_id='DESCRIZIONE_CLASSI_ISCRIZIONE'
				LEFT OUTER JOIN CTL_DOC_Value ambito WITH (NOLOCK) on ambito.idheader = d.id and ambito.DSE_ID='TESTATA_PRODOTTI'  and ambito.DZT_Name = 'ambito'

		WHERE d.tipodoc in ( 'bando_gara' ,'BANDO_SEMPLIFICATO')
				AND d.deleted = 0
				AND d.statodoc = 'sended'
				and db.RupProponente = @IdPfu


	--METTO IN UNA TEMP LE SCRITTURE PRIVATE
	select distinct Fascicolo , dsp.NumeroLotto 
		into #TempScritturePrivate_contratti
	from  
		CTL_Doc sp WITH (NOLOCK) 
			LEFT OUTER JOIN Document_Microlotti_Dettagli dsp WITH (NOLOCK) ON dsp.IdHeader = sp.Id and dsp.tipodoc = sp.Tipodoc and dsp.voce = 0 --and dsp.NumeroLotto = lb.NumeroLotto 
	where  sp.TipoDoc  in ('SCRITTURA_PRIVATA','CONTRATTO_GARA')  AND sp.StatoDoc = 'Sended'and sp.Deleted = 0 



	--METTO IN UNA TEMP LE COM DI ESITO
	select 
		distinct Fascicolo , NumeroLotto , ed.DataInvio
		into #TempComEsito
		from  
			CTL_Doc  ed WITH (NOLOCK)
				LEFT OUTER JOIN Document_comunicazione_StatoLotti ced WITH (NOLOCK) ON ced.IdHeader = ed.Id and ced.deleted = 0  
		where ed.deleted = 0 and ed.TipoDoc = 'PDA_COMUNICAZIONE_GENERICA' AND ed.StatoDoc = 'Sended' AND ed.JumpCheck = '0-ESITO_DEFINITIVO_MICROLOTTI'

	--metto in un atemp numero invitati per procedura
	SELECT 
		COUNT(*) AS NumeroInvitati, IdHEader 
			into #TempNumInvitati
		FROM 
			CTL_DOC WITH (NOLOCK)
				inner join CTL_DOC_Destinatari WITH (NOLOCK) on id = idheader and ( (Tipodoc = 'BANDO_GARA' and Seleziona = 'Includi') or (Tipodoc = 'BANDO_SEMPLIFICATO' ))
		WHERE  Tipodoc in ( 'BANDO_GARA' , 'BANDO_SEMPLIFICATO' )
		
		GROUP BY IdHEader

	--METTO IN UNA TEMP I LOTTI OFFERTA DELLA PDA
	select 
		o.IdHeader , ol.NumeroLotto , o.idAziPartecipante ,ValoreImportoLotto
			INTO #TempLottiOfferte
		from Document_PDA_OFFERTE o WITH (NOLOCK) 
				LEFT OUTER JOIN Document_Microlotti_Dettagli ol WITH (NOLOCK) ON ol.IdHeader = o.idrow and ol.tipodoc = 'PDA_OFFERTE' and ol.voce = 0 

	SELECT 
		d.id
		, Ente 
		, aziRagioneSociale                                                
		, AZI_Ente
		, d.Titolo
		, Oggetto 	 
		, CriterioAggiudicazioneGara
		, d.StatoFunzionale
		, Registro 
		, d.Fascicolo
		, d.Note 
		, d.[DataInvio]
		, [DataInvioAl]
		, [DataScadenzaOfferta]
		, [DataScadenzaA]
		, [ImportoBaseAsta2]
		, d.CIG
		, CIG_LOTTO
		, isnull( d.NumeroLotto , '0' ) AS [NumeroLotto]
		, RecivedIstanze
		, d.ValoreImportoLotto  -- base asta
		, tipoProceduraCaratteristica 
		, ProceduraGara
		, d.TipoDoc
		, TipoAppaltoGara
		, DescTipoProcedura
		, d.Descrizione
		, pfuLogin                                      
		, UserRup
		, d.IdPfu --idpfu del rup
		, [ClassiMerceologiche]
      	, [ClassiMerceologicheLiv]
		, Divisione_lotti
		, [NumeroInvitati]
    
    
		, CASE WHEN sp.Fascicolo IS NOT NULL 
                THEN 'Stipula Contratto'
            WHEN ed.Fascicolo IS NOT NULL 
                THEN 'Esito Definitivo'
            ELSE ''
		  END   AS [Aggiudicazione]

		, case when ed.Fascicolo IS NOT NULL then 1 else 0 end as IsAggiudicato

		, LEFT(dmstr.vatValore_FT, CHARINDEX('-', dmstr.vatValore_FT) - 1)  as PrimoLivelloStruttura
		, dmstr.vatValore_FT as TIPO_AMM_ER
	  
		, o.ValoreImportoLotto as ImportoAggiudicato
	 
		, pda.id as idPdA
		 ,pl.id as idRowLotto
		,d.ambito
		,d.Appalto_Verde
		,d.Acquisto_Sociale
		,d.AppaltoInEmergenza
		, d.Appalto_PNRR
		, d.Appalto_PNC
		, d.IdentificativoIniziativa
		, d.GeneraConvenzione
		, pl.StatoRiga
		, isnull(  CAST(ltVa.value AS datetime)   ,ed.datainvio) as Data_Aggiudicazione_Lotto
	  INTO #TempProcedureFinale

  FROM 

	#TempProcedure d

	 -- -- verifico la presenza di una scrittura privata
	 left outer join  #TempScritturePrivate_contratti as  sp ON d.Fascicolo = sp.Fascicolo 
														AND (
																(  d.Divisione_lotti <> '0' and sp.NumeroLotto = d.NumeroLotto )
																or
																(  d.Divisione_lotti = '0' )
															 )

	  LEFT OUTER JOIN  #TempComEsito as ed 	on d.Fascicolo = ed.Fascicolo 
												AND ( 
														( d.Divisione_lotti = '0' /*and ed.NumeroLotto = '1'*/ )
														or
														( d.Divisione_lotti <> '0' and ed.NumeroLotto = d.NumeroLotto )
													)
		

  
	  -- numero invitati
	  left outer join 	#TempNumInvitati as ni on d.Id = ni.IdHeader

	  -- livello struttura ente
     left outer join DM_Attributi dmstr WITH (NOLOCK) on d.AZI_Ente  = dmstr.LNK   AND dmstr.dztNome = 'TIPO_AMM_ER' and dmstr.idApp=1
	

	  ---- recupero il lotto aggiudicato se presente
	  left outer join CTL_DOC pda WITH (NOLOCK) on pda.LinkedDoc = d.id and pda.deleted = 0 and pda.TipoDoc = 'PDA_MICROLOTTI'
	  LEFT OUTER JOIN Document_Microlotti_Dettagli pl WITH (NOLOCK) ON pl.IdHeader = pda.Id and pda.tipodoc = pl.Tipodoc and pl.voce = 0 and isnull(d.NumeroLotto, '1') = pl.NumeroLotto
	  
	 
	  left outer join  #TempLottiOfferte  o on  o.IdHeader = pda.id and pl.Aggiudicata = o.idAziPartecipante and pl.NumeroLotto = o.NumeroLotto	  
	  left join Document_Microlotti_DOC_Value ltVa with(nolock) ON ltVa.idheader = pl.id and dse_id = 'INVIO_FINE_AGG_CONDIZ' and DZT_Name = 'DataInvio' and isnull(value,'') <> ''

	set @SQLCmd =  'select * from 
						#TempProcedureFinale where 1 = 1 '
						
	if 	@SQLWhere <> ''
		set   @SQLCmd = @SQLCmd +  ' and  ' + @SQLWhere
	
	
	
	if rtrim( @Sort ) <> ''
		set @SQLCmd=@SQLCmd + ' order by ' + @Sort


	

	--print @SQLCmd
	exec (@SQLCmd)

	--select @cnt = count(*) from #temp
	--set @cnt = @@rowcount

end





GO
