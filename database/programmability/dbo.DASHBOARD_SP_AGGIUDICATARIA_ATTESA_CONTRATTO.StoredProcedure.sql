USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DASHBOARD_SP_AGGIUDICATARIA_ATTESA_CONTRATTO]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE proc [dbo].[DASHBOARD_SP_AGGIUDICATARIA_ATTESA_CONTRATTO]
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
	declare @SQLCmd			varchar(max)
	declare @SQL			varchar(max)
	declare @SQLWhere		varchar(max)

	--ricavo la condizone di where di base basata sulle colonne della vista 
	set @SQLWhere = dbo.GetWhere( 'DASHBOARD_VIEW_AGGIUDICATARIA_ATTESA_CONTRATTO' , 'V',@AttrName ,  @AttrValue ,  @AttrOp )
	--print @SQLWhere
	if @Filter = ''
	 set   @Filter = ' 1 = 1 '
	
	--CREO LA TEMP TABLE DOVE METTO I RECORD
	select top 0 * into #tmp from DASHBOARD_VIEW_AGGIUDICATARIA_ATTESA_CONTRATTO
	
	--CREO LO SCRIPT PER RECUPERARE I DATI PRIMA CON IDPFU della pda 
	-- e poi per vedere se esiste un subentro e passare la visibilità al nuovo utente sulla comunicazione di esito
	set @SQL='
	(
	select 
		 --min (D.id) as ID, 
		 D.id as ID, 
		 D.idheader, 
		 C.Protocollo,
		 cast(C.Body as nvarchar(4000)) as Descrizione,
		 C.Data as DataInvio,
		 D.IdaziAggiudicataria as muIdAziDest,
		 C.tipodoc as GridViewer_OPEN_DOC_NAME,
		 --min(c.id) as GridViewer_ID_DOC
		C.id as GridViewer_ID_DOC,
		--min(C.idpfu) as idpfu ,
		--C.idpfu,
		--isnull( SUB.Value , C1.IdPfu ) as idpfu,
		C.IdPfu ,
		TipoProceduraCaratteristica		
	from  
		ctl_doc C   with(nolock) 
			--inner join ( select  min (id) as ID,  idheader , IdaziAggiudicataria, NumeroLotto from Document_comunicazione_StatoLotti with(nolock) where Deleted = 0 group by idheader , IdaziAggiudicataria , NumeroLotto) as D  on C.id=D.idheader --and d.Deleted = 0
			inner join ( select  min (id) as ID,  idheader , IdaziAggiudicataria from Document_comunicazione_StatoLotti with(nolock) where Deleted = 0 group by idheader , IdaziAggiudicataria ) as D  on C.id=D.idheader --and d.Deleted = 0
			inner join ctl_doc c1   with(nolock) on c.linkedDoc=c1.id and C1.tipodoc=''PDA_MICROLOTTI'' and C1.deleted=0
			--inner join Document_MicroLotti_Dettagli lotti with(nolock) on lotti.IdHeader = C.LinkedDoc and lotti.TipoDoc = ''PDA_MICROLOTTI'' and lotti.NumeroLotto = D.NumeroLotto  and ISNULL(lotti.voce,0) = 0 and lotti.StatoRiga=''AggiudicazioneDef''
			inner join ( select distinct idheader from Document_MicroLotti_Dettagli lotti with(nolock) where lotti.TipoDoc = ''PDA_MICROLOTTI'' and ISNULL(lotti.voce,0) = 0 and lotti.StatoRiga=''AggiudicazioneDef'' group by Idheader  ) DM on DM.IdHeader = C.LinkedDoc
			inner join ctl_doc c2   with(nolock) on c1.linkedDoc=c2.id and C2.tipodoc=''BANDO_GARA''
			inner join document_bando DB   with(nolock) on C2.id=DB.idheader and ProceduraGara=15478  --15478 negoziata
			left outer join ctl_doc_value SUB with( nolock ) on SUB.DSE_ID=''Subentro'' and dzt_name = ''Subentro''  and c.id = SUB.idheader 
			left join CTL_DOC_Value Stip_Contr with (nolock)  on Stip_Contr.IdHeader = C.Id 
															and Stip_Contr.DSE_ID =''DIRIGENTE''
															and Stip_Contr.DZT_NAME=''StipulaDelContratto''
			
	where 
		C.tipodoc=''PDA_COMUNICAZIONE_GENERICA''
		and C.jumpcheck=''0-ESITO_DEFINITIVO_MICROLOTTI''
		and C.statoDoc=''Sended''
		and C.id not in 
			(
			select linkeddoc 
				from ctl_doc S with(nolock) 
					inner join Document_MicroLotti_Dettagli SD with(nolock) on SD.idheader=S.id and SD.TipoDoc = ''SCRITTURA_PRIVATA'' -- and SD.numerolotto=D.NumeroLotto
				where S.tipodoc=''SCRITTURA_PRIVATA'' 
					and S.statofunzionale in (''Confermato'',''InLavorazione'',''Inviato'') 
					and S.destinatario_azi=D.IdAziAggiudicataria and S.deleted=0

			  )
		and  SUB.Value is null
		and  C.idpfu = '+ cast( @IdPfu as varchar(10)) + ' and ( ' + @Filter + ' ) 
		--stilupacontratto sulla com di esito deve essere si
		--se non presente per il pregresso è come se fosse si
		and ISNULL(Stip_Contr.value,''1'')=''1''

	)'
	--print @SQL
	insert into #tmp
		execute(@SQL)

	set @SQL='
	(
	select 
		 --min (D.id) as ID, 
		 D.id as ID, 
		 D.idheader, 
		 C.Protocollo,
		 cast(C.Body as nvarchar(4000)) as Descrizione,
		 C.Data as DataInvio,
		 D.IdaziAggiudicataria as muIdAziDest,
		 C.tipodoc as GridViewer_OPEN_DOC_NAME,
		 --min(c.id) as GridViewer_ID_DOC
		C.id as GridViewer_ID_DOC,
		--min(C.idpfu) as idpfu ,
		--C.idpfu,
		--isnull( SUB.Value , C1.IdPfu ) as idpfu,
		SUB.Value as IdPfu ,
		TipoProceduraCaratteristica		
	from  
		ctl_doc C   with(nolock) 
			inner join ( select  min (id) as ID,  idheader , IdaziAggiudicataria, NumeroLotto from Document_comunicazione_StatoLotti with(nolock) where Deleted = 0 group by idheader , IdaziAggiudicataria , NumeroLotto) as D  on C.id=D.idheader --and d.Deleted = 0
			--inner join ( select  min (id) as ID,  idheader , IdaziAggiudicataria from Document_comunicazione_StatoLotti with(nolock) where Deleted = 0 group by idheader , IdaziAggiudicataria ) as D  on C.id=D.idheader --and d.Deleted = 0
			inner join ctl_doc c1   with(nolock) on c.linkedDoc=c1.id and C1.tipodoc=''PDA_MICROLOTTI'' and C1.deleted=0
			inner join Document_MicroLotti_Dettagli lotti with(nolock) on lotti.IdHeader = C.LinkedDoc and lotti.TipoDoc = ''PDA_MICROLOTTI''  and lotti.NumeroLotto = D.NumeroLotto and ISNULL(lotti.voce,0) = 0  and lotti.StatoRiga=''AggiudicazioneDef''
			inner join ctl_doc c2   with(nolock) on c1.linkedDoc=c2.id and C2.tipodoc=''BANDO_GARA''
			inner join document_bando DB   with(nolock) on C2.id=DB.idheader and ProceduraGara=15478  --15478 negoziata
			inner join ctl_doc_value SUB with( nolock ) on SUB.DSE_ID=''Subentro'' and dzt_name = ''Subentro''  and c.id = SUB.idheader 
			left join CTL_DOC_Value Stip_Contr with (nolock)  on Stip_Contr.IdHeader = C.Id 
															and Stip_Contr.DSE_ID =''DIRIGENTE''
															and Stip_Contr.DZT_NAME=''StipulaDelContratto''
				
	where 
		C.tipodoc=''PDA_COMUNICAZIONE_GENERICA''
		and C.jumpcheck=''0-ESITO_DEFINITIVO_MICROLOTTI''
		and C.statoDoc=''Sended''
		and C.id not in 
			(
			select linkeddoc 
				from ctl_doc S with(nolock) 
					inner join Document_MicroLotti_Dettagli SD with(nolock) on SD.idheader=S.id and SD.TipoDoc = ''SCRITTURA_PRIVATA'' and SD.numerolotto=D.NumeroLotto
				where S.tipodoc=''SCRITTURA_PRIVATA'' 
					and S.statofunzionale in (''Confermato'',''InLavorazione'',''Inviato'') 
					and S.destinatario_azi=D.IdAziAggiudicataria and S.deleted=0
			  )
		and  SUB.Value = '+ cast( @IdPfu as varchar(10)) + ' and ( ' + @Filter + ' ) 
		--stilupacontratto sulla com di esito deve essere si
		--se non presente per il pregresso è come se fosse si
		and ISNULL(Stip_Contr.value,''1'')=''1''

	)'
	--print @SQL
	insert into #tmp
		execute(@SQL)
	--DIAMO LA VISIBILITA' AL RUP
	set @SQL='
	(
	select 
		 --min (D.id) as ID, 
		 D.id as ID, 
		 D.idheader, 
		 C.Protocollo,
		 cast(C.Body as nvarchar(4000)) as Descrizione,
		 C.Data as DataInvio,
		 D.IdaziAggiudicataria as muIdAziDest,
		 C.tipodoc as GridViewer_OPEN_DOC_NAME,
		 --min(c.id) as GridViewer_ID_DOC
		C.id as GridViewer_ID_DOC,
		--min(C.idpfu) as idpfu ,
		--C.idpfu,
		--isnull( SUB.Value , C1.IdPfu ) as idpfu,
		v2.value as IdPfu ,
		TipoProceduraCaratteristica		
	from  
		ctl_doc C   with(nolock) 
			inner join ( select  min (id) as ID,  idheader , IdaziAggiudicataria, NumeroLotto from Document_comunicazione_StatoLotti with(nolock) where Deleted = 0 group by idheader , IdaziAggiudicataria , NumeroLotto) as D  on C.id=D.idheader --and d.Deleted = 0
			--inner join ( select  min (id) as ID,  idheader , IdaziAggiudicataria from Document_comunicazione_StatoLotti with(nolock) where Deleted = 0 group by idheader , IdaziAggiudicataria ) as D  on C.id=D.idheader --and d.Deleted = 0
			inner join ctl_doc c1   with(nolock) on c.linkedDoc=c1.id and C1.tipodoc=''PDA_MICROLOTTI'' and C1.deleted=0
			inner join Document_MicroLotti_Dettagli lotti with(nolock) on lotti.IdHeader = C.LinkedDoc and lotti.TipoDoc = ''PDA_MICROLOTTI''  and lotti.NumeroLotto = D.NumeroLotto and ISNULL(lotti.voce,0) = 0  and lotti.StatoRiga=''AggiudicazioneDef''
			inner join ctl_doc c2   with(nolock) on c1.linkedDoc=c2.id and C2.tipodoc=''BANDO_GARA''
			inner join document_bando DB   with(nolock) on C2.id=DB.idheader and ProceduraGara=15478  --15478 negoziata
			-- recuperato il RUP della gara
			left outer join CTL_DOC_Value v2 with(nolock) on db.idheader = v2.idheader and v2.dzt_name = ''UserRUP'' and v2.DSE_ID = ''InfoTec_comune''
			left join CTL_DOC_Value Stip_Contr with (nolock)  on Stip_Contr.IdHeader = C.Id 
															and Stip_Contr.DSE_ID =''DIRIGENTE''
															and Stip_Contr.DZT_NAME=''StipulaDelContratto''
				
	where 
		C.tipodoc=''PDA_COMUNICAZIONE_GENERICA''
		and C.jumpcheck=''0-ESITO_DEFINITIVO_MICROLOTTI''
		and C.statoDoc=''Sended''
		and C.id not in 
			(
			select linkeddoc 
				from ctl_doc S with(nolock) 
					inner join Document_MicroLotti_Dettagli SD with(nolock) on SD.idheader=S.id and SD.TipoDoc = ''SCRITTURA_PRIVATA'' and SD.numerolotto=D.NumeroLotto
				where S.tipodoc=''SCRITTURA_PRIVATA'' 
					and S.statofunzionale in (''Confermato'',''InLavorazione'',''Inviato'') 
					and S.destinatario_azi=D.IdAziAggiudicataria and S.deleted=0
			  )
		and  v2.Value = '+ cast( @IdPfu as varchar(10)) + ' and ( ' + @Filter + ' ) 
		--stilupacontratto sulla com di esito deve essere si
		--se non presente per il pregresso è come se fosse si
		and ISNULL(Stip_Contr.value,''1'')=''1''

	)'
	--print @SQL
	insert into #tmp
		execute(@SQL)

	--select * from #tmp
	
	
	
	set @SQLCmd =  'select distinct c.* from #tmp c '

	--set @SQLCmd = @SQLCmd + ' where idpfu = ' + cast( @IdPfu as varchar(10))

	if 	@SQLWhere <> ''
		set   @SQLCmd = @SQLCmd +  ' where ' + @SQLWhere
	

	
	--if @Filter <> ''
	--	set   @SQLCmd = @SQLCmd + ' and ( ' + @Filter + ' ) '
	
	if rtrim( @Sort ) <> ''
		set @SQLCmd=@SQLCmd + ' order by ' + @Sort




	--select @SQLCmd
	exec (@SQLCmd)



end





GO
