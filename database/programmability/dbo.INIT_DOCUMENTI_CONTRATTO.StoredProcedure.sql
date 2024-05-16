USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[INIT_DOCUMENTI_CONTRATTO]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE proc [dbo].[INIT_DOCUMENTI_CONTRATTO] ( @IdDoc as int, @IdUser as int )
as
begin
    
   --popolo la riga per gli atti 
	declare @InfoAtto as nvarchar(max)
	declare @AnagDoc as varchar (200)
	declare @NotEditable as varchar(300)
	declare @Descrizione as nvarchar(max)
	declare @Obblig as varchar(300)
	declare @TipoFile as varchar(300)
	declare @FirmeRichieste as varchar(300)
	declare @ProceduraGara as varchar(20)
	declare @TipoBandoGara as varchar (20)
	declare @TipoProceduraCaratteristica as varchar(100)
	
	--recupero le caratterisitche della gara 
	--select 
	--	@ProceduraGara=ProceduraGara, @TipoBandoGara= TipoBandoGara,@TipoProceduraCaratteristica=TipoProceduraCaratteristica  
	--	from document_bando with (nolock) where idheader = @IdDoc

	
	--popolo le righe per busta documentazione
	select REL_ValueOutput 
		into #lista_doc 
			from CTL_Relations with (nolock) 
		where  REL_Type = 'DEFAULT_CONTRATTO_GARA_DOCUMENTAZIONE' --and REL_ValueInput = @ProceduraGara + ',' + @TipoBandoGara + ',' + @TipoProceduraCaratteristica

	if exists (select * from #lista_doc)
	begin
				
		--cursore su #lista_doc
		DECLARE crsDoc CURSOR STATIC FOR 
					
			select * from #lista_doc 

		OPEN crsDoc

		FETCH NEXT FROM crsDoc INTO @InfoAtto
		WHILE @@FETCH_STATUS = 0
		BEGIN
					
			set @NotEditable= ''
			set @AnagDoc =''

			--in primaposizione 1 c'è anagdoc per la riga bloccata
			set @AnagDoc = dbo.getpos(@InfoAtto,'~~~',1)
					
			if @AnagDoc <> ''
			begin
				select 
					@Descrizione =  Descrizione, @NotEditable = NotEditable 
					from 
						BANDO_TipologiaAtti 
					where anagdoc=@AnagDoc
			end
			else
			begin
				
				--in 2 posizione c'è la descrizione per la riga libera
				set @Descrizione = dbo.getpos(@InfoAtto,'~~~',2)
				
				--in 6 posizione c'è la lista delle colonne non editaibili
				set @NotEditable = dbo.getpos(@InfoAtto,'~~~',6)
			end
			
			--in 3 posizione obblig
			set @Obblig = dbo.getpos(@InfoAtto,'~~~',3)
					
			--in 4 posizione eventuale filtro per attributo RichiesteFirme
			--che verrà memorizzato nella colonna TipoFile
			set @TipoFile = dbo.getpos(@InfoAtto,'~~~',4)

			--in 5 posizione il default per RichiesteFirme
			set @FirmeRichieste  = dbo.getpos(@InfoAtto,'~~~',5)

			--descrizione
			--allegato
			--anagdoc
			--notEditable
			--firmerichieste
			--obbligatorio
			

			insert into CTL_DOC_ALLEGATI 
				( [idHeader], [Descrizione],  [AnagDoc], [NotEditable], [EvidenzaPubblica], Obbligatorio, FirmeRichieste )
				select 
					@IdDoc as idheader , @Descrizione, @AnagDoc, @NotEditable , 0  , @Obblig , @FirmeRichieste
					


			FETCH NEXT FROM crsDoc INTO @InfoAtto
		END

		CLOSE crsDoc 
		DEALLOCATE crsDoc 

	end
	
end


GO
