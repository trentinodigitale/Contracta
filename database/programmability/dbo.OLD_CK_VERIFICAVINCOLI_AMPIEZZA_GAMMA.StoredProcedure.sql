USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CK_VERIFICAVINCOLI_AMPIEZZA_GAMMA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













CREATE  PROCEDURE [dbo].[OLD_CK_VERIFICAVINCOLI_AMPIEZZA_GAMMA]  (  @Iddoc int)
AS
BEGIN 
	
	

	SET NOCOUNT ON
	declare @idOfferta int
	declare @idmodAcquisto as int 
	declare @idModAmpGamma as Int
	declare @idBando INT
	declare @Espressione        nvarchar(2000)
	declare @EspressioneOrig    nvarchar(2000)	
	declare @DztNameAttrib      varchar(500)
	declare @DztDescAttrib      varchar(500)
	declare @DescrizioneVincolo	nvarchar(1000)
	declare @statement          nvarchar(MAX)		
	declare @AttribForExpr as varchar(500)
	declare @Type int	
	
	select  @idOfferta = LinkedDoc from ctl_doc with(nolock) where id = @idDoc 
	
	if exists(select id  from ctl_doc with(nolock) where id = @idDoc and TipoDoc='OFFERTA')
	begin
		set @idOfferta = @idDoc
	end

	select @idbando = LinkedDoc	from ctl_doc with(nolock) where id = @idOfferta

	select @idmodAcquisto = Value from ctl_doc_value with(nolock) where IdHeader = @idbando and DSE_ID = 'TESTATA_PRODOTTI' and DZT_Name = 'id_modello'
	
	select @idModAmpGamma = Value from ctl_doc_value with(nolock) where IdHeader = @idmodAcquisto and DSE_ID = 'AMBITO' and DZT_Name = 'TipoModelloAmpiezzaDiGamma'

	set @AttribForExpr=''

	--SE SUL MODELLO ESISTONO I VINCOLI PROCEDO A FARE I CONTROLLI
	IF EXISTS (select * from Document_Vincoli  with(nolock) where IdHeader=@idModAmpGamma)
	BEGIN
		--recupero i vincoli inclusi sul modello
		DECLARE crsVincoli CURSOR STATIC FOR 
		select Espressione, Descrizione, Espressione as EspressioneOrig from Document_Vincoli  with(nolock) where idheader=@idModAmpGamma

		OPEN crsVincoli
		FETCH NEXT FROM crsVincoli INTO @Espressione, @DescrizioneVincolo, @EspressioneOrig
		WHILE @@FETCH_STATUS = 0

		BEGIN
			--print @DescrizioneVincolo
			--print 'espressione origine=' + @Espressione
			set @AttribForExpr = ''	

			--se nell'espressione è presente la parola isMultiplo ci metto dbo d'avanti
			set @Espressione = REPLACE(@Espressione, 'isMultiplo(', 'dbo.isMultiplo(')

			--se nell'espressione è presente la parola isEmpty ci metto dbo d'avanti
			set @Espressione = REPLACE(@Espressione, ' isEmpty(', ' dbo.isEmpty(')

			--rimpiazzo gli operatori e le parentesi per assicurarci gli spazi davanti gli attributi
			set @Espressione = replace(@Espressione,'(', ' ( ')
			set @Espressione = replace(@Espressione,')', ' ) ')
			set @Espressione = replace(@Espressione,'+', ' + ')
			set @Espressione = replace(@Espressione,'-', ' - ')
			set @Espressione = replace(@Espressione,'*', ' * ')
			set @Espressione = replace(@Espressione,'/', ' / ')

			--Sostituisce i nomi delle colonne della microlotti dettagli alla nostra espressione
			declare @NumDec varchar(6)
			DECLARE crsAttrib CURSOR STATIC FOR 
			

				select CV.value as DztDescAttrib , CV2.Value as DztNameAttrib, d.DZT_Type,
						case when isnull(cv3.Value,'')='' then '0' else cv3.Value end  as NumDec
					from ctl_doc_value CV with(nolock)
						inner join ctl_doc_value CV2 with(nolock) on CV2.IdHeader=CV.IdHeader and CV.DSE_ID=CV2.DSE_ID and CV2.DZT_Name='DZT_Name' and CV2.Row=CV.Row
						left join LIB_Dictionary d with(nolock) on d.DZT_Name = cv2.value
						inner join ctl_doc_value CV3 with(nolock) on CV3.IdHeader=CV.IdHeader and CV.DSE_ID=CV3.DSE_ID and CV3.DZT_Name='Numero_Decimali' and CV3.Row=CV.Row
						where CV.idheader=@idModAmpGamma 
							and CV.dzt_name='Descrizione' and CV.DSE_ID='MODELLI'
				
			OPEN crsAttrib

			FETCH NEXT FROM crsAttrib INTO @DztDescAttrib,@DztNameAttrib, @Type, @NumDec
			WHILE @@FETCH_STATUS = 0
			BEGIN
				
				--print @DztNameAttrib
				set @DztDescAttrib = Replace(@DztDescAttrib, '''', '''''')

				--conservo il nome di un attributo presente nel vincolo per recuperare le caratteristiche lotto/lottovoce/ecc...
				if @AttribForExpr = '' and CHARINDEX ('[' + @DztDescAttrib + ']' , @Espressione) > 0 
					set @AttribForExpr = @DztNameAttrib
				
				if @Type = 2
				begin

					if @NumDec = '0'
						set @Espressione = replace(@Espressione,' ' + @DztNameAttrib + ' ' , ' cast ( ' + @DztNameAttrib +' as int) ' )							
					else
						set @Espressione = replace(@Espressione,' ' + @DztNameAttrib + ' ' , ' cast ( ' + @DztNameAttrib +' as float) ' )							
				
				end		
				
				if @Type in ( 4,5,8 ) --, 18 )
				begin
					set @Espressione = replace(@Espressione,' ' + @DztNameAttrib + ' ' , ' dbo.GetDescsValuesFromDztDomExt( ''' + @DztNameAttrib +''' , ' + @DztNameAttrib +' , ''I'' ) ' )							
				end
							
				FETCH NEXT FROM crsAttrib INTO @DztDescAttrib,@DztNameAttrib, @Type,@NumDec
			END
		
			CLOSE crsAttrib 
			DEALLOCATE crsAttrib 						
			
			--inserisco nella temp table tutti gli id del documento
			--che devono rispettare il vincolo a seconda del tipo di gara lotto/lotti singola voce/multivoce
			set @statement = ' 
				declare @SQL nvarchar(max)
				select id into #TEMP_WORK_TABLE_ID from document_microlotti_dettagli  with(nolock)  where tipodoc in ( ''OFFERTA_AMPIEZZA'' , ''OFFERTA_AMPIEZZA_DI_GAMMA'' ) and idheader=' + cast(@iddoc as varchar(500))  + ''
						
			--print @statement
			exec (@statement)
				
			--RIMUOVO QUELLI CHE RISPETTANO IL VINCOLO
			set @statement = @statement + '
			begin try
				
				set @SQL= ''delete from  #TEMP_WORK_TABLE_ID  where id in (select id from document_microlotti_dettagli with(nolock) where tipodoc in ( ''''OFFERTA_AMPIEZZA'''' , ''''OFFERTA_AMPIEZZA_DI_GAMMA'''') and idheader=' + cast(@iddoc as varchar(500)) + ' and ( ' + replace( @Espressione , '''' , '''''' ) + ') ) ''
				exec ( @SQL ) 			
			end try
			begin catch
				declare @err int
				set @err = 1
			end catch
			'

			--print @statement
			exec (@statement)

			--SE CI SONO RECORD SIGNIFICA CHE NON TUTTI I VINCOLI SONO OK
			--QUINDI PER QUELLI CHE SONO PRESENTI NELLA TEMP SIGNIFICA CHE NON RISPETTANO IL VINCOLO ESAMINATO
			--if exists( select * from #TEMP_WORK_TABLE_ID )		
			--begin
			--end

			set @statement = @statement + '

				update DM set EsitoRiga = isnull(EsitoRiga,'''') + ''<br>Vincolo "''''' + replace(@DescrizioneVincolo,'''','''''')  + '''''" non rispettato.<img src="../images/Domain/info.png" alt = "Il Vincolo richiesto è: ''''' + dbo.HTML_Encode(@EspressioneOrig) + '''''" title="Il Vincolo richiesto è: ''''' + dbo.HTML_Encode(@EspressioneOrig) + '''''" />''
					from Document_MicroLotti_Dettagli DM with(nolock) 
						inner join 	#TEMP_WORK_TABLE_ID T on DM.id=T.id			
				where dm.tipodoc in ( ''OFFERTA_AMPIEZZA'' , ''OFFERTA_AMPIEZZA_DI_GAMMA'' )
				
				and DM.idheader=' + cast(@iddoc as varchar(100)) + '

				drop table #TEMP_WORK_TABLE_ID			
			
				'
			
			--print @statement
			exec ( @statement)

			FETCH NEXT FROM crsVincoli INTO  @Espressione, @DescrizioneVincolo, @EspressioneOrig

		END

		CLOSE crsVincoli 
		DEALLOCATE crsVincoli 	
	END


END



GO
