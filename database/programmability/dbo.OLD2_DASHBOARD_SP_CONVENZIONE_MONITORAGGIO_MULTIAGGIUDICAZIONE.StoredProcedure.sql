USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_DASHBOARD_SP_CONVENZIONE_MONITORAGGIO_MULTIAGGIUDICAZIONE]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--use AFLink_PA_Dev 




CREATE proc [dbo].[OLD2_DASHBOARD_SP_CONVENZIONE_MONITORAGGIO_MULTIAGGIUDICAZIONE]
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
	declare @Macro_Convenzione as varchar(max) 
	declare @Lng as varchar(10)
	declare @MakeExcel as int
	declare @dm_query as nvarchar(max) 
	declare @Sql_Insert_Dinamici  nvarchar(max)
	declare @dm_id as nvarchar(500) 
	declare @FormatDinamici as varchar(100)
	declare @NomiColonneFrom as nvarchar(max)
    declare @LeftJoinDomain as nvarchar(max)
    declare @Cont as int
	declare @ListComunVista as varchar(max)
	declare @IdConv  as varchar(100)

	declare @Fornitore as nvarchar(500) 
	declare @Quota as float --varchar(100)
	declare @Totale as float --varchar(100)
	declare @Eroso as float
	declare @Cig as varchar(50)
	declare @Sql as nvarchar(max)


	set @MakeExcel=0
	set @Lng='I'

	set nocount on

	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp

	
	set @Ambito			= dbo.GetParam( 'Ambito'		, @Param ,1)
	set @Descrizione	= dbo.GetParam( 'Descrizione'	, @Param ,1)
	set @Macro_Convenzione	= dbo.GetParam( 'Macro_Convenzione'	, @Param ,1)	
	
	--nella FILTER è presente id della convenzione e lo ricavo
	if @Filter<>''
	begin
		set @IdConv= REPLACE( lower(@Filter) , 'idconv = ', '')
	
		select 
			distinct 
			--dettconv.IdHeader as idConv,
			dettconv.CIG,
			DCL.NumeroLotto as [Numero Lotto],
			DCL.Descrizione as [Descrizione Lotto],
	
			case
				when gr.id IS null then DCL.Importo
				else gr21.value 
			end AS [Valore Lotto] ,

			Tot_Altri_Ordinativi_Lotto as [Totale Ordinativi],

			case
				when gr.id IS null then AltreConv.Importo - Tot_Altri_Ordinativi_Lotto
				else gr21.value - Tot_Altri_Ordinativi_Lotto
			end AS Residuo,


			--AltreConv.cig as CigAltreConv,
			--AltreConv.IdHeader as IdAltraConv,
			--DC.Mandataria as Fornitore ,
			A.aziRagioneSociale, 

			case 
				when GR_Perc.PercAgg  = 100 then null
				else AltreConv.Importo 
			end as Quota,
			
			isnull(AltreConv.Impegnato,0) as Totale,

			dbo.AFS_ROUND ( (isnull(AltreConv.Impegnato,0)/AltreConv.importo)*100,2)  as [% Eroso] 
			
			--, isnull(GR_Perc.PercAgg,0) as PercAgg 

			into #t

			from 
				Document_Convenzione_Lotti DCL
		
					--recupero cig della convenzione
					left join 
						(	
							select 
								distinct cig,numerolotto,idheader 
								from 
									Document_MicroLotti_Dettagli with(NOLOCK) 
								where 
									tipodoc='CONVENZIONE'
						) dettConv on DCL.idHeader=dettConv.IdHeader and DCL.NumeroLotto=dettConv.NumeroLotto 		
		
					----cerco le altre convenzioni sullo stesso cig
					left join
					(
		
						select 
							distinct dettConv.IdHeader, dettConv.CIG, Importo, Impegnato
							--dettConv.CIG, sum(Importo) as Importo , Sum(Impegnato) as Impegnato
							from 
								Document_Convenzione_Lotti  DCL with(NOLOCK)
									inner join (
												select 
													distinct cig,numerolotto,idheader 
													from 
														Document_MicroLotti_Dettagli DETT_CONV with(NOLOCK) 
															inner join CTL_DOC CONV  with(NOLOCK)  on CONV.Id = IdHeader and CONV.StatoFunzionale <> 'inlavorazione' and CONV.Deleted =0
													where 
														DETT_CONV.tipodoc='CONVENZIONE'  
												) dettConv on DCL.idHeader=dettConv.IdHeader and DCL.NumeroLotto=dettConv.NumeroLotto
							--group by dettConv.CIG

					) AltreConv on  AltreConv.CIG = dettConv.cig --and dettconv.IdHeader <> AltreConv.IdHeader
			
					--salgo sulla pda per recuperare idlotto della pda a cui è legato il doc di graduatoria
					left join ( 
			
							select  lg.id  , cig , lg.tipodoc , lg.voce , lg.NumeroLotto , LinkedDoc 
								from Document_MicroLotti_Dettagli lg with(nolock)  
									inner join ctl_doc pda with(nolock) ON pda.id = lg.IdHeader and pda.deleted=0 and pda.TipoDoc = 'PDA_MICROLOTTI'
								where isnull( lg.voce , 0 ) = 0 and isnull( CIG ,'' ) <> ''					

							) as lg  on  lg.cig = AltreConv.CIG and lg.tipodoc = 'PDA_MICROLOTTI' and dettConv.NumeroLotto=lg.NumeroLotto 

					left join CTL_DOC gr with(nolock) on gr.linkeddoc= lg.Id and gr.TipoDoc = 'PDA_GRADUATORIA_AGGIUDICAZIONE' and gr.StatoFunzionale = 'Confermato' and gr.deleted=0
						
					left join document_microlotti_dettagli GR_Perc with(nolock) ON GR_Perc.idheader = gr.id and GR_Perc.tipodoc=gr.tipodoc and GR_Perc.percAgg=100
					
					left join CTL_DOC_Value gr21 with(nolock) ON gr21.IdHeader = gr.Id and gr21.DSE_ID = 'IMPORTO' and gr21.DZT_Name = 'ImportoAggiudicatoInConvenzione'

					left join (
						select dettConv.CIG, sum(ISNULL(Impegnato,0)) as Tot_Altri_Ordinativi_Lotto 
							from Document_Convenzione_Lotti  DCL with(NOLOCK)
								--inner join Document_MicroLotti_Dettagli dettConv with (nolock) on DCL.idHeader=dettConv.IdHeader and dettConv.tipodoc='CONVENZIONE' and DCL.NumeroLotto=dettConv.NumeroLotto and isnull(dettConv.voce,0) = 0 
								inner join (select distinct cig,numerolotto,idheader from Document_MicroLotti_Dettagli with(NOLOCK) where tipodoc='CONVENZIONE'  ) dettConv on DCL.idHeader=dettConv.IdHeader and DCL.NumeroLotto=dettConv.NumeroLotto
							group by dettConv.CIG
				
						) as z on z.CIG=AltreConv.CIG

					--salgo sui fornitori delle altre convenzioni per prendere la quota e l'eroso (impegnato/quota)*100
					inner join
						Document_Convenzione DC on DC.ID = AltreConv.IdHeader --and isnull(DC.AZI_Dest,0) <> 0 
					inner join 
						Aziende A on A.IdAzi = DC.Mandataria 

			
			where DCL.idHeader = @IdConv

			--if exists (select )
	
			--costruisco una tabella con le colonne fisse CIG,NumeroLotto, Valore Lotto, TotaleOrdinativi, REsiduo
			-- + 2 colonne per ogni fornitore [Quota Fornitore_01], [% Eroso Fornitore_01]
			select 
				distinct   CIG, [Numero Lotto], [Descrizione Lotto],[Valore Lotto],[Totale Ordinativi], 
						dbo.AFS_ROUND ( ( [Totale Ordinativi]/[Valore Lotto])*100,2) as [Percentuale Erosione] 
						
						into #t1  
				 
					from #t
				 order by CIG,[Numero Lotto] 

			--con un cursore per ogni fornitore aggiungo le colonne Quota e % Eroso e le valorizzo
			DECLARE crsForn CURSOR STATIC FOR 
	
				select cig, aziragionesociale, QUOTA,Totale, [% Eroso]  from  #t order by CIG,[Numero Lotto] 

			OPEN crsForn

			FETCH NEXT FROM crsForn INTO @Cig, @Fornitore,@Quota,@Totale,@Eroso
			WHILE @@FETCH_STATUS = 0
			BEGIN

				--select  dbo.FormatMoney(0.00)

				set @Sql = 
					'	IF NOT EXISTS (
							SELECT *
							FROM   tempdb.sys.columns
							WHERE  object_id = Object_id(''tempdb..#t1'') and name=''' +  REPLACE (@Fornitore,'''','''''') + ' - Quota''
						)
						BEGIN

							ALTER TABLE dbo.#t1 ADD
							[' +  REPLACE (@Fornitore,'''','''''') + ' - Quota] float --varchar(500) 
							--default ''''

							ALTER TABLE dbo.#t1 ADD
							[' +  REPLACE (@Fornitore,'''','''''') + ' - Totale ordinativi] float --varchar(500) 
							--default ''''

							ALTER TABLE dbo.#t1 ADD
							[' +  REPLACE (@Fornitore,'''','''''') + ' - % Eroso] float--varchar(500)  
							--default ''''

						END

					'

				--print @Sql
				exec (@Sql)
				

				
				 
				set @Sql =' update #t1 
								set 
									'

									if isnull(@Quota,0) <> 0 
										set @Sql =@Sql + '
															
											[' +  REPLACE (@Fornitore,'''','''''') + ' - Quota] = ' + cast(@Quota as varchar(50)) + ',	
										'

									set @Sql =@Sql + '
									[' +  REPLACE (@Fornitore,'''','''''') + ' - Totale ordinativi] = ' + cast(@Totale as varchar(50)) + ',

									
									[' +  REPLACE (@Fornitore,'''','''''') + ' - % Eroso] = ' + cast(@Eroso as varchar(50)) + '

									where cig = ''' + replace(@Cig,'''','''''') + ''''

				exec (@Sql)
				--print (@Sql)
				--SELECT dbo.formatfloat(null)
				--select dbo.FormatMoney ('12')

				FETCH NEXT FROM crsForn INTO @Cig, @Fornitore,@Quota,@Totale,@Eroso
			END

			CLOSE crsForn 
			DEALLOCATE crsForn 
	
	
			select * from  #t1 order by CAST([Numero Lotto] as int) asc

	end


end





GO
