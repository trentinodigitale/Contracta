USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_DASHBOARD_SP_VIEW_BANDI_FORN_SERV_PRIV]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE proc [dbo].[OLD2_DASHBOARD_SP_VIEW_BANDI_FORN_SERV_PRIV]
(@IdPfu							int,
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
	set @SQLWhere = dbo.GetWhere( 'DASHBOARD_VIEW_BANDI_FORN_SERV_PRIV' , 'V',  @AttrName  ,  @AttrValue ,  @AttrOp )

	--METTO IN UNA TEMP I BANDI DI COMPETENZA DELL'UTENTE IN INPUT
	select 
			d.Id
			,d.Titolo 
			,d.GUID
			,d.Protocollo
			,d.TipoDoc
			,d.StatoFunzionale
			,d.Body
			,d.statodoc
			,d.Fascicolo
			,p.IdPfu
			,case 
				when d.tipodoc = 'BANDO_SEMPLIFICATO' then 222 
				when d.tipodoc in ( 'BANDO_GARA','BANDO_CONCORSO') then 168
				when d.tipodoc = 'BANDO_ASTA' then 386
				else 0 
			 end as msgISubType
			,ProtocolloBando
			,TipoAppaltoGara
			,CriterioAggiudicazioneGara
			,DataScadenzaOfferta
			,ImportoBaseAsta
			,ProceduraGara
			,CriterioFormulazioneOfferte
			--,TipoBandoGara
			,TipoBandoGara as TipoBando
			,CIG
			,TipoProceduraCaratteristica
			,Appalto_Verde
			,Acquisto_Sociale
			,TipoSedutaGara
			,StatoSeduta
			,EnteProponente
			,DataInvio
			,az.AziRagioneSociale AS EnteAppaltante
			,az.IdAzi as AZI_Ente
			,statoiscrizione
			,ds.IdAzi 
			,case when DataScadenzaOfferta > getdate() then '0' else '1' end as Scaduto
			,TipoAppaltoGara as Tipologia

			into #TempBandi

		from 
			CTL_DOC d 
				inner join document_bando b  with(nolock) on d.id = b.idheader
				
				inner join CTL_DOC_Destinatari ds  with(nolock) on  ds.idHeader = d.id

				inner join profiliutente p  with(nolock) on p.pfuidazi = ds.IdAzi

				inner join aziende az with(nolock)  on az.idazi=d.Azienda   ---per recuperare l'enteAppaltante

		where
			d.tipodoc in ( 'BANDO_SEMPLIFICATO' , 'BANDO_GARA' , 'BANDO_ASTA','BANDO_CONCORSO' )  
			--statofunzionale in ('Pubblicato') and 
			and d.statofunzionale not in ('InLavorazione' , 'InApprove' , 'Rifiutato' , 'NotApproved',
							'ProntoPerInviti', 'InProtocollazione' )  
			and d.deleted = 0
			and p.IdPfu = @IdPfu 
		

		--applico a questo insieme il filtro passato in input perchè ho tutti i campi a disposizione
		select 
			top 0 * 
				into #TempBandiFiltrati
			from 
				#TempBandi

		
		set @SQLCmd =  'insert 
							into #TempBandiFiltrati 
						select  
							* 
							from 
								#TempBandi where 1 = 1 '
		if @Filter <> ''
			set   @SQLCmd = @SQLCmd + ' and ( ' + @Filter + ' ) '
		
		exec (@SQLCmd)


		--METTO IN UNA TEMP LE RISPOSTE AI BANDI COINVOLTI
		select 
			max( R.id ) as id ,R.LinkedDoc , azienda 
				into #TempRisposte
			from 
				CTL_DOC  R with(nolock) 
					inner join #TempBandi Bandi on Bandi.Id = R.LinkedDoc
			where 
				R.TipoDoc in ('OFFERTA','OFFERTA_ASTA' ,'DOMANDA_PARTECIPAZIONE','RISPOSTA_CONCORSO') and deleted = 0 
				
			group by LinkedDoc , azienda

		
		--METTO IN UNA TEMP GLI ESITI DEI BANDI COINVOLTI
		select 
			distinct leg
				into #TempEsiti
			from
				DOCUMENT_RISULTATODIGARA_ROW_VIEW R
					inner join #TempBandiFiltrati on leg=id
			where R.StatoFunzionale='Inviato'	
		

		--METTO IN UNA TEMP LE MODIFICHE DEI BANDI COINVOLTI
		select 
			d.linkedDoc , TipoDoc as TipoModifica  
				into #TempModifiche
			from 
				ctl_doc d with(nolock) 

					inner join 
						( 
						Select max(M.id) as ID_DOC ,  M.linkedDoc 
							from 
								ctl_doc M with(nolock) 
									inner join #TempBandiFiltrati Bandi on Bandi.Id =M.LinkedDoc 
							where 
								M.tipodoc IN ('RETTIFICA_BANDO','PROROGA_BANDO','RETTIFICA_GARA','PROROGA_GARA'  , 'RIPRISTINO_GARA'  ) and M.Statodoc ='Sended' 
							group by linkedDoc  

						) as M on M.id_DOC = d.id
		
		
		
		--METTO IN UNA TEMP I DOPC LETTI DALL'UNTETE IN INPUT
		select 
			distinct 
					left( DOC_NAME , 18 ) as DOC_NAME , 1 as id , idPfu , id_Doc 
				into #TempDocRead 
			from   
				CTL_DOC_READ  with(nolock) 
			where 
				idpfu = @IdPfu

		--EFFETTUO LA SELECT FINALE

		select 
			d.id as IdMsg, 
			d.IdPfu, 
			1000 as msgIType, 
			case 
				when d.tipodoc = 'BANDO_SEMPLIFICATO' then 222 
				when d.tipodoc = 'BANDO_GARA' then 168
				when d.tipodoc = 'BANDO_ASTA' then 386
				else 0 
				end as msgISubType, 
			
			CASE WHEN DR.leg IS NULL THEN 0 
				ELSE DR.leg 
			END AS IDDOCR ,

			CASE WHEN Dr.leg IS NULL THEN 0 
			   ELSE 1 
			END AS Precisazioni,

			d.Titolo as Name,
			case when isnull( r.id , 0 ) = 0 then 1 else 0 end as  bRead, 
			ProtocolloBando, 
			d.Protocollo as ProtocolloOfferta, 
			d.DataInvio as ReceivedDataMsg, 
			case d.StatoFunzionale
				when 'Revocato' then '<strong>Bando Revocato - </strong> ' + cast( d.Body as nvarchar(4000)) 
				when 'InRettifica' then '<strong>Bando In Rettifica - </strong> ' + cast( d.Body as nvarchar(4000)) 
				when  'Sospeso' then '<strong>Procedura Sospesa - </strong> ' + cast(d.Body as nvarchar (4000)) 
				when  'InSospensione' then '<strong>Procedura in Sospensione - </strong> ' + cast(d.Body as nvarchar (4000)) 
			else				
				case 
					when isnull(v.linkeddoc,0) > 0 and V.TipoModifica =  'RIPRISTINO_GARA' then '<strong>Procedura Ripristinata - </strong> ' + cast( d.Body as nvarchar(4000)) 
					when isnull(v.linkeddoc,0) > 0 and V.TipoModifica <> 'RIPRISTINO_GARA' then  '<strong>Bando Rettificato - </strong> ' + cast( d.Body as nvarchar(4000)) 
				else
					cast( d.Body as nvarchar(4000)) 
				end				
			end as Oggetto, 

			--TipoAppaltoGara as Tipologia, 
			Tipologia,
			convert( varchar(30) , DataScadenzaOfferta ,126 ) as expirydate, 

			ImportoBaseAsta, 

			ProceduraGara as tipoprocedura, 
			d.statodoc as StatoGD, 
			d.Fascicolo, 
			case CriterioAggiudicazioneGara 
				when 15531 then 1
				when 15532 then 2
				when 16291 then 3
				when 25532 then 4
				end as CriterioAggiudicazione, 
			case CriterioFormulazioneOfferte 
				when 15536 then 1 
				when 15537 then 2
				else 0 
				end as CriterioFormulazioneOfferta, 
			'1' as OpenDettaglio ,
			--case when DataScadenzaOfferta > getdate() then '0' else '1' end as Scaduto,
			Scaduto , 
			cast( d.GUID as varchar (50) ) as IdDoc, 
			--TipoBandoGara as TipoBando, 
			TipoBando,
			CIG,
			case ld.statofunzionale
				when 'InLavorazione' then 'Saved'
				when 'Sended' then 'Sended'
				when 'Inviato' then 'Sended'
				when 'Annullato' then 'Annullata'
				when 'Ritirata' then 'Ritirata'				   
				else ''
			end as StatoCollegati,
			case d.tipoDoc 
				when 'BANDO_SEMPLIFICATO' then 'BANDO_SEMPLIFICATO_INVITO' 
				else d.tipoDoc
			end as OPEN_DOC_NAME
			,
			case ld.statofunzionale
				when 'InLavorazione' then 'Saved'
				when 'Sended' then 'Sended'
				when 'Inviato' then 'Sended'
				when 'Annullato' then 'Annullata'
				when 'InAttesaFirma' then 'InAttesaFirma'
				when 'Ritirata' then 'Ritirata'
				else ''
			end as OpenOfferte
			, EnteAppaltante 
			, d.Protocollo
			, isnull( TipoProceduraCaratteristica , '' ) as TipoProceduraCaratteristica
			,ISNULL(Appalto_Verde,'no') as Appalto_Verde
			,ISNULL(Acquisto_Sociale,'no') as Acquisto_Sociale 
			,case 
					when Appalto_Verde='si' and Acquisto_Sociale='si' then '<img title="Appalto Verde" alt="Appalto Verde" src="../images/Appalto_Verde.png">&nbsp;<img title="Acquisto Sociale" alt="Acquisto Sociale" src="../images/Acquisto_Sociale.png">'  
					when Appalto_Verde='si' and Acquisto_Sociale='no' then  '<img title="Appalto Verde" alt="Appalto Verde" src="../images/Appalto_Verde.png">' 
					when Appalto_Verde='no' and Acquisto_Sociale='si' then  '<img title="Acquisto Sociale" alt="Acquisto Sociale" src="../images/Acquisto_Sociale.png">' 
			end as Bando_Verde_Sociale
			
			, AZI_Ente
			
			,case when TipoSedutaGara='virtuale' then case when StatoSeduta is null then 'prevista' else case when StatoSeduta='aperta' then 'incorso' else 'prevista' end  end else '' end as SedutaVirtuale
			
			,EnteProponente 
			, statoiscrizione
			, --IdPfuMitt as utentedomanda
			  ld.IdPfu as utentedomanda

			into #TempFinale
		from 
		
			#TempBandiFiltrati d 


			left outer join 
				#TempRisposte as lo on lo.LinkedDoc = d.id and idAzi = lo.azienda

			
			left join 
				CTL_DOC ld with(nolock)  on ld.TipoDoc in ('OFFERTA','OFFERTA_ASTA' ,'DOMANDA_PARTECIPAZIONE','RISPOSTA_CONCORSO' )
												and lo.id = ld.id
			
			left outer join
						#TempEsiti DR on DR.leg=d.id 


			left  join 
				#TempModifiche V on V.LinkedDoc=d.id
		
			-- il tipo doc è stato troncato a 18 perchè lato fornitore il documento che apre è il
			-- BANDO_SEMPLIFICATO_INVITO mentre il documento è BANDO_SEMPLIFICATO
			left outer join  
								--select 
								--	distinct left( r.DOC_NAME , 18 ) as DOC_NAME , 1 as id , r.idPfu , r.id_Doc 
								--	from   
								--		CTL_DOC_READ r with(nolock) 
								#TempDocRead 

							 r on  r.idPfu = d.IdPfu and left( r.DOC_NAME , 18 ) = left( d.tipoDoc ,18 ) and r.id_Doc = d.id
		





	set @SQLCmd =  'select * from 
						#TempFinale where 1 = 1 '
						
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
