USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_RISOLVE_VERBALEGARA_Document_ValoreOfferta_Contratto]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE  PROC [dbo].[OLD2_RISOLVE_VERBALEGARA_Document_ValoreOfferta_Contratto] ( @Id int , @contesto as varchar(200))
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
	select 	
		@Divisione_lotti = isnull(Divisione_lotti,0), @PresenzaListino= isnull(PresenzaListino,0) , @IdBando= IdBando,
		@CriterioFormulazioneOfferte=CriterioFormulazioneOfferte
		 from 
			VERBALE_GARA_STIPULA_CONTRATTO_SetAttibValues  where id = @Id
			
	--select @PresenzaListino
	--return

	--if( @Divisione_lotti = '0' or  @PresenzaListino = '0' or  @PresenzaListino = '' ) 
	if (  @PresenzaListino = '0' or  @PresenzaListino = '' ) 
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
				

				select top 100000 @valore_calcolato = @valore_calcolato + '' <div> Lotto '' + DM.NumeroLotto + '' - '' + cast ( dbo.FormatFloat_Virgola(  ISNULL(' + @AttribValoreOfferto +' ,''0'' ) ) as varchar ) + ''</div><br>''
								
					from Document_MicroLotti_Dettagli DM with(nolock) 						
					where DM.idheader= ' + cast( @id as varchar(50) ) + '  and dm.tipodoc=''CONTRATTO_GARA''
						order by cast( DM.NumeroLotto as int ) 
				
				select @valore_calcolato  as Esito
				'
		


	END
	
	

	exec (@strSQL)
	

END

















GO
