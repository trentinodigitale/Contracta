USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SEDUTA_SDA_CREATE_FROM_BANDO_ISCRIZ_ALBO]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[SEDUTA_SDA_CREATE_FROM_BANDO_ISCRIZ_ALBO] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @ProtocolloRiferimento as varchar(40)
	declare @Errore as nvarchar(2000)

	declare @info as nvarchar(2000)
	declare @num_massimo_doc as int
	declare @num_tot_doc as int
	declare @numero_doc_inseriti as int
	declare @id_com INT
	declare @numero_doc_prog as int
	declare @jumpcheck varchar(500)
	

	set @Errore = ''
	set @info = ''
	
	
	select @jumpcheck = isnull( jumpcheck , '' ) from ctl_doc with(nolock) where id = @idDoc --BANDO_ALBO_LAVORI

	select @num_massimo_doc = N_DocInSeduta from Document_Parametri_Abilitazioni with(nolock) where [deleted] = 0 and (  ( @jumpcheck = 'BANDO_ALBO_LAVORI' and  [TipoDoc] = 'ALBO_LAVORI' ) or (  @jumpcheck = '' and  [TipoDoc] =  'ALBO' ))
	if isnull( @num_massimo_doc , 0 ) <= 0 
		select @num_massimo_doc=DZT_ValueDef  from LIB_Dictionary with(nolock) where dzt_name='SYS_NUMERO_DOCUMENTI_SEDUTA_SDA'

	select  @num_tot_doc=count(*)
			from CTL_DOC i with(nolock)
				inner join CTL_DOC d  with(nolock) on d.linkedDoc =  i.id
							and d.TipoDoc in ( 'SCARTO_ISCRIZIONE' ,'INTEGRA_ISCRIZIONE' , 'CONFERMA_ISCRIZIONE' ,'SCARTO_ISCRIZIONE_LAVORI','CONFERMA_ISCRIZIONE_LAVORI' ) 
							and d.StatoFunzionale = 'Valutato' --'InLavorazione'
							and d.deleted = 0
			where i.linkedDoc = @idDoc and i.TipoDoc like 'ISTANZA_ALBO%'


	-- cerco una versione precedente del documento 
	set @id = null
	select @id = id from CTL_DOC with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'SEDUTA_SDA' ) and statofunzionale = 'InLavorazione'

	--preparo il cursore con tutte le comunicazioni pronte per essere inserite nella seduta, vengono esclusi documenti già presenti in doc di seduta presenti
	declare CurProg Cursor Static for 
		select d.id as id_com 
			from CTL_DOC i with(nolock)
				inner join CTL_DOC d with(nolock) on d.linkedDoc =  i.id
							and d.TipoDoc in ( 'SCARTO_ISCRIZIONE' ,'INTEGRA_ISCRIZIONE' , 'CONFERMA_ISCRIZIONE', 'SCARTO_ISCRIZIONE_LAVORI','CONFERMA_ISCRIZIONE_LAVORI' ) 
							and d.StatoFunzionale = 'Valutato' --'InLavorazione'
							and d.deleted = 0
				where i.linkedDoc = @idDoc and i.TipoDoc like 'ISTANZA_ALBO%'
				and d.id not in ( select i.Value from CTL_DOC d with(nolock)
									inner join CTL_DOC_Value i with(nolock) on i.IdHeader = d.id and i.DSE_ID = 'COMUNICAZIONI' 
									where d.TipoDoc = 'SEDUTA_SDA' and d.LinkedDoc = @idDoc and d.Deleted=0
								 )
		order by d.id


	if @id is not null
	begin
			
		-- aggiungo eventuali comunicazioni di conferma/scarto mancanti se non ho raggiunto il numero massimo di documenti 
		select @numero_doc_inseriti=count(*) from CTL_DOC_Value with(nolock) where DSE_ID = 'COMUNICAZIONI' and idheader=@id

		if @numero_doc_inseriti < @num_massimo_doc
		BEGIN
			set @numero_doc_prog=@numero_doc_inseriti
			open CurProg  FETCH NEXT FROM CurProg 
				INTO @id_com
				WHILE @@FETCH_STATUS = 0
				BEGIN
					insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
	             		select @id,'COMUNICAZIONI',-1,'idDoc',@id_com
						set @numero_doc_prog=@numero_doc_prog+1
					if @numero_doc_prog = @num_massimo_doc
						break;				 
					FETCH NEXT FROM CurProg INTO @id_com
				END 

			CLOSE CurProg
			DEALLOCATE CurProg
		END	
		--nel caso per quella seduta sono state già inseriti più doc del consentito li rimuovo tutti e poi li rimetto
		if @numero_doc_inseriti > @num_massimo_doc
		BEGIN	
			delete from ctl_doc_value where DSE_ID='COMUNICAZIONI' and IdHeader=@id
			set @numero_doc_prog=0
			
			if @numero_doc_prog < @num_massimo_doc
			BEGIN				
				open CurProg  FETCH NEXT FROM CurProg 
					INTO @id_com
					WHILE @@FETCH_STATUS = 0
					BEGIN
						insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
	             			select @id,'COMUNICAZIONI',-1,'idDoc',@id_com
							set @numero_doc_prog=@numero_doc_prog+1
						if @numero_doc_prog = @num_massimo_doc
							break;				 
						FETCH NEXT FROM CurProg INTO @id_com
					END 

				CLOSE CurProg
				DEALLOCATE CurProg
			END
			
		END
			
			
			--insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
			--select @id as IdHeader, 'COMUNICAZIONI' as DSE_ID, -1 as Row, 'idDoc' as DZT_Name, d.id as Value 
			--	from CTL_DOC i
			--		inner join CTL_DOC d on d.linkedDoc =  i.id
			--								and d.TipoDoc in ( 'SCARTO_ISCRIZIONE' ,'INTEGRA_ISCRIZIONE' , 'CONFERMA_ISCRIZIONE' ) 
			--								and d.StatoFunzionale = 'Valutato' --'InLavorazione'
			--								and d.deleted = 0
						
			--	where i.linkedDoc =  @idDoc and i.TipoDoc like 'ISTANZA_ALBO%'
			--		and d.id not in ( select i.Value from CTL_DOC d 
			--								inner join CTL_DOC_Value i on i.IdHeader = d.id and i.DSE_ID = 'COMUNICAZIONI' 
			--							where d.TipoDoc = 'SEDUTA_SDA' and d.LinkedDoc = @idDoc )
		
	end
	else
	begin

		-------------------------------------------------------------------------------------
		--- CONTROLLO PREVENTIVO SULLA PRESENZA DI COMUNICAZIONI DA COLLEGARE ALLA SEDUTA ---
		-------------------------------------------------------------------------------------
		IF EXISTS ( 
					select @id as IdHeader, 'COMUNICAZIONI' as DSE_ID, -1 as  Row, 'idDoc' as DZT_Name, d.id as Value 
					from CTL_DOC i with(nolock) 
						inner join CTL_DOC d with(nolock) on d.linkedDoc =  i.id
												and d.TipoDoc in ( 'SCARTO_ISCRIZIONE' ,'INTEGRA_ISCRIZIONE' , 'CONFERMA_ISCRIZIONE' ,'SCARTO_ISCRIZIONE_LAVORI','CONFERMA_ISCRIZIONE_LAVORI' ) 
												and d.StatoFunzionale = 'Valutato' --'InLavorazione'
												and d.deleted = 0
					where i.linkedDoc =  @idDoc and i.TipoDoc like 'ISTANZA_ALBO%'
				  )

		BEGIN

			-- calcolo il numero della seduta
			declare @NumeroSeduta int
			set @NumeroSeduta = null
			select @NumeroSeduta  = Value
				from CTL_DOC_Value 
					where idheader = (
							select max( id  ) as id
									from CTL_DOC  with(nolock) 
									where LinkedDoc = @idDoc 
										and deleted = 0 and TipoDoc in ( 'SEDUTA_SDA' ) 
						)
						and DSE_ID = 'DATE'
						and DZT_Name = 'NumeroSeduta'

			set @NumeroSeduta = isnull( @NumeroSeduta  , 0 ) + 1

			declare @Titolo nvarchar(1000)
			declare @TitoloBando nvarchar(1000)
			
			select @Titolo = cast( @NumeroSeduta as varchar(10)) +
				    case isnull(jumpcheck,'')
					    when '' then ' Seduta Mercato Elettronico' 
					    when ' BANDO_ALBO_LAVORI' then 'Riepilogo Seduta Bando Iscrizione Albo Lavori'
					    else ' Seduta Bando'
				    end 
				    ,@TitoloBando = Titolo
				from CTL_DOC with(nolock)  where id = @idDoc

			 -- se esistono altri bandi della stessa tipologia concateniamo anche il titolo alla descrizione
			 if exists( select id from CTL_DOC with(nolock) where deleted = 0 and tipodoc = 'BANDO' and isnull( JumpCheck , '' ) = @jumpcheck and StatoFunzionale <> 'InLavorazione' )
			 begin

				set @Titolo = @Titolo + ' - [' + @TitoloBando + ']'

			 end

			 set @Titolo = left( @Titolo  , 500 ) 

			-- altrimenti lo creo
			INSERT into CTL_DOC (
				IdPfu,  TipoDoc, 
				Titolo, Body, Azienda, StrutturaAziendale, 
				ProtocolloRiferimento, Fascicolo, LinkedDoc )
			    select 
				    @IdUser as idpfu , 'SEDUTA_SDA' as TipoDoc ,  
				
				    --case isnull(jumpcheck,'')
					   -- when '' then 'Seduta Bando Me' 
					   -- when 'BANDO_ALBO_LAVORI' then 'Riepilogo Seduta Bando Iscrizione Albo Lavori'
					   -- else 'Seduta Bando'
				    --end as Titolo
				
				    --, '' Body, 
				    @Titolo as Titolo , @Titolo as Body , 

				    Azienda, StrutturaAziendale, 
				    Protocollo, Fascicolo, id as LinkedDoc 
			    from CTL_DOC with(nolock)
			    where id = @idDoc



			set @id = SCOPE_IDENTITY()


			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values( @id , 'DATE' , 0, 'NumeroSeduta', @NumeroSeduta ) 

			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values( @id , 'DATE' , 0, 'DataInizio', convert( varchar(19) , getdate() , 126 ) ) 

			-- collego al documento tutte le comunicazioni che sono in uno stato in lavorazione
			set @numero_doc_prog=0
			if @numero_doc_prog < @num_massimo_doc
			BEGIN				
				open CurProg  FETCH NEXT FROM CurProg 
					INTO @id_com
					WHILE @@FETCH_STATUS = 0
					BEGIN
						insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
	             			select @id,'COMUNICAZIONI',-1,'idDoc',@id_com
							set @numero_doc_prog=@numero_doc_prog+1
						if @numero_doc_prog = @num_massimo_doc
							break;				 
						FETCH NEXT FROM CurProg INTO @id_com
					END 

				CLOSE CurProg
				DEALLOCATE CurProg
			END


			--insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
			--	select @id as IdHeader, 'COMUNICAZIONI' as DSE_ID, -1 as  Row, 'idDoc' as DZT_Name, d.id as Value 
			--	from CTL_DOC i
			--		inner join CTL_DOC d on d.linkedDoc =  i.id
			--								and d.TipoDoc in ( 'SCARTO_ISCRIZIONE' ,'INTEGRA_ISCRIZIONE' , 'CONFERMA_ISCRIZIONE' ) 
			--								and d.StatoFunzionale = 'Valutato' --'InLavorazione'
			--								and d.deleted = 0
			--	where i.linkedDoc =  @idDoc and i.TipoDoc like 'ISTANZA_ALBO%'

			--aggiungo il riferimento nella tabella Document_PDA_Sedute
			insert into Document_PDA_Sedute (idHeader,NumeroSeduta,idSeduta) VALUES
			(@idDoc,@NumeroSeduta,@id)	
			--aggiungo l'elenco dei verbali
				insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					select @id as IdHeader,'VERBALE',-1 as Row,'Titolo',Titolo as Value from CTL_DOC  with(nolock)
						inner join dbo.Document_VerbaleGara with(nolock)  on idheader = id and TipoSorgente = 3
					where tipodoc = 'VERBALETEMPLATE'
					order by id desc
					
				insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					select @id as IdHeader,'VERBALE',-1 as Row,'guid',GUID as Value from CTL_DOC  with(nolock)
						inner join dbo.Document_VerbaleGara with(nolock) on idheader = id and TipoSorgente = 3
					where tipodoc = 'VERBALETEMPLATE'
					order by id desc

		END
		ELSE
		BEGIN
			set @info = 'Non sono attualmente presenti documenti per la creazione della Seduta'
		END
	
	end
	
	if exists( select IdHeader from CTL_DOC_Value with(nolock) where idheader = @id and Row = -1 and  DSE_ID = 'COMUNICAZIONI' )
	begin

		--aggiorno il numero riga sulle comunicazioni
		declare @idRow INT
		declare @Row INT
		set @Row = 0

		declare CurProg Cursor static for 
		Select IdRow from CTL_DOC_Value 	with(nolock)
			where idheader = @id and DSE_ID = 'COMUNICAZIONI' 
			order by IdRow

		open CurProg

		FETCH NEXT FROM CurProg 
		INTO @idrow
		WHILE @@FETCH_STATUS = 0
			BEGIN
			   update  CTL_DOC_Value set Row = @Row where IdRow=@IdRow
			   set @Row = @Row + 1  

			 FETCH NEXT FROM CurProg 
			 INTO @idrow
		END 
		CLOSE CurProg
		DEALLOCATE CurProg

	end
	
	if exists( select IdHeader from CTL_DOC_Value with(nolock) where idheader = @id and Row = -1 and  DSE_ID = 'VERBALE' and dzt_name='titolo')
	begin

		--aggiorno il numero riga sulle comunicazioni
		
		set @Row = 0

		declare CurProg Cursor static for 
		Select IdRow from CTL_DOC_Value  with(nolock)	
			where idheader = @id and DSE_ID = 'VERBALE' and dzt_name='titolo'
			order by IdRow

		open CurProg

		FETCH NEXT FROM CurProg 
		INTO @idrow
		WHILE @@FETCH_STATUS = 0
			BEGIN
			   update  CTL_DOC_Value set Row = @Row where IdRow=@IdRow
			   set @Row = @Row + 1  

			 FETCH NEXT FROM CurProg 
			 INTO @idrow
		END 
		CLOSE CurProg
		DEALLOCATE CurProg

	end
	
	if exists( select IdHeader from CTL_DOC_Value with(nolock) where idheader = @id and Row = -1 and  DSE_ID = 'VERBALE' and dzt_name='guid')
	begin

		--aggiorno il numero riga sulle comunicazioni
		
		set @Row = 0

		declare CurProg Cursor static for 
		Select IdRow from CTL_DOC_Value with(nolock)	
			where idheader = @id and DSE_ID = 'VERBALE' and dzt_name='guid'
			order by IdRow

		open CurProg

		FETCH NEXT FROM CurProg 
		INTO @idrow
		WHILE @@FETCH_STATUS = 0
			BEGIN
			   update  CTL_DOC_Value set Row = @Row where IdRow=@IdRow
			   set @Row = @Row + 1  

			 FETCH NEXT FROM CurProg 
			 INTO @idrow
		END 
		CLOSE CurProg
		DEALLOCATE CurProg

	end

	--aggiorno il residuo di documenti da processare che restano
	delete from CTL_DOC_Value where DSE_ID='DATE' and DZT_Name='Numero_Documenti_da_elaborare'
	IF ( @num_tot_doc > ( Select count(*) from ctl_doc_value  with(nolock) where DSE_ID='COMUNICAZIONI' and idheader=@id ) )
	BEGIN		
		insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values( @id , 'DATE' , 0, 'Numero_Documenti_da_elaborare',  @num_tot_doc - (Select count(*) from ctl_doc_value where DSE_ID='COMUNICAZIONI' and idheader=@id) ) 
	END
	ELSE
	BEGIN
		insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values( @id , 'DATE' , 0, 'Numero_Documenti_da_elaborare',  0 ) 
	END
	if @Errore = ''
	begin
		
		IF @info = ''
		BEGIN

			-- rirorna l'id della nuova comunicazione appena creata
			select @Id as id

		END
		ELSE
		BEGIN
			
			select 'INFO' as id, @info as Errore

		END
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end

END













GO
