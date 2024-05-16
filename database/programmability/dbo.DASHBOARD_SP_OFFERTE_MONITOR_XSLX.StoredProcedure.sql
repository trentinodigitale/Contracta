USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DASHBOARD_SP_OFFERTE_MONITOR_XSLX]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE proc [dbo].[DASHBOARD_SP_OFFERTE_MONITOR_XSLX]
(
	 @Filter                        varchar(8000),
	 @FilterTable					varchar(8000),
	 @idpfu							varchar(1000)
)
as
begin

	--la chiamata arriva anche dalla cartella Report | Elenco procedure
	declare @AttrName						nvarchar(max)
	declare @AttrValue						nvarchar(max)
	declare @AttrOp 						varchar(8000)
	declare @SQLWhere						nvarchar(max)
	declare @SQLCmd							nvarchar(max)
	declare @Descrizione					as varchar(1500)
	declare @Cnt nvarchar(max)


	set @AttrName	= dbo.GetPos(@Filter , '#~#'  , 1 )
	set @AttrValue	= dbo.GetPos(@Filter , '#~#'  , 2 )
	set @AttrOp		= dbo.GetPos(@Filter , '#~#'  , 3 )
	set @SQLCmd = ''

	
	if @FilterTable = 'DASHBOARD_SP_VIEW_REPORT_LISTA_PROCEDURE_ENTE'
		begin 

			create table tempGare ( 
						id int,
						Ente varchar(max)
						, aziRagioneSociale varchar(max)                                               
						, AZI_Ente varchar(max)
						, Titolo varchar(max)
						, Oggetto varchar(max)	 
						, CriterioAggiudicazioneGara varchar(max)
						, StatoFunzionale varchar(max)
						, Registro varchar(max)
						, Fascicolo varchar(max)
						, Note varchar(max)
						, DataInvio varchar(max)
						, DataInvioAl varchar(max)
						, DataScadenzaOfferta varchar(max)
						, DataScadenzaA varchar(max)
						, ImportoBaseAsta2 varchar(max)
						, CIG varchar(max)
						, ImportoBaseAsta varchar(max)
						, RupProponente varchar(max)
						, EnteProponente varchar(max)
						, Opzioni varchar(max)
						, Oneri varchar(max)
						, DataPubblicazione varchar(max)
						, NumeroOfferte varchar(max)
						, CIG_LOTTO varchar(max)
						, NumeroLotto varchar(max)
						, RecivedIstanze varchar(max)
						, ValoreImportoLotto varchar(max)
						, tipoProceduraCaratteristica varchar(max)
						, ProceduraGara varchar(max)
						, TipoDoc varchar(max)
						, TipoAppaltoGara varchar(max)
						, DescTipoProcedura varchar(max)
						, Descrizione varchar(max)
						, pfuLogin varchar(max)                                      
						, UserRup varchar(max)
						, IdPfu varchar(max) 
						, ClassiMerceologiche varchar(max)
      					, ClassiMerceologicheLiv varchar(max)
						, Divisione_lotti varchar(max)
						, NumeroInvitati varchar(max)  
						, Aggiudicazione varchar(max)
						, IsAggiudicato varchar(max)
						, PrimoLivelloStruttura varchar(max)
						, TIPO_AMM_ER varchar(max)	  
						, ImportoAggiudicato varchar(max)	 
						, idPdA varchar(max)
						, idRowLotto varchar(max)
						, ambito varchar(max)
						, Appalto_Verde varchar(max)
						, Acquisto_Sociale varchar(max)
						, AppaltoInEmergenza varchar(max)
						, Appalto_PNRR varchar(max)
						, Appalto_PNC varchar(max)
						, IdentificativoIniziativa varchar(max)
						, GeneraConvenzione varchar(max)
						, StatoRiga varchar(max)
						, Data_Aggiudicazione_Lotto varchar(max)
				);

			insert into tempGare 
				EXEC DASHBOARD_SP_VIEW_REPORT_LISTA_PROCEDURE_ENTE @idpfu, @AttrName,@AttrValue,@AttrOp,'','','', ''  

			select distinct id into #templist from tempGare with(nolock)
				
			drop table tempGare	

				set @SQLCmd =  '
							select 
								V.*
							into #tempOfferte 
								from DASHBOARD_VIEW_REPORT_LISTA_PROCEDURE V with(nolock)
									inner join #templist lproc with(nolock) on lproc.Id = v.id
							where 1 = 1
				'	
		end
	else
		begin 
			--ricavo la condizone di where di base 
			set @SQLWhere = dbo.GetWhere( 'DASHBOARD_VIEW_REPORT_LISTA_PROCEDURE' , 'V',  @AttrName  ,  @AttrValue ,  @AttrOp )

			set @SQLCmd =  '
			select 
				V.*
					into #tempOfferte
				from DASHBOARD_VIEW_REPORT_LISTA_PROCEDURE V 					
				where 1 = 1
				'	

				if 	@SQLWhere <> ''
					set   @SQLCmd = @SQLCmd + ' and ' + @SQLWhere
		end

	

	set @SQLCmd =  @SQLCmd + 'select 
								V.*,
								o.idmsg AS IdOfferta,				
								model.value as idModello,
								o.aziRagionesociale as RagionesocialeFornitore,
								o.codicefiscale as Codicefiscalefornitore,
								offerta.DataScadenza as DatascaenzaOfferta,
								o.Posizione
					from 
					#tempOfferte V 
						inner join CTL_DOC_Value model with(nolock) ON model.IdHeader = V.id and model.dse_id = ''TESTATA_PRODOTTI'' and model.DZT_Name = ''id_modello'' and isnull(model.value,'''') <> ''''					
						inner join dashboard_view_pda_dati_offerte o with(nolock) on o.idPDA=V.idPdA and o.NumeroLotto=v.NumeroLotto and o.voce=0 and o.Posizione in (''Aggiudicatario definitivo'',''Idoneo definitivo'')
						inner join ctl_doc offerta with(nolock) on offerta.id=o.idmsg
					'


	
	--print @SQLCmd

	exec (@SQLCmd)
	
	--select @cnt = count(*) from #temp
	--set @cnt = @@rowcount



end
GO
