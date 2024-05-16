USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DASHBOARD_SP_VIEW_BANDI_FORN_SERV_PUBB]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[OLD_DASHBOARD_SP_VIEW_BANDI_FORN_SERV_PUBB]
(@IdPfu							int,
 @AttrName						varchar(8000),
 @AttrValue						varchar(8000),
 @AttrOp 						varchar(8000),
 @Filter			            varchar(8000),
 @Sort                          varchar(8000),
 @Top                           int,
 @Cnt                           int output
)
as
begin

	declare @Param varchar(max)
	declare @Profilo as varchar(max)
	declare @Ambito as varchar(max)
	declare @Descrizione as varchar(max)
	
	declare @AttrName_App as varchar(max)
	declare @Filter_App as varchar(max)
	declare @DescTipoProcedura as nvarchar(500)
	set nocount on

	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp
	--set @Descrizione	= dbo.GetParam( 'Descrizione'	, @Param ,1)
	

	set @DescTipoProcedura	= dbo.GetParam( 'DescTipoProcedura'	, @Param ,1)


	--costruisco select da eseguire
	declare @SQLCmd			varchar(max)
	declare @SQLWhere		varchar(max)
	declare @SQLWhere_orig		varchar(max)


	set @AttrName_App = @AttrName

	-- replace del nome corretto dei parametri per risolvere gli AS che faceva la vista
	set @AttrName_App = replace(  @AttrName_App , 'Precisazioni' , '' )
	set @AttrName_App = replace(  @AttrName_App , 'Name' , 'Titolo' )
	set @AttrName_App = replace(  @AttrName_App , 'ProtocolloOfferta' , 'Protocollo' )
	set @AttrName_App = replace(  @AttrName_App , 'ReceivedDataMsg' , 'DataInvio' )
	set @AttrName_App = replace(  @AttrName_App , 'Oggetto' , 'cast(Body as nvarchar(max))' )
	set @AttrName_App = replace(  @AttrName_App , 'Tipologia' , 'TipoAppaltoGara' )
	set @AttrName_App = replace(  @AttrName_App , 'ExpiryDate' , 'convert( varchar(19),isnull( DataScadenzaOfferta ,DataScadenzaOffIndicativa),120)' )
	set @AttrName_App = replace(  @AttrName_App , 'ExpiryDateAl' , 'convert( varchar(19),isnull( DataScadenzaOfferta ,DataScadenzaOffIndicativa),120)' )
	set @AttrName_App = replace(  @AttrName_App , 'tipoprocedura' , 'ProceduraGara' )
	set @AttrName_App = replace(  @AttrName_App , 'StatoGD' , 'statodoc' )
	set @AttrName_App = replace(  @AttrName_App , 'CriterioAggiudicazione' , 'CriterioAggiudicazioneGara' )
	set @AttrName_App = replace(  @AttrName_App , 'EnteAppaltante' , 'aziRagioneSociale' )
	set @AttrName_App = replace(  @AttrName_App , 'IdMittente' , 'idpfu' )
	set @AttrName_App = replace(  @AttrName_App , 'AZI_Ente' , 'a.idAzi' )
	set @AttrName_App = replace(  @AttrName_App , 'Scaduto' , 'case when isnull( DataScadenzaOfferta ,DataScadenzaOffIndicativa) > getdate() then ''0'' else ''1'' end' )
	set @AttrName_App = replace(  @AttrName_App , 'DOCUMENT' , 'a.tipodoc' )
	set @AttrName_App = replace(  @AttrName_App , 'OPEN_DOC_NAME' , 'a.tipodoc' )

	set @Filter_App = @Filter

	set @Filter_App = replace(  @Filter_App , 'Precisazioni' , '' )
	set @Filter_App = replace(  @Filter_App , 'Name' , 'Titolo' )
	set @Filter_App = replace(  @Filter_App , 'ProtocolloOfferta' , 'Protocollo' )
	set @Filter_App = replace(  @Filter_App , 'ReceivedDataMsg' , 'DataInvio' )
	set @Filter_App = replace(  @Filter_App , 'Oggetto' , 'cast(Body as nvarchar(max))' )
	set @Filter_App = replace(  @Filter_App , 'Tipologia' , 'TipoAppaltoGara' )
	set @Filter_App = replace(  @Filter_App , 'ExpiryDate' , 'convert( varchar(19),isnull( DataScadenzaOfferta ,DataScadenzaOffIndicativa),120)' )
	set @Filter_App = replace(  @Filter_App , 'ExpiryDateAl' , 'convert( varchar(19),isnull( DataScadenzaOfferta ,DataScadenzaOffIndicativa),120)' )
	set @Filter_App = replace(  @Filter_App , 'tipoprocedura' , 'ProceduraGara' )
	set @Filter_App = replace(  @Filter_App , 'StatoGD' , 'statodoc' )
	set @Filter_App = replace(  @Filter_App , 'CriterioAggiudicazione' , 'CriterioAggiudicazioneGara' )
	set @Filter_App = replace(  @Filter_App , 'EnteAppaltante' , 'aziRagioneSociale' )
	set @Filter_App = replace(  @Filter_App , 'IdMittente' , 'idpfu' )
	set @Filter_App = replace(  @Filter_App , 'AZI_Ente' , 'a.idAzi' )
	set @Filter_App = replace(  @Filter_App , 'Scaduto' , 'case when isnull( DataScadenzaOfferta ,DataScadenzaOffIndicativa) > getdate() then ''0'' else ''1'' end' )
	set @Filter_App = replace(  @Filter_App , 'DOCUMENT' , 'a.tipodoc' )
	set @Filter_App = replace(  @Filter_App , 'OPEN_DOC_NAME' , 'a.tipodoc' )

	--ricavo la condizone di where di base basata sulle colonne della vista  da cui tolgo l'ambito per gestirlo separatamente
	set @SQLWhere = dbo.GetWhere( 'DASHBOARD_VIEW_BANDI_FORN_SERV_PUBB' , 'V',@AttrName_App ,  @AttrValue ,  @AttrOp )
	
	set @SQLWhere_orig = dbo.GetWhere( 'DASHBOARD_VIEW_BANDI_FORN_SERV_PUBB' , 'V', @AttrName,  @AttrValue ,  @AttrOp )

