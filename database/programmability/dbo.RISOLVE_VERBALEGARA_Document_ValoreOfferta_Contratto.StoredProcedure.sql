USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[RISOLVE_VERBALEGARA_Document_ValoreOfferta_Contratto]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE  PROC [dbo].[RISOLVE_VERBALEGARA_Document_ValoreOfferta_Contratto] ( @Id int , @contesto as varchar(200))
AS 
BEGIN 
	SET NOCOUNT ON
	
	declare @Divisione_lotti varchar(5)
	declare @PresenzaListino as varchar(10)
	declare @IdDocModello int
	declare @IdBando as int
	declare @strSQL as nvarchar(max)
	declare @AttribValoreOfferto as varchar(200)
	declare @CriterioFormulazioneOfferte as varchar(100)

	--set @valore_calcolato=''

	--recupero divisione lotti dalla gara
	--select 	
	--	@Divisione_lotti = isnull(Divisione_lotti,0), @PresenzaListino= isnull(PresenzaListino,0) , @IdBando= IdBando,
	--	@CriterioFormulazioneOfferte=CriterioFormulazioneOfferte
	--	 from 
	--		VERBALE_GARA_STIPULA_CONTRATTO_SetAttibValues  where id = @Id
			
	--select @Divisione_lotti
	--return

	select 
			@Divisione_lotti =isnull(Divisione_lotti,0),
			@PresenzaListino=isnull(C6.value,0),
			@IdBando=GARA.id,
			@CriterioFormulazioneOfferte=CriterioFormulazioneOfferte
			from ctl_doc CONTR with(nolock) 
				inner join CTL_DOC COM with(nolock)   on COM.id=CONTR.LinkedDoc and COM.Deleted =0
				inner join ctl_doc PDA with (nolock)  on PDA.id=COM.LinkedDoc and PDA.TipoDoc='PDA_MICROLOTTI' and PDA.Deleted=0
				inner join  CTL_DOC GARA with(nolock) on GARA.id=PDA.LinkedDoc and GARA.TipoDoc in ('BANDO_GARA' , 'BANDO_SEMPLIFICATO')
				inner join  Document_bando GARA_DETT with(nolock) on GARA_DETT.idHeader=GARA.id
				left join CTL_DOC_VALUE C6 with(nolock) on C6.IdHeader = CONTR.id and C6.dse_id='CONTRATTO' and C6.DZT_Name ='PresenzaListino'
			where contr.id=@Id

	--if( @Divisione_lotti = '0' or  @PresenzaListino = '0' or  @PresenzaListino = '' ) 
	if (@PresenzaListino = '0' or  @PresenzaListino = '' )
	BEGIN
			
			set @strSQL=' 
			
			declare @valore_calcolato nvarchar(MAX)
			set @valore_calcolato=''''
			select @valore_calcolato=  dbo.FormatFloat_Virgola( isnull(value,''''))
					from ctl_Doc_value with (nolock) where idheader = ' + cast( @id as varchar(50) ) + ' and dse_id=''CONTRATTO'' and DZT_Name =''NewTotal''

			select @valore_calcolato  as Esito

			'
			--set @valore_calcolato = dbo.FormatFloat_Virgola (@valore_calcolato)
			--select @valore_calcolato  as Esito
	END
	ELSE
	BEGIN
		--set @valore_calcolato=''
		
			
		select @IdDocModello = id from ctl_doc with (nolock) where tipodoc = 'CONFIG_MODELLI_LOTTI' and deleted = 0 and linkeddoc = @IdBando		
		
		--select @AttribValoreOfferto = value from ctl_doc_Value with (nolock) where idheader = @IdDocModello and dse_id='FORMULE' and dzt_name='Operatore1'

		select @AttribValoreOfferto= c1.value 
			from 
				ctl_doc_Value C1 with (nolock) 
					inner join ctl_doc_Value C2 with (nolock) on c2.IdHeader=C1.idheader and c2.row=c1.row and c2.DZT_Name='CriterioFormulazioneOfferte' and c2.value = @CriterioFormulazioneOfferte
			where 
				C1.idheader = @IdDocModello and C1.DSE_ID='FORMULE' and C1.dzt_name='Operatore1'



		

		set @strSQL='

				declare @valore_calcolato nvarchar(MAX)
				set @valore_calcolato=''''
				

				select top 100000 @valore_calcolato = @valore_calcolato '
				
				if  @Divisione_lotti <> '0'			
					set @strSQL =  @strSQL +	' + '' <div> Lotto '' + DM.NumeroLotto + '' - '' '
				
				set @strSQL =  @strSQL +  ' + cast ( dbo.FormatFloat_Virgola(  ISNULL(' + @AttribValoreOfferto +' ,''0'' ) ) as varchar ) '
				
				if  @Divisione_lotti <> '0'
					set @strSQL =  @strSQL +	' + ''</div><br>'''

				
				set @strSQL =  @strSQL + '	
					from 
						Document_MicroLotti_Dettagli DM with(nolock) 						
					where 
						DM.idheader= ' + cast( @id as varchar(50) ) + '  and dm.tipodoc=''CONTRATTO_GARA''
					order by cast( DM.NumeroLotto as int ) 
				
				select @valore_calcolato  as Esito

				'
		


	END
	
	
	--print (@strSQL)
	exec (@strSQL)
	

END

















GO
