USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DASHBOARD_SP_LIVELLO_EROSIONE_GIC]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE proc [dbo].[OLD_DASHBOARD_SP_LIVELLO_EROSIONE_GIC]
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

	declare @Param varchar(max)
	declare @Sql as nvarchar(max)
    declare @Cig					as varchar(100)
	declare @Descrizione			as nvarchar(500)

	set nocount on

	--set @Param = Replace(@AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp,' ','')
	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp

	--recupero i parametri di filtro
    set @Cig					= dbo.GetParam( 'Cig' , @Param ,1)
	set @Descrizione					= dbo.GetParam( 'Descrizione' , @Param ,1)

	--recupero cig dalle convenzioni
	select 
		distinct DM.cig,DM.numerolotto,DM.idheader 
			into #Temp_Cig_Convenzioni 
		from Document_MicroLotti_Dettagli DM with(NOLOCK) 
			inner join ctl_doc C with(nolock) on C.id=DM.IdHeader and C.TipoDoc='CONVENZIONE' and C.Deleted=0 and C.StatoFunzionale <> 'InLavorazione'
			where DM.tipodoc='CONVENZIONE' and DM.cig <>'' 
				and ISNULL(C.JumpCheck,'')<>'INTEGRAZIONE' -- and DM.StatoRiga <> 'Trasferito'
	
	----recupero cig dalle PDA
	select  
		lg.id  , isnull(lg.cig,garadett.cig) as cig , lg.tipodoc , lg.voce , lg.NumeroLotto , LinkedDoc 
			into #Temp_Cig_PDA
		from Document_MicroLotti_Dettagli lg with(nolock)  
			inner join ctl_doc pda with(nolock) ON pda.id = lg.IdHeader and pda.deleted=0 and pda.TipoDoc = 'PDA_MICROLOTTI'
				inner join document_bando garaDett with (nolock) on garaDett.idheader =  pda.linkeddoc 
		where lg.Tipodoc = 'PDA_MICROLOTTI' and isnull( lg.voce , 0 ) = 0 and isnull(lg.cig,garadett.cig) <> '' 

	--recupero Impegnato per Atri Ordinativi Lotto
	--select 
	--	dettConv.CIG, sum(ISNULL(Impegnato,0)) as Tot_Altri_Ordinativi_Lotto 
	--		into #Temp_Tot_Altri_Ordinativi_Lotto
	--	from Document_Convenzione_Lotti  DCL with(NOLOCK)
	--		inner join 
	--				#Temp_Cig_Convenzioni
	--				dettConv on DCL.idHeader=dettConv.IdHeader and DCL.NumeroLotto=dettConv.NumeroLotto
	--	group by dettConv.CIG
	
	--select * from #Temp_Tot_Altri_Ordinativi_Lotto

	set @Sql = '
	
				select 

					dettConv.cig as id,

					dettConv.cig, 
	
					max(DCL.Descrizione) as Descrizione, 
					
					--case 
						--when ISNULL(aggiud.PercAgg,0) = 100 then sum ( importo ) / count(*) 
						--else 
						sum ( importo )  as Importo,
					--end as Importo , 

					sum (Impegnato)  as Impegnato, 
					
					--case 
					--	when ISNULL(aggiud.PercAgg,0) = 100 then
					--			( sum ( importo ) / count(*) )  - sum (Impegnato) 
					--	else 
								 sum ( importo )   - sum (Impegnato) as Residuo ,
					--end as Residuo ,

					--case 
					--	when ISNULL(aggiud.PercAgg,0) = 100 then
					--		(  sum ( Impegnato )  / ( sum ( importo ) /count(*)) ) * 100 
					--	else
							(  sum ( Impegnato )  /  sum ( importo )  ) * 100 as PercErosione
					--end as PercErosione

				from 
					
					Document_Convenzione_Lotti DCL with(NOLOCK)
						
						inner join #Temp_Cig_Convenzioni dettConv 
							on DCL.idHeader=dettConv.IdHeader and DCL.NumeroLotto=dettConv.NumeroLotto 		
						
						left join #Temp_Cig_PDA lg 
							on lg.cig = dettConv.CIG and lg.tipodoc = ''PDA_MICROLOTTI'' and dettConv.NumeroLotto=lg.NumeroLotto 
					
						left join Document_Bando gara with(nolock) 
							on gara.idHeader = lg.LinkedDoc and gara.TipoAggiudicazione=''Multifornitore''

						left join CTL_DOC gr with(nolock) 
							ON gr.LinkedDoc = lg.Id and gr.TipoDoc = ''PDA_GRADUATORIA_AGGIUDICAZIONE'' and gr.StatoFunzionale = ''Confermato'' 

						left join CTL_DOC_Value gr2 with(nolock) 
							ON gr2.IdHeader = gr.Id and gr2.DSE_ID = ''IMPORTO'' and gr2.DZT_Name = ''CIG_LOTTO'' and gr2.Value=dettConv.cig

						left join Document_Convenzione dc with(nolock) on dc.ID = DCL.IdHeader
	
						left join Document_microlotti_dettagli aggiud with(nolock) 
							ON aggiud.IdHeader = gr.Id and aggiud.TipoDoc = ''PDA_GRADUATORIA_AGGIUDICAZIONE'' and aggiud.Aggiudicata=dc.AZI_Dest --and ISNULL(aggiud.PercAgg,0) = 100
							--prendo solo 100 del destinatario della convenzione
	
						--left join CTL_DOC_Value gr21 with(nolock) 
						--	ON gr21.IdHeader = gr.Id and gr21.DSE_ID = ''IMPORTO'' and gr21.DZT_Name = ''ImportoAggiudicatoInConvenzione''
						
						--left join #Temp_Tot_Altri_Ordinativi_Lotto z on z.CIG=gr2.value
							
				where importo <> 0 and dettConv.cig <>'''' and DCL.descrizione <>'''' '

	if @Cig <> ''  
		set @Sql =  @Sql + ' and dettConv.cig like ''' + replace(@Cig,'''','''''')  + ''''
	
	if @Descrizione<> ''  
		set @Sql =  @Sql + ' and DCL.descrizione like ''' +  replace(@Descrizione,'''','''''') + ''''

	 set @Sql =  @Sql +
					'
					group by dettConv.cig,ISNULL(aggiud.PercAgg,0)
						order by dettConv.cig

					'

	exec ( @Sql )
	--print @Sql
		

	
	
	

end








GO