--				[Id], [IdPfu], [IdDoc], [TipoDoc], [StatoDoc], [Data], [Protocollo], [PrevDoc], [Deleted], [Titolo], [Body], [Azienda], [StrutturaAziendale], [DataInvio], [ProtocolloRiferimento], [ProtocolloGenerale], [Fascicolo], [Note], [DataProtocolloGenerale], [LinkedDoc], [SIGN_HASH], [SIGN_ATTACH], [SIGN_LOCK], [JumpCheck], [StatoFunzionale], [Destinatario_User], [Destinatario_Azi], [RichiestaFirma], [NumeroDocumento], [DataDocumento], [Versione], [VersioneLinkedDoc], [GUID], [idPfuInCharge], [CanaleNotifica], [URL_CLIENT], [Caption], [FascicoloGenerale], [OPEN_DOC_NAME], [muidazidest], [TipoProceduraCaratteristica], [NewTotal], [BodyContratto], [DataScadenza], [idBando]
	

	--set @SQLCmd =  'select c.*	 from DASHBOARD_VIEW_CONTRATTO_GARA c 

	--inner join (
	--	-- estendo la visualizzazione a tutti gli utenti nei riferimenti della gara come BANDO
	--	select idpfu , id as idBando  from ctl_doc where tipodoc in (  ''BANDO_GARA'' , ''BANDO_SEMPLIFICATO'' )
	--	union 
	--	select idPfu , idheader as idBando from Document_Bando_Riferimenti r with(nolock) where  r.RuoloRiferimenti  = ''Bando'' 
	--) as V on V.idBando = c.idBando
	--'


	set @SQLCmd =  'select 
			ID,
			id as IdMsg, 
			ctl_doc.IdPfu, 
			1000 as msgIType, 
			case 
				when tipodoc = ''BANDO_SEMPLIFICATO'' then 221 
				else 0 
				end as msgISubType, 
			0 as IDDOCR, 
			0 as Precisazioni,
			--CASE WHEN Dr.leg IS NULL THEN 0 
			--   ELSE 1 
			--END AS Precisazioni,
			''1'' as OpenDettaglio ,
			Titolo as Name,
			cast( GUID as  varchar(100) )  as IdDoc, 

			ProtocolloBando,
			CIG, 
			isnull(ctl_doc.Protocollo ,'''') as ProtocolloOfferta, 
			DataInvio as ReceivedDataMsg, 
			case
				 when ctl_doc.statofunzionale = ''revocato'' then ''<strong>Bando Revocato - </strong> '' + cast(Body as nvarchar (2000)) 				
				 when ctl_doc.statofunzionale = ''InRettifica'' then ''<strong>Bando In Rettifica - </strong> '' + cast(Body as nvarchar (2000)) 
				 when ctl_doc.statofunzionale = ''Sospeso'' then ''<strong>Procedura Sospesa - </strong> '' + cast(Body as nvarchar (2000)) 
				 when ctl_doc.statofunzionale = ''InSospensione'' then ''<strong>Procedura in Sospensione - </strong> '' + cast(Body as nvarchar (2000)) 
			else
				--case 
				--	when isnull(v.linkeddoc,0) > 0 and V.TipoModifica =  ''RIPRISTINO_GARA'' then ''<strong>Procedura Ripristinata - </strong> '' + cast( Body as nvarchar(4000)) 
				--	when isnull(v.linkeddoc,0) > 0 and V.TipoModifica <> ''RIPRISTINO_GARA'' then  ''<strong>Bando Rettificato - </strong> '' + cast( Body as nvarchar(4000)) 
				--else
					cast( Body as nvarchar(4000)) 
				--end				
			end as Oggetto,		


			TipoAppaltoGara as Tipologia, 
			convert( varchar(19),isnull( DataScadenzaOfferta ,DataScadenzaOffIndicativa),120) as ExpiryDate, 
			convert( varchar(19),isnull( DataScadenzaOfferta ,DataScadenzaOffIndicativa),120) as ExpiryDateAl, 

			replace(str(ImportoBaseAsta, 25, 2),'','',''.'') AS ImportoBaseAsta,
			
			ProceduraGara as tipoprocedura, 
			case statodoc 
				when ''Sended'' then ''2'' 
				else ''1'' 
			end as StatoGD, 
			case CriterioAggiudicazioneGara 
				when 15531 then 1
				when 15532 then 2
				when 16291 then 3
				when 25532 then 4
				end as CriterioAggiudicazione, 
			
			aziRagioneSociale as EnteAppaltante,
			
			ISNULL(Appalto_Verde,''no'') as Appalto_Verde,
			ISNULL(Acquisto_Sociale,''no'') as Acquisto_Sociale ,
			
			TipoBandoGara ,
			ctl_doc.idpfu as IdMittente ,
			a.idAzi as AZI_Ente,

			--0 as  Scaduto, 
			case when isnull( DataScadenzaOfferta ,DataScadenzaOffIndicativa) > getdate() then ''0'' else ''1'' end as Scaduto, 
			''1'' as EvidenzaPubblica
			,tipodoc as DOCUMENT 
			,tipodoc as OPEN_DOC_NAME 
			,case 
					when Appalto_Verde=''si'' and Acquisto_Sociale=''si'' then ''<img title="Appalto Verde" alt="Appalto Verde" src="../images/Appalto_Verde.png">&nbsp;<img title="Acquisto Sociale" alt="Acquisto Sociale" src="../images/Acquisto_Sociale.png">''  
					when Appalto_Verde=''si'' and Acquisto_Sociale=''no'' then  ''<img title="Appalto Verde" alt="Appalto Verde" src="../images/Appalto_Verde.png">'' 
					when Appalto_Verde=''no'' and Acquisto_Sociale=''si'' then  ''<img title="Acquisto Sociale" alt="Acquisto Sociale" src="../images/Acquisto_Sociale.png">'' 
			end as Bando_Verde_Sociale,
			Protocollo,
			case when TipoSedutaGara=''virtuale'' then case when StatoSeduta is null then ''prevista'' else case when StatoSeduta=''aperta'' then ''incorso'' else ''prevista'' end  end else '''' end as SedutaVirtuale
			,EnteProponente,
			tipodoc,statofunzionale,deleted,body
		'
	--se presente nel filtro TipoProceduraFiltro aggiungo la colonna TipoProceduraFiltro
	if @DescTipoProcedura <> ''
	begin
		set @SQLCmd =  @SQLCmd +  ',dbo.GetDescTipoProcedura ( Tipodoc , TipoProceduraCaratteristica , ProceduraGara , TipoBandoGara )  as DescTipoProcedura'
	end

	set @SQLCmd =  @SQLCmd + 
		'
			  into #temp

		from ctl_doc  with(nolock) 
			inner join aziende a with(nolock) on azienda = a.idazi
			inner join document_bando  with(nolock)  on id = idheader
			
			--left  join (
			
			
			--		select d.linkedDoc , TipoDoc as TipoModifica  from ctl_doc d with(nolock) 
			--			inner join ( 
			--							Select max(id) as ID_DOC ,  linkedDoc from ctl_doc  with(nolock) where tipodoc IN (''RETTIFICA_BANDO'',''PROROGA_BANDO'',''RETTIFICA_GARA'',''PROROGA_GARA''  , ''RIPRISTINO_GARA''  ) and Statodoc =''Sended'' group by linkedDoc  
			--							) as M on M.id_DOC = d.id
			
			--		) V on V.LinkedDoc=CTL_DOC.id

			--left outer join
			--(
			--	select distinct leg
			--		from
			--			DOCUMENT_RISULTATODIGARA_ROW_VIEW
			--		where StatoFunzionale=''Inviato''						
			--) DR on DR.leg=ctl_doc.id 

		where tipodoc in ( ''BANDO_SEMPLIFICATO'' , ''BANDO_GARA'', ''BANDO_CONCORSO'' ) 
				and ctl_doc.statofunzionale not in (''InLavorazione'' , ''InApprove'' , ''Rifiutato'') 
				and ctl_doc.deleted = 0 and document_bando.EvidenzaPubblica = ''1''
	'
	
	--if @Descrizione <> '' 
	--begin
	--	set @SQLCmd = @SQLCmd + ' inner join ( select distinct idheader from document_microlotti_dettagli d with(nolock) where d.tipodoc = ''CONVENZIONE'' and d.DESCRIZIONE_CODICE_REGIONALE like ''%' + replace ( @Descrizione  , '''' , '''''' ) + '%'' ) as D on d.idheader = C.id '
	--end
	
	--set @SQLCmd = @SQLCmd + ' where (  c.idPfuInCharge = ' + cast( @IdPfu as varchar(10)) + ' or  c.idpfu = ' + cast( @IdPfu as varchar(10)) + ' or c.UserRUP = ' + cast( @IdPfu as varchar(10)) + ' or c.IdPfu_Firmatario = ' + cast( @IdPfu as varchar(10)) + ' or v.idpfu is not null  )  '



	if 	@SQLWhere <> ''
		set   @SQLCmd = @SQLCmd +  ' and ' + @SQLWhere
	

	
	if @Filter_App <> ''
		set   @SQLCmd = @SQLCmd + ' and ( ' + @Filter_App + ' ) '
	
	--if rtrim( @Sort ) <> ''
	--	set @SQLCmd=@SQLCmd + ' order by ' + @Sort

	-- popola la #temp
	--set @SQLCmd=@SQLCmd + '   select * from #temp'
	--exec (@SQLCmd)

	--return

	--print @SQLCmd
	--print '----------------------------------------------------------------'


	set @SQLCmd = @SQLCmd +  '   

		select 
			ID,
			IdMsg, 
			#temp.IdPfu, 
			msgIType, 
			IDDOCR, 
			--0 as Precisazioni,
			CASE WHEN Dr.leg IS NULL THEN 0 
			   ELSE 1 
			END AS Precisazioni,
			OpenDettaglio ,
			Name,
			IdDoc, 

			ProtocolloBando,
			CIG, 
			ProtocolloOfferta, 
			ReceivedDataMsg, 
			case
				 when #temp.statofunzionale = ''revocato'' then ''<strong>Bando Revocato - </strong> '' + cast(Body as nvarchar (2000)) 				
				 when #temp.statofunzionale = ''InRettifica'' then ''<strong>Bando In Rettifica - </strong> '' + cast(Body as nvarchar (2000)) 
				 when #temp.statofunzionale = ''Sospeso'' then ''<strong>Procedura Sospesa - </strong> '' + cast(Body as nvarchar (2000)) 
				 when #temp.statofunzionale = ''InSospensione'' then ''<strong>Procedura in Sospensione - </strong> '' + cast(Body as nvarchar (2000)) 
			else
				case 
					when isnull(v.linkeddoc,0) > 0 and V.TipoModifica =  ''RIPRISTINO_GARA'' then ''<strong>Procedura Ripristinata - </strong> '' + cast( Body as nvarchar(4000)) 
					when isnull(v.linkeddoc,0) > 0 and V.TipoModifica <> ''RIPRISTINO_GARA'' then  ''<strong>Bando Rettificato - </strong> '' + cast( Body as nvarchar(4000)) 
				else
					cast( Body as nvarchar(4000)) 
				end				
			end as Oggetto,		


			Tipologia, 
			ExpiryDate, 
			ExpiryDateAl, 

			ImportoBaseAsta,
			
			tipoprocedura, 
			StatoGD, 
			CriterioAggiudicazione, 
			
			EnteAppaltante,
			
			Appalto_Verde,
			Acquisto_Sociale ,
			
			TipoBandoGara ,
			IdMittente ,
			AZI_Ente,			
			 EvidenzaPubblica,
			 DOCUMENT ,
			 OPEN_DOC_NAME ,
			Bando_Verde_Sociale,
			Protocollo,
			 SedutaVirtuale,
			EnteProponente  , msgISubType, Scaduto
			
		from #temp with (nolock)
			
			
			left  join (
			
			
					select d.linkedDoc , TipoDoc as TipoModifica  from ctl_doc d with(nolock) 
						inner join ( 
										Select max(id) as ID_DOC ,  linkedDoc 
											from ctl_doc  with(nolock) 
												where tipodoc IN (''RETTIFICA_BANDO'',''PROROGA_BANDO'',''RETTIFICA_GARA'',''PROROGA_GARA''  , ''RIPRISTINO_GARA''  ) 
												and Statodoc =''Sended'' group by linkedDoc  
										) as M on M.id_DOC = d.id
			
					) V on V.LinkedDoc=#temp.id

			left outer join
			(
				select distinct leg
					from
						DOCUMENT_RISULTATODIGARA_ROW_VIEW
					where StatoFunzionale=''Inviato''						
			) DR on DR.leg=#temp.id 

		where #temp.tipodoc in ( ''BANDO_SEMPLIFICATO'' , ''BANDO_GARA'' ,''BANDO_CONCORSO'') 
				and #temp.statofunzionale not in (''InLavorazione'' , ''InApprove'' , ''Rifiutato'') 
				and #temp.deleted = 0 and #temp.EvidenzaPubblica = ''1'' 
	'

	if @DescTipoProcedura <> ''
	begin
		set   @SQLCmd = @SQLCmd +  ' and DescTipoProcedura = ''' + @DescTipoProcedura + ''' '
	end

	if 	@SQLWhere_orig  <> ''
		set   @SQLCmd = @SQLCmd +  ' and ' + @SQLWhere_orig
	

	
	if @Filter <> ''
		set   @SQLCmd = @SQLCmd + ' and ( ' + @Filter + ' ) '
	
	if rtrim( @Sort ) <> ''
		set @SQLCmd=@SQLCmd + ' order by ' + @Sort

	
	
	

	--print @SQLCmd

	exec ( @SQLCmd )
	
	

	--select @cnt = count(*) from #temp
	--set @cnt = @@rowcount

end



GO
