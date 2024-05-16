USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DASHBOARD_SP_VIEW_LOTTI_GARA_ATTESA_CONVENZIONE]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE proc [dbo].[OLD_DASHBOARD_SP_VIEW_LOTTI_GARA_ATTESA_CONVENZIONE]
(@IdPfu							int,
 @AttrName						varchar(8000),
 @AttrValue						varchar(8000),
 @AttrOp 						varchar(8000),
 @Filter                        varchar(8000),
 @Sort                          varchar(8000),
 @Top                           int,
 @Cnt                           int output,
 @nIsExcel						int = 0
)
as
	declare @Param varchar(8000)
	declare @Profilo as varchar(1500)
	declare @Ruolo as varchar(1500)
	
	set nocount on

	--set @Param = Replace(@AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp,' ','')
	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp

	--print @Param
	
	--recupero i parametri Profilo e UserRole 
    --set @Profilo = dbo.GetParam( 'Profilo' , @Param ,1)
	--set @Ruolo = dbo.GetParam( 'UserRole' , @Param ,1)
	

	--print 	@Profilo
	
	--costruisco select da eseguire
	declare @SQLCmd			varchar(8000)
	declare @SQLWhere		varchar(8000)
	
	--ricavo la condizone di where di base basata sulle colonne della vista
	set @SQLWhere = dbo.GetWhere( 'DASHBOARD_VIEW_LOTTI_GARA_ATTESA_CONVENZIONE' , 'V', @AttrName ,  @AttrValue ,  @AttrOp )

	set @SQLCmd = ''

	--se sto facendo EXCEL metto in una tabella TEMP le descrizioni per il campo StatoUtenti
	--if @nIsExcel = 1
	--BEGIN
	--	set @SQLCmd = '
	--		select 
	--			DMV_DM_ID as Dominio, DMV_Cod as Codice , isnull( cast( ML_Description as nvarchar(4000)) , Dmv_descML)  as Descrizione
	--				into #Desc_Domini
	--			from LIB_DomainValues with (nolock)
	--				left outer join LIB_Multilinguismo with (nolock) on ML_KEY = DMV_DescML and ML_LNG=''I''
	--			where DMV_DM_ID in (''statoutenti'',''TIPO_AMM_ER'')

	--		'
	--END

	set @SQLCmd = '

		select 
			distinct  CONV.id as IdConvenzione, DETT_CONV.AZI_Dest,lottic.cig 
			into #temp

			from 
				ctl_doc CONV with(nolock)
					inner join Document_Convenzione DETT_CONV  with(nolock) on DETT_CONV.ID=CONV.id
					left join Document_MicroLotti_Dettagli lottiC with(nolock) ON lottiC.idheader = CONV.id and lottic.TipoDoc = CONV.tipodoc
				where 
					CONV.tipodoc=''CONVENZIONE''  and CONV.Deleted = 0  '


	set @SQLCmd =  @SQLCmd +
			'
			
			select min( id ) as id , idheader  , IdaziAggiudicataria , NumeroLotto
					into #Comunicazioni
							from 
								Document_comunicazione_StatoLotti  with(nolock) 
							where  Deleted = 0 group by idheader , IdaziAggiudicataria , NumeroLotto


			select 

				 D.id as ID, 		 
				 D.idheader, 		
				 C.Protocollo,
				 c.ProtocolloRiferimento,
				 cast(C.Body as nvarchar(4000)) as Descrizione,
				 C.Data as DataInvio,
				 D.IdaziAggiudicataria as muIdAziDest,
				 D.IdaziAggiudicataria as idAzi2,
				 C.tipodoc as GridViewer_OPEN_DOC_NAME,
				C.id as GridViewer_ID_DOC,

				pu.IdPfu as idpfu , 
				C.idpfu as idpfuRup,
				isnull(TipoProceduraCaratteristica,'''') as TipoProceduraCaratteristica
				,isnull(lotti.CIG, db.cig) as CIG,
				lotti.NumeroLotto
				,ISNULL(TipoSceltaContraente,'''') as TipoSceltaContraente
				,lotti.StatoRiga

		from ctl_doc C   with(nolock)

				inner join #Comunicazioni as D  on C.id=D.idheader 

				inner join ctl_doc c1   with(nolock) on c.linkedDoc=c1.id and C1.tipodoc=''PDA_MICROLOTTI'' and c1.Deleted = 0
				inner join Document_MicroLotti_Dettagli lotti with(nolock) on lotti.IdHeader = C.LinkedDoc and lotti.TipoDoc = ''PDA_MICROLOTTI'' 
												and lotti.NumeroLotto = D.NumeroLotto and ISNULL(lotti.voce,0) = 0 
												and lotti.StatoRiga in (''AggiudicazioneDef'', ''AggiudicazioneCond'')			
				
				inner join Document_PDA_OFFERTE PDA_OFF with(nolock)  on PDA_OFF.idheader=C1.id
				inner join Document_MicroLotti_Dettagli DMO with(nolock) on PDA_OFF.IdRow=DMO.IdHeader and DMO.TipoDoc=''PDA_OFFERTE'' 																		
																			and  ( DMO.Posizione like ''Idoneo%'' or DMO.Posizione like ''Aggiudicatario%'')
																			and DMO.numerolotto=D.numerolotto and DMO.voce=0 and PDA_OFF.idAziPartecipante=D.IdAziAggiudicataria
																		

				inner join ctl_doc c2   with(nolock) on c1.linkedDoc=c2.id and C2.tipodoc IN ( ''BANDO_GARA'',''BANDO_SEMPLIFICATO'')
			
				inner join document_bando DB   with(nolock) on C2.id=DB.idheader 
						
				left join	#temp			
					
					as CONVENZIONE on CONVENZIONE.AZI_Dest=D.IdAziAggiudicataria 
								and (  ( isnull(CONVENZIONE.CIG,'''') = lotti.cig and Divisione_lotti <> ''0'')
										 or 
									   ( Divisione_lotti = ''0'' and isnull(CONVENZIONE.CIG,'''') = db.cig )
									 )
	
		
				inner join ProfiliUtente as pu with(nolock) on c2.Azienda = pu.pfuIdAzi


		where C.tipodoc=''PDA_COMUNICAZIONE_GENERICA''
				and C.jumpcheck=''0-ESITO_DEFINITIVO_MICROLOTTI''
				and C.statoDoc=''Sended''
				
				and	CONVENZIONE.CIG is null				
				
			
				and isnull(DB.GeneraConvenzione,''0'') = ''1''


				and pu.IdPfu = ' + cast(@IdPfu as varchar(10))

			
			

	if 	@SQLWhere <> ''
	begin
		set @SQLWhere = REPLACE(@SQLWhere, 'StatoRiga','lotti.StatoRiga')		
		set @SQLWhere = REPLACE(@SQLWhere, 'idpfuRup','C.idpfu')
		set @SQLWhere = REPLACE(@SQLWhere, 'Protocollo','C.Protocollo')
		set @SQLWhere = REPLACE(@SQLWhere, 'Descrizione','cast(C.Body as nvarchar(4000))')
		set @SQLWhere = REPLACE(@SQLWhere, 'CIG','isnull(lotti.CIG, db.cig)')
		set @SQLWhere = REPLACE(@SQLWhere, 'NumeroLotto','lotti.NumeroLotto')
		set @SQLWhere = REPLACE(@SQLWhere, 'idAzi2','D.IdaziAggiudicataria')
		set @SQLWhere = REPLACE(@SQLWhere, 'TipoProceduraCaratteristica','isnull(TipoProceduraCaratteristica,'''') ')
		set @SQLWhere = REPLACE(@SQLWhere, 'TipoSceltaContraente','ISNULL(TipoSceltaContraente,'''') ')
		
		
		set   @SQLCmd = @SQLCmd + ' and  ' + @SQLWhere
	end
	

if @Sort <> ''
	set @SQLCmd=@SQLCmd + ' order by  ' + @Sort

--print @SQLCmd
exec (@SQLCmd)

	--select @cnt = count(*) from #temp
	--set @cnt = @@rowcount






GO
