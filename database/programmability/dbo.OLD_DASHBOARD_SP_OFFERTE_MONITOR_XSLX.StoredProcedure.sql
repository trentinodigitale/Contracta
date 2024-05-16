USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DASHBOARD_SP_OFFERTE_MONITOR_XSLX]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[OLD_DASHBOARD_SP_OFFERTE_MONITOR_XSLX]
(
	 @Filter                        varchar(8000)
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

	set @AttrName	= dbo.GetPos(@Filter , '#~#'  , 1 )
	set @AttrValue	= dbo.GetPos(@Filter , '#~#'  , 2 )
	set @AttrOp		= dbo.GetPos(@Filter , '#~#'  , 3 )
	

	--ricavo la condizone di where di base 
	set @SQLWhere = dbo.GetWhere( 'DASHBOARD_VIEW_REPORT_LISTA_PROCEDURE' , 'V',  @AttrName  ,  @AttrValue ,  @AttrOp )

	
	set @SQLCmd = ''

	
		
			
	set @SQLCmd =  '
			select 
				V.*
					into #tempOfferte
				from DASHBOARD_VIEW_REPORT_LISTA_PROCEDURE V 					
				where 1 = 1
				'	

	if 	@SQLWhere <> ''
		set   @SQLCmd = @SQLCmd + ' and ' + @SQLWhere

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
