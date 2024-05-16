USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DASHBOARD_SP_VALUTAZIONEGARE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE proc [dbo].[DASHBOARD_SP_VALUTAZIONEGARE]
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
	
	declare @Name as varchar(1500)
	declare @UtenteCommissione nvarchar(200)
	declare @consenti_accesso_per_ruolo as nvarchar(200)
	
	declare @Stato as varchar(100)
	
	set nocount on

	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp
	set @Name	= dbo.GetParam( 'Name'	, @Param ,1)

	set @Stato=''
	set @Stato	= dbo.GetParam( 'StatoFunzionale'	, @Param ,1)
	if @Stato is null 
		set @Stato=''
	
	set @UtenteCommissione = cast( @IdPfu as varchar) 

	--costruisco select da eseguire
	declare @SQLCmd			varchar(max)
	declare @SQL			varchar(max)
	declare @SQLWhere		varchar(max)
	
	--ricavo la condizone di where di base basata sulle colonne della vista 
	--set @SQLWhere = dbo.GetWhere( 'DASHBOARD_VIEW_VALUTAZIONEGARE' , 'V',@AttrName ,  @AttrValue ,  @AttrOp )
	--print @SQLWhere


	if @Filter = ''
	 set   @Filter = ' 1 = 1 '
	
	select @consenti_accesso_per_ruolo=dbo.PARAMETRI('CONSENTI_ACCESSO_PDA','RUOLO_COMMISSIONE','VALORE','','-1')
	
	-- recupero dall'utente passato in input tutte le gare a cui è collegato	
	select CTL.linkeddoc as idBando , 'COMM' as TipoUtente ,RuoloCommissione
		into #TempGare 
		from Document_CommissionePda_Utenti u  with(nolock)
			inner join CTL_DOC CTL  with(nolock) on CTL.id = u.idheader and CTL.TIPODOC='COMMISSIONE_PDA' and CTL.StatoFunzionale='Pubblicato' and CTL.jumpcheck <> '55;167' and ctl.deleted=0
		where u.UtenteCommissione = @UtenteCommissione  
	
	--SE TROVIAMO VALORIZZATO @consenti_accesso_per_ruolo filtro solo i ruoli consentiti
	if @consenti_accesso_per_ruolo <> ''
	BEGIN
		delete from #TempGare where RuoloCommissione not in ( @consenti_accesso_per_ruolo )
	END
	
	-- aggiungo le gare dove l'utente è il rup e non è già in commissione
	insert into #TempGare ( idBando  , TipoUtente,RuoloCommissione) 
		select RUP.IdHeader ,  'RUP' as TipoUtente,0
			from CTL_DOC_Value RUP with(nolock) 
			where RUP.DSE_ID='InfoTec_comune' and RUP.DZT_Name='UserRUP'
				and RUP.idheader not in ( select  idBando from #TempGare )
				and RUP.Value = @UtenteCommissione

	declare @PI_approvazione_diretta varchar(10)
	select @PI_approvazione_diretta =  dbo.PARAMETRI('BANDO_GARA','APPROVE','PI_DIRECT_APPROVE','',-1)

	if @PI_approvazione_diretta = 'YES'
		-- aggiunge le gare inviate di cui è PI ma solo se sono Affidamento diretto (15583)
		-- Richiesta di preventivo (15479)
		-- Consultazione preliminari di mercato (15585)
		insert into #TempGare ( idBando  , TipoUtente,RuoloCommissione) 
			select id ,  'COMM' as TipoUtente,0
				from CTL_DOC with(nolock) 
					inner join Document_Bando with(nolock)  on idHeader = Id 
				where TipoDoc = 'bando_gara' and Deleted=0 and IdPfu = @UtenteCommissione
					and StatoDoc = 'Sended'
					and ProceduraGara in ('15583','15479','15585')
					and id not in ( select  idBando from #TempGare )
				

	Create table #Gare ( idBando  int  , TipoUtente varchar(10) )
	
	--prendo le gare una volta sola
	if @Name <> '' 
	begin
		
		insert into #Gare ( idBando  , TipoUtente )
			select distinct idBando , TipoUtente
				from #TempGare 
					inner join ctl_doc with(nolock) on idBando = id
					where Titolo like '%' + @Name + '%'
	end
	else
	begin

		insert into #Gare ( idBando  , TipoUtente )
			select distinct idBando , TipoUtente
				from #TempGare 

	end


	-- effettuo la query finale

	set @SQLCmd = '

	select * from (
		SELECT 
		
			' + @UtenteCommissione + ' as Owner
			,d.id as IdMsg
			, d.IdPfu AS IdPfu
			, '''' as msgIType
			, '''' as msgISubType
			, -1 as msgelabwithsuccess
			, d.titolo as Name
			, cast( d.body as nvarchar(4000)) as Oggetto
			, b.ProtocolloBando as ProtocolloBando
			, b.DataScadenzaOfferta as ExpiryDate
			,case b.ImportoBaseAsta WHEN ''0'' then ''''
					else b.ImportoBaseAsta
			   end as ImportoBaseAsta
	
			,case b.CriterioAggiudicazioneGara WHEN ''0''then ''''
					else b.CriterioAggiudicazioneGara
			   end as CriterioAggiudicazioneGara
			, case d.statoFunzionale 
					when ''InLavorazione'' then 1 
					else ''2''
				end AS StatoGD
			 ,'''' as FaseGara
			 ,d.Data as DataCreazione
			 ,ReceivedQuesiti
			 ,b.tipoappalto
			 ,b.proceduragara
			 ,'''' as IdDocBando	
			 ,case when isnull(PDA.StatoFunzionale,'''')='''' and isnull(TipoProceduraCaratteristica,'''')=''RFQ'' then ''DaValutare'' else PDA.StatoFunzionale end as StatoFunzionale
			, case 
				when isnull( r.StatoRepertorio , '''' ) = '''' then ''InCorso''
				else r.StatoRepertorio 
			  end as StatoRepertorio 


			, case 
				--when VisualizzaNotifiche = ''0'' and getdate() < DataAperturaOfferte then null
				when VisualizzaNotifiche = ''0'' and getdate() < DataScadenzaOfferta then null		
				else RecivedIstanze
			  end as ReceivedOff 


			, case 
				when d.Tipodoc  in (''BANDO_GARA'',''BANDO_SEMPLIFICATO'') then ''BANDO_SEMPLIFICATO''
				else d.Tipodoc 
			end	as OPEN_DOC_NAME
	
			,
			case 
				when d.statofunzionale in (''InLavorazione'',''InApprove'') then ''''
				else
					case b.EvidenzaPubblica
						when ''1'' then
							case 
								when isnull(CT.deleted,1)=1 then ''1''
								else ''0''
							end
						else ''0''
					end 
		
			end as DocumentoPubblicato

			,
			
			case 
				when d.TipoDoc = ''BANDO_CONCORSO'' then ''PDA_CONCORSO''
				else ''PDA_MICROLOTTI'' 
			end as MAKE_DOC_NAME
			--''PDA_MICROLOTTI''  as MAKE_DOC_NAME

			, isnull(TipoProceduraCaratteristica,'''') as TipoProceduraCaratteristica 
			, d.Tipodoc 
			, isnull(TipoSceltaContraente,'''') as TipoSceltaContraente
			, CU.Cottimo_Gara_Unificato
		from 
			#Gare g
				inner join CTL_DOC as d with(nolock , INDEX (ICX_CTL_DOC_id) ) on idBando = d.id

				inner join document_bando b with(nolock) on d.id = b.idheader

				left outer join Document_Repertorio r with(nolock) on r.ProtocolloBando = b.ProtocolloBando

				left outer join CTL_DOC CT with(nolock) on CT.TipoDoc=''BANDO_NON_VIS'' and CT.linkedDoc=D.id and CT.jumpcheck=D.TipoDoc and ct.deleted = 0 
				left outer join ctl_doc PDA with(nolock) on PDA.TipoDoc in (''PDA_MICROLOTTI'',''PDA_CONCORSO'') and PDA.linkedDoc=D.id and PDA.jumpcheck=D.TipoDoc and PDA.deleted=0

				--vedo tramite parametro se il Cottimo è unificato alle Procedure di gara
				cross join (select dbo.PARAMETRI(''GROUP_Procedura'',''Cottimo_Gara_Unificato'',''ATTIVO'',''NO'',-1 ) as Cottimo_Gara_Unificato ) CU  


		where 
			d.TipoDoc in (''BANDO_GARA'',''BANDO_SEMPLIFICATO'',''BANDO_CONCORSO'') -- Aggiunto il nuovo tipo doc BANDO_CONCORSO per concorsi di idee e progettazione
			and d.deleted=0 
			and ( getdate() >= b.DataScadenzaOfferta  or b.tipoProceduraCaratteristica = ''RFQ'' )
			and d.StatoFunzionale not in  (''InLavorazione'',''Rifiutato'',''InApprove'')  --AGGIUNTA PER NON FAR USCIRE LE GARE INFORMALI PRIMA DELLA SCADENZA
		
			--and ( DC.UtenteCommissione IS NOT NULL or b.ProceduraGara  in (''15583'',''15479'') )--AGGIUNTA PER NON FAR USCIRE LE GARE NON INFORMALI SENZA COMMISSIONE
			and ( g.TipoUtente = ''COMM'' or b.ProceduraGara  in (''15583'',''15479'') or b.tipoProceduraCaratteristica = ''RFQ''  )--AGGIUNTA PER NON FAR USCIRE LE GARE NON INFORMALI SENZA COMMISSIONE

			and b.tipobandogara not in (''4'',''5'') -- per escludere gli avvisi dell''AFFIDAMENTO DIRETTO A DUE FASI

		'	
		
	if @stato <> '' 
		--set @SQLCmd = @SQLCmd + ' and PDA.statofunzionale = ''' + @stato + ''''
		set @SQLCmd = @SQLCmd + ' and case when isnull(PDA.StatoFunzionale,'''')='''' and isnull(TipoProceduraCaratteristica,'''')=''RFQ'' then ''DaValutare'' else PDA.StatoFunzionale end = ''' + @stato + ''''
		

	set @SQLCmd = @SQLCmd + ' 
	
	) as a 
	
'

	--if 	@SQLWhere <> ''
	--	set   @SQLCmd = @SQLCmd +  ' where ' + @SQLWhere
	

	
	if @Filter <> ''
	begin

		set   @SQLCmd = @SQLCmd + ' where ( ' +   @Filter   + ' ) '
	
	end	

	if rtrim( @Sort ) <> ''
	begin

		set @SQLCmd = @SQLCmd +  ' order by ' + @Sort

	end


	--print @SQLCmd
	--select @SQLCmd
	exec (@SQLCmd)



end









GO
