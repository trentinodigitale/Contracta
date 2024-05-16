USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_VERIFICAVINCOLI_GARE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE  PROCEDURE [dbo].[CK_VERIFICAVINCOLI_GARE]  (  @Iddoc int)
AS
BEGIN 
	
	

	SET NOCOUNT ON
	declare @idBando			int
	declare @TipoDoc			varchar(200)
	declare @LinkedDoc			int
	declare @Colonna			varchar(200)
	declare @idDocModello		int
	declare @Espressione        nvarchar(2000)
	declare @EspressioneOrig    nvarchar(2000)	
	declare @DztNameAttrib      varchar(500)
	declare @DztDescAttrib      varchar(500)
	declare @DescrizioneVincolo	nvarchar(1000)
	declare @statement          nvarchar(MAX)	
	declare @lottovoce as varchar(100)
	declare @Divisione_Lotti varchar(20)
	declare @AttribForExpr as varchar(500)
	declare @Type int	


	--declare @Iddoc int
	--set @Iddoc = 83456

	set @AttribForExpr=''

	select @TipoDoc = TipoDoc , @LinkedDoc = LinkedDoc from CTL_DOC with(nolock) where id = @iddoc

	
	if @Tipodoc in ( 'BANDO_SEMPLIFICATO' , 'BANDO_GARA' , 'BANDO_ASTA' )
	begin
		set @Colonna = 'MOD_BandoSempl'
		set @idBando = @idDoc	
	end
	else if @Tipodoc in ( 'OFFERTA' ,'OFFERTA_ASTA' )
	begin
		set @Colonna = 'MOD_OffertaInput'
		set @idBando = @LinkedDoc
	end


	select @Divisione_Lotti = Divisione_Lotti from document_bando  with(nolock) where idheader = @idBando


	-- se una gara è senza lotti ma è presente la voce zero allora concettualmente diventa una gara a lotti con voci
	if @divisione_lotti = '0' and exists( select * from ctl_doc_value  with(nolock) where idheader = @idBando and DSE_ID = 'TESTATA_PRODOTTI' and DZT_Name = 'RigaZero' and Value = '1' )
	begin
		declare @NR int
		select @NR = count( * ) from Document_MicroLotti_Dettagli  with(nolock) where idheader = @iddoc and tipodoc = @TipoDoc

		-- le gare senza lotti che presentano una sola riga si considerano come quelle a lotti senza voci
		if isnull( @NR , 0 ) = 1 
			set @divisione_lotti = '2'
		else
			set @divisione_lotti = '1'

	end

	--print @divisione_lotti
	--return 

	select @idDocModello = id from ctl_doc  with(nolock) where tipodoc = 'CONFIG_MODELLI_LOTTI' and deleted = 0 and linkeddoc = @idBando


	--SE SUL MODELLO ESISTONO I VINCOLI PROCEDO A FARE I CONTROLLI
	IF EXISTS (select idheader from Document_Vincoli  with(nolock) where IdHeader=@idDocModello and contesto_vincoli like '%'+ @Colonna + '%')
	BEGIN
		--recupero i vincoli inclusi sul modello
		DECLARE crsVincoli CURSOR STATIC FOR 
		select Espressione,Descrizione,Espressione as EspressioneOrig from Document_Vincoli  with(nolock) where idheader=@idDocModello and contesto_vincoli like '%'+ @Colonna + '%'

		OPEN crsVincoli
		FETCH NEXT FROM crsVincoli INTO @Espressione,@DescrizioneVincolo,@EspressioneOrig
		WHILE @@FETCH_STATUS = 0

		BEGIN

			--print 'espressione origine=' + @Espressione
			set @AttribForExpr = ''	

			--se nell'espressione è presente la parola isMultiplo ci metto dbo d'avanti
			set @Espressione = REPLACE(@Espressione, 'isMultiplo(', 'dbo.isMultiplo(')

			--rimpiazzo gli operatori e le parentesi per assicurarci gli spazi davanti gli attributi
			set @Espressione = replace(@Espressione,'(', ' ( ')
			set @Espressione = replace(@Espressione,')', ' ) ')
			set @Espressione = replace(@Espressione,'+', ' + ')
			set @Espressione = replace(@Espressione,'-', ' - ')
			set @Espressione = replace(@Espressione,'*', ' * ')
			set @Espressione = replace(@Espressione,'/', ' / ')

			--Sostituisce i nomi delle colonne della microlotti dettagli alla nostra espressione
			DECLARE crsAttrib CURSOR STATIC FOR 
				
			select CV.value as DztDescAttrib , CV2.Value as DztNameAttrib , d.DZT_Type
				from ctl_doc_value CV with(nolock)
					inner join ctl_doc_value CV2 with(nolock) on CV2.IdHeader=CV.IdHeader and CV.DSE_ID=CV2.DSE_ID and CV2.DZT_Name='DZT_Name' and CV2.Row=CV.Row
					left join LIB_Dictionary d with(nolock) on d.DZT_Name = cv2.value
					where CV.idheader=@idDocModello and CV.dzt_name='Descrizione' and CV.DSE_ID='MODELLI'
				
			OPEN crsAttrib

			FETCH NEXT FROM crsAttrib INTO @DztDescAttrib,@DztNameAttrib , @Type
			WHILE @@FETCH_STATUS = 0
			BEGIN
				
				--print @DztNameAttrib
				
				--conservo il nome di un attributo presente nel vincolo per recuperare le caratteristiche lotto/lottovoce/ecc...
				if @AttribForExpr = '' and CHARINDEX ('[' + @DztDescAttrib + ']' , @Espressione) > 0 
					set @AttribForExpr = @DztNameAttrib
				
				if @Type = 2
					set @Espressione = replace(@Espressione,'[' + @DztDescAttrib + ']' , ' cast ( ' + @DztNameAttrib +' as float) ' )							
				else
				if @Type in ( 4,5,8, 18 )
					set @Espressione = replace(@Espressione,'[' + @DztDescAttrib + ']' , ' dbo.GetDescsValuesFromDztDomExt( ''' + @DztNameAttrib +''' , ' + @DztNameAttrib +' , ''I'' ) ' )							
				else
					set @Espressione = replace(@Espressione,'[' + @DztDescAttrib + ']' , ' ' + @DztNameAttrib +' ' )							

				
				FETCH NEXT FROM crsAttrib INTO @DztDescAttrib,@DztNameAttrib , @Type
			END
		
			CLOSE crsAttrib 
			DEALLOCATE crsAttrib 
			
			--print 'espressione risolta=' +  @Espressione
			--print 'attributo espressione=' + @AttribForExpr
				
			
			--recupero le caratteristiche (lotto/lottovoce/voce,ecc...) di un attributo dell'espressione
			--gli altri dovrebbero avere le stesse caratteristiche
			set @lottovoce=''
			select @lottovoce=value 
				from ctl_doc_value  with(nolock) 
			where row=(select row from ctl_doc_value where idheader=@IdDocModello and DSE_ID='MODELLI' and dzt_name='DZT_Name' and value=@AttribForExpr)
				and idheader=@idDocModello and DSE_ID='MODELLI' and DZT_Name='LottoVoce'
			
			--print 'lottovoce=' + @lottovoce

			--inserisco nella temp table tutti gli id del documento
			--che devono rispettare il vincolo a seconda del tipo di gara lotto/lotti singola voce/multivoce
			set @statement = ' select id into #TEMP_WORK_TABLE_ID from document_microlotti_dettagli  with(nolock)  where idheader=' + cast(@iddoc as varchar(500))  + ' and TipoDoc = ''' + CAST(@TipoDoc  as varchar(500))   + ''''
			
			if @Divisione_Lotti = '0' 
			begin
					
				if (   @lottovoce = 'Lotto' )
				begin
					set @statement = @statement + ' and numeroriga = 0 ' 
				end

				if (   @lottovoce = 'LottoVoce' )
				begin
					set @statement = @statement + ' and numeroriga >= 0 ' 
				end

				if (   @lottovoce = 'Voce' )
				begin
					set @statement = @statement + ' and numeroriga > 0 ' 
				end

				
			end
			
			if ( @Divisione_Lotti = '1'   )
			begin

				if    @lottovoce = 'Lotto'
				begin
					set @statement = @statement + ' and voce = 0 ' 
				end

				if    @lottovoce = 'LottoVoce'
				begin
					set @statement = @statement + ' and voce >= 0 ' 
				end

				if    @lottovoce = 'Voce'
				begin
					set @statement = @statement + ' and voce <> 0 ' 
				end

			end
			
			--print @statement
			--exec (@statement)
				
			--RIMUOVO QUELLI CHE RISPETTANO IL VINCOLO
			set @statement = @statement + '

				delete from  #TEMP_WORK_TABLE_ID  where id in (select id from document_microlotti_dettagli with(nolock) where idheader=' + cast(@iddoc as varchar(500)) + ' and TipoDoc = ''' +  @TipoDoc  + ''' and ' +	@Espressione + ')'
			
			--print @statement
			--exec (@statement)

			--SE CI SONO RECORD SIGNIFICA CHE NON TUTTI I VINCOLI SONO OK
			--QUINDI PER QUELLI CHE SONO PRESENTI NELLA TEMP SIGNIFICA CHE NON RISPETTANO IL VINCOLO ESAMINATO
			--if exists( select * from #TEMP_WORK_TABLE_ID )		
			--begin
			--end

			set @statement = @statement + '

				update DM set EsitoRiga = isnull(EsitoRiga,'''') + ''<br>Vincolo "''''' + replace(@DescrizioneVincolo,'''','''''')  + '''''" non rispettato.<img src="../images/Domain/info.png" alt = "Il Vincolo richiesto è: ''''' + dbo.HTML_Encode(@EspressioneOrig) + '''''" title="Il Vincolo richiesto è: ''''' + dbo.HTML_Encode(@EspressioneOrig) + '''''" />''
					from Document_MicroLotti_Dettagli DM with(nolock) 
						inner join 	#TEMP_WORK_TABLE_ID T on DM.id=T.id			
				where DM.idheader=' + cast(@iddoc as varchar(100)) + ' and DM.TipoDoc = ''' +  @TipoDoc  + '''

				drop table #TEMP_WORK_TABLE_ID			
			
				'
			
			--print @statement
			exec ( @statement)

			FETCH NEXT FROM crsVincoli INTO @Espressione,@DescrizioneVincolo,@EspressioneOrig

		END

		CLOSE crsVincoli 
		DEALLOCATE crsVincoli 	
	END


END



GO
