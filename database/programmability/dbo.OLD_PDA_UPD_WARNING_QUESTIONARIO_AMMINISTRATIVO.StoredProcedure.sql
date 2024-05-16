USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PDA_UPD_WARNING_QUESTIONARIO_AMMINISTRATIVO]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE proc [dbo].[OLD_PDA_UPD_WARNING_QUESTIONARIO_AMMINISTRATIVO]( @idPda as int, @IdOff as int )
as
begin

	declare @idrow int
	declare @IdGara as int
	declare @PresenzaQuestionario as varchar(10)
	declare @IdQuest as int
	declare @IdModuloQuest as int
	declare @Descrizione as nvarchar(500)
	declare @Valori as nvarchar(max)
	declare @ValoriEsclusione as nvarchar(max)
	declare @ValoriWarning as nvarchar(max)
	declare @IDFornitore as int
	declare @DescrizioneWarning as nvarchar(max)
	declare @ModuloQuestionario_SezioniCondizionate as nvarchar(max)
	declare @Attrib as nvarchar(1000)

	set @PresenzaQuestionario='no'

	--recupero id gara 
	select @IdGara=LinkedDoc from ctl_doc with (nolock) where id = @IdOff

	--recupero idrow offerta sulla document_pda_offerte
	select @idrow = idrow , @IDFornitore=idAziPartecipante  from document_pda_offerte with (nolock) where idmsg=@IdOff

	--recupero presenza questionario amministrativo
	select @PresenzaQuestionario = isnull(value,'') from ctl_doc_Value with (nolock) 
		where idheader =@IdGara and dse_id='QUESTIONARIO' and dzt_name='PresenzaQuestionario'
	

	--recupero il MODULO_QUESTIONARIO_AMMINISTRATIVO COMPILATO ED ALLEGATO FIRMATO LEGATO ALL'OFFERTA
	set @IdModuloQuest=-1
	select @IdModuloQuest = id from ctl_doc with (nolock) 
		where tipodoc='MODULO_QUESTIONARIO_AMMINISTRATIVO' and linkeddoc = @IdOff and isnull(SIGN_ATTACH , '')<>''



  
	if @PresenzaQuestionario='si' and @IdModuloQuest <> -1
	begin
		
		--recupero il questionario amministrativo legato alla gara 
		select @IdQuest=id 
			from ctl_doc with (nolock) 
			where tipodoc='QUESTIONARIO_AMMINISTRATIVO' 
				AND LINKEDDOC = @IdGara
				AND isnull(jumpcheck,'')=''

		 --recupero le sezioni condizionate 
		select  
			@ModuloQuestionario_SezioniCondizionate=isnull(value,'')
			from 
				CTL_DOC_Value with (nolock)
			
			where IdHeader =@IdModuloQuest and DSE_ID='MODULO' and DZT_Name ='ModuloQuestionario_SezioniCondizionate'

		
		--metto in una temp le sez condizionate con parametro e valorecondizione
		--select 
		--	dbo.GetPos( dbo.GetPos(items,'###',1) , ':' ,1) as Attrib,
		--	dbo.GetPos(dbo.GetPos(items,'###',1), ':' ,2) as Valore, 
		--	dbo.GetPos(items,'###',2) as Sezione,
		--	--alla colonna succ gli do 200 blank altrimeni dopo mi da string truncated
		--	--quando vado a valorizzarla
		--	'                                                                                                                                                                                                                             ' as ValoreSulDocumento
		--	into #SezioniCondizionate
	
		--	from 
		--		--dbo.Split('PARAMETRO_1_1:giallo ###3,PARAMETRO_2_1:napoli###5',',')
		--		dbo.Split(@ModuloQuestionario_SezioniCondizionate,',')
		
		select 
			dbo.GetPos(items ,':' ,1) as Attrib,
			dbo.GetPos(items ,':' ,2) as Valori

			into #ParametriSezioniCondizionate
	
		from 
			dbo.Split(@ModuloQuestionario_SezioniCondizionate,',')
		
		--variabile table @SezioniCondizionate
		declare @SezioniCondizionate Table
		 (
		 Attrib varchar(500),
		 Sezione varchar(10),
		 Valore nvarchar(max),
		 ValoreSulDocumento nvarchar(max)
		 )


		 --faccio un cursore per recuperare i valori e le sezioni condizionate per ogni parametro
		DECLARE crsParam CURSOR STATIC FOR 
	
			select Attrib, Valori from #ParametriSezioniCondizionate 

		OPEN crsParam

		FETCH NEXT FROM crsParam INTO @Attrib, @Valori
		WHILE @@FETCH_STATUS = 0
		BEGIN
	

			--popolo la tabella @SezioniCondizionate
			insert into @SezioniCondizionate
			( Attrib, Sezione ,Valore)
	
			select 
				@Attrib , 
				dbo.getpos(items,'###',2) as Sezione, 
				dbo.getpos(items,'###',1) as Valore
				from 
					dbo.split (@Valori, '@@@')
		

			FETCH NEXT FROM crsParam INTO @Attrib, @Valori
		END

		CLOSE crsParam 
		DEALLOCATE crsParam 



		--aggiorno sulla temp il valore dell'attributo presente sul modulo questionario
		update 
			S
			set ValoreSulDocumento = dbo.getpos(isnull(value,''),'@',2)
			--select Attrib, value
			from 
				@SezioniCondizionate S
				inner join CTL_DOC_Value  on Attrib=DZT_Name 
			where IdHeader=@IdModuloQuest and DSE_ID='MODULO'


		--recupero i parametri del questionario SOLO DELLE SEZIONI VISIBILI che ammettono esclusioni e li metto in una temp
		select 
			S.ChiaveUnivocaRiga,
			A.keyriga, 'PARAMETRO_' + replace(A.keyriga,'.','_') as Parametro, 
			A.Descrizione, isnull(A.valori_di_esclusione_parametro,'')  as ValoriEsclusione	
							
				into #TempParametri_Esclusione
				
			from 
				Document_Questionario_Amministrativo A with (nolock) 
					inner join Document_Questionario_Amministrativo S with (nolock) on dbo.getPos(A.KeyRiga,'.',1) =dbo.getPos(S.KeyRiga,'.',1)
													and S.TipoRigaQuestionario ='sezione' and A.idHeader = S.idHeader 
					where 
						A.idheader= @IdQuest
						and isnull(A.valori_di_esclusione_parametro,'') <>''
						and 
						( 
							--la sezione del paraemtro è tra quelle condizionate visibili
							S.ChiaveUnivocaRiga in ( select Sezione from @SezioniCondizionate where CHARINDEX ( '###'+Valore+'###' , '###'+isnull(ValoreSulDocumento,'')+'###') >0 )
							or
							S.ChiaveUnivocaRiga not in ( select Sezione from @SezioniCondizionate)
						)
		
		--per tutti i parametri che possono causare warning controllo se il fornitore sul modulo questionario 
		--ha insertito dei valori che causano warning
		--drop table #TempParametri_Esclusione
		--select * from #TempParametri_Esclusione


		--cancello i warning memorizzati se ci sono
		delete Document_Pda_Offerte_Anomalie where IdHeader= @idPda and IdRowOfferta = @idrow and IdFornitore = @IDFornitore and TipoAnomalia ='MODULO_QUESTIONARIO_AMMINISTRATIVO'

		DECLARE crsParam CURSOR STATIC FOR 
			
			select 
				Descrizione , replace( Value , cast(@IdQuest as varchar(50)) + '_' + keyriga + '@','') as Valori , ValoriEsclusione 
				--,*
				from ctl_doc_value with (nolock) 
						inner join #TempParametri_Esclusione on DZT_NAME=Parametro
					where idheader=@IdModuloQuest and isnull(value,'')<>''
			

		OPEN crsParam

		FETCH NEXT FROM crsParam INTO @Descrizione, @Valori, @ValoriEsclusione
		WHILE @@FETCH_STATUS = 0
		BEGIN
				
				set @ValoriWarning=''
				--se tra i @Valori inseriti sul documento è presente uno di quelli presenti nei @ValoriEsclusione allora
				--segnalo il warning
				
				select
					@ValoriWarning = @ValoriWarning + '''' + V.items  + ''','
					from 
						dbo.split(@Valori,'###') V
							inner join
									(select items from dbo.split(@ValoriEsclusione,'###') where items <> '' ) E on E.items = V.items
					where 
						V.items <> ''
	
				
				if @ValoriWarning <> ''
				begin
					set @ValoriWarning = substring(@ValoriWarning,1,len(@ValoriWarning)-1)

					if charindex(''',''',@ValoriWarning) = 0
						
						set @DescrizioneWarning = 'Il fornitore ha selezionato il valore ' + @ValoriWarning + ' per il parametro ''' + @Descrizione + ''' che è motivo di esclusione'
						
					else
						set @DescrizioneWarning = 'Il fornitore ha selezionato i valori ' + @ValoriWarning + ' per il parametro ''' + @Descrizione + ''' che è motivo di esclusione'
					
					insert into  Document_Pda_Offerte_Anomalie 
						 ( [IdHeader], [IdRowOfferta], [IdDocOff], [IdFornitore], [Descrizione], [Data], [TipoAnomalia] ) 
						values
						( @idPda, @idrow, @IdOff, @IDFornitore, @DescrizioneWarning, getdate(), 'MODULO_QUESTIONARIO_AMMINISTRATIVO' ) 
				end

		FETCH NEXT FROM crsParam INTO @Descrizione, @Valori, @ValoriEsclusione
		END

		CLOSE crsParam 
		DEALLOCATE crsParam 

		

		
		--select top 1 * from Document_Pda_Offerte_Anomalie 
		
		--drop table #SezioniCondizionate
		drop table #TempParametri_Esclusione
		drop table #ParametriSezioniCondizionate

	end

end
GO
