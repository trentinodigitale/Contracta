USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_MODULO_TEMPLATE_REQUEST_COPY_CONTENT]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[OLD_MODULO_TEMPLATE_REQUEST_COPY_CONTENT]  ( @idDoc_From int ,@IdDoc_to int  , @IdUser int )
AS
BEGIN

	declare @Statofunzionale varchar(500) 
	declare @Azienda varchar(500) 
	declare @LinkedDoc int
	declare @AziendaFrom as int
	declare @AziendaDest as int
	declare @IdUserFrom as int 

	set @LinkedDoc = 0
	set @Azienda = 0
	set @AziendaFrom = 0

	select @LinkedDoc  = LinkedDoc  , @Azienda = azienda from CTL_DOC  with(nolock) where id = @IdDoc_to and StatoFunzionale = 'InLavorazione' and TipoDoc = 'MODULO_TEMPLATE_REQUEST' 
	
	--stato funzionale del documento a cui è collegato il DGUE destinazione
	select @Statofunzionale = Statofunzionale  from ctl_doc  with(nolock) where id = @LinkedDoc

	--azienda documento DGUE sorgente da cui devo copiare
	select @AziendaFrom=Azienda,@IdUserFrom=Idpfu from CTL_DOC  with(nolock) where Id=@idDoc_From

	--se azienda vale 0 allora recupero azienda del from dall'utente compilatore dl from
	if @AziendaFrom=0
		select @AziendaFrom = pfuidazi from ProfiliUtente with (nolock) where IdPfu = @IdUserFrom

	-- ricopio se il documento di destinazione è in lavorazione
	-- ricopio se il documento sorgente appartiene alla mia azienda

	if @Statofunzionale =  'InLavorazione' and exists ( select pfuidazi from profiliutente  with(nolock) where idpfu =  @IdUser and pfuidazi  = @AziendaFrom ) 
	begin

	
		-- preparo le tabelle di appoggio con l'elenco dei campi per il match
		select top 0 
				cast( '' as  varchar(500)) as MA_DZT_Name , 
				cast( '' as varchar(500)) as UUID  
			into #FieldFrom


		select top 0 
				cast( '' as  varchar(500)) as MA_DZT_Name , 
				cast( '' as varchar(500)) as UUID  
			into #FieldTo


		-- genero in una tabella temporanea tutti i dati del documento sorgente con uuid e valore considerando anche le iterazioni
		insert into #FieldFrom exec MODULO_REQUEST_GET_FIELD  @idDoc_From


		-- genero in una tabella temporanea tutti i riferimenti del documento di destinazione con uuid e considerando anche le iterazioni
		insert into #FieldTo exec MODULO_REQUEST_GET_FIELD  @IdDoc_to
		


		-- verifico se il documento di destinazione ha un numero di iterazioni differente dalla sorgente
		--  se no lo devo ricreare aggiungendo un numero di iterazioni esatte per ogni elemento iterabile
		if exists( 	
					select f.*
						from #FieldFrom F
							inner join #FieldTo T on f.UUID = t.UUID
							left outer join CTL_DOC_Value df with(nolock) on df.IdHeader = @idDoc_From and df.DZT_Name = f.MA_DZT_Name and df.DSE_ID = 'ITERAZIONI'
							left outer join CTL_DOC_Value dt with(nolock) on dt.IdHeader = @IdDoc_to and dt.DZT_Name = t.MA_DZT_Name and dt.DSE_ID = 'ITERAZIONI'
						where  f.UUID like 'ITERAZIONI-%' 
							and  -- il numero di occorrenze della sorgente è differente dalla destinazione
							isnull( cast( df.value as int ) , 1 )  <>  isnull( cast( dt.value  as int ) , 1 )
					)
		begin
			-- rettifico le iterazioni 
			delete from CTL_DOC_VALUE where idheader = @IdDoc_to and DSE_ID = 'ITERAZIONI'

			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				select @IdDoc_to , 'ITERAZIONI' , 0 , t.MA_DZT_Name , isnull( df.Value , '1' )
					from #FieldFrom F
						inner join #FieldTo T on f.UUID = t.UUID
						left outer join CTL_DOC_Value df with(nolock) on df.IdHeader = @idDoc_From and df.DZT_Name = f.MA_DZT_Name and df.DSE_ID = 'ITERAZIONI'
					where  f.UUID like 'ITERAZIONI-%' 

			-- ricreo il template
			exec MAKE_MODULO_TEMPLATE_REQUEST 	0 , '' , @IdDoc_to


			-- genero in una tabella temporanea tutti i dati del documento sorgente con uuid e valore considerando anche le iterazioni
			delete from #FieldFrom
			insert into #FieldFrom exec MODULO_REQUEST_GET_FIELD  @idDoc_From


			-- genero in una tabella temporanea tutti i riferimenti del documento di destinazione con uuid e considerando anche le iterazioni
			delete from #FieldTo
			insert into #FieldTo exec MODULO_REQUEST_GET_FIELD  @IdDoc_to
		
		end




		------------------------------------------------------------------------------------------------------------------------------
		--metto in join le due tabelle temporanee per uuid e numero iterazione sovrascrivendo i dati sulla destinazione
		------------------------------------------------------------------------------------------------------------------------------

		-- inserisco i record mancanti
		insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
			select @IdDoc_to , 'MODULO' , 0 , t.MA_DZT_Name , df.Value
				from #FieldFrom F
					inner join #FieldTo T on f.UUID = t.UUID
					inner join CTL_DOC_Value df with(nolock) on df.IdHeader = @idDoc_From and df.DZT_Name = f.MA_DZT_Name and df.DSE_ID = 'MODULO'
					left outer join CTL_DOC_Value dt with(nolock) on dt.IdHeader = @IdDoc_to and dt.DZT_Name = t.MA_DZT_Name and dt.DSE_ID = 'MODULO'
				where dt.IdRow is null -- solo i record mancanti
				

		-- aggiorno quelli presenti
		update dt set Value = df.Value
			from #FieldFrom F
				inner join #FieldTo T on f.UUID = t.UUID
				inner join CTL_DOC_Value df with(nolock) on df.IdHeader = @idDoc_From and df.DZT_Name = f.MA_DZT_Name and df.DSE_ID = 'MODULO'
				inner join CTL_DOC_Value dt with(nolock) on dt.IdHeader = @IdDoc_to and dt.DZT_Name = t.MA_DZT_Name and dt.DSE_ID = 'MODULO'



	end

	--declare @idDoc_From int
	--declare @IdDoc_to int
	--declare @IdUser int 
	--set @idDoc_From=83312--83255--83332
	--set @IdDoc_to=83377
	--set @IdUser=35846

/*	declare @idbando as int 
	declare @id_TEMPLATE_CONTEST_FROM as int
	declare @id_TEMPLATE_CONTEST_TO as int
	declare @tipodoc_l as varchar(500)
	declare @tipodoc_l_TO as varchar(500)
	select @tipodoc_l=tipodoc from ctl_doc where id=(select linkeddoc from ctl_doc where id=@idDoc_From)
	select @tipodoc_l_TO=tipodoc from ctl_doc where id=(select linkeddoc from ctl_doc where id=@IdDoc_to)
	--print @tipodoc_l
	if @tipodoc_l in ( 'OFFERTA','MANIFESTAZIONE_INTERESSE','DOMANDA_PARTECIPAZIONE' ) or @tipodoc_l like 'ISTANZA%' 
	BEGIN
		select 
			@id_TEMPLATE_CONTEST_FROM=CT.id 
			from ctl_doc C
				inner join ctl_doc CO on CO.id=C.LinkedDoc
				inner join ctl_doc CT on CT.LinkedDoc=CO.LinkedDoc and CT.TipoDoc='TEMPLATE_CONTEST' and CT.deleted=0				
			where C.id=@idDoc_From
			--PRINT @id_TEMPLATE_CONTEST_FROM
	END
	IF  @tipodoc_l = 'RICHIESTA_COMPILAZIONE_DGUE_RISPOSTA'
	BEGIN
		select 
			@id_TEMPLATE_CONTEST_FROM=CT.id 
			from ctl_doc C
				inner join ctl_doc CRIS on C.LinkedDoc=CRIS.id
				inner join ctl_doc CRIC on CRIS.LinkedDoc=CRIC.id
				inner join ctl_doc CO on CO.id=CRIC.LinkedDoc
				inner join ctl_doc CT on CT.LinkedDoc=CO.LinkedDoc and CT.TipoDoc='TEMPLATE_CONTEST' and CT.deleted=0				
			where C.id=@idDoc_From
			--PRINT @id_TEMPLATE_CONTEST_FROM
	END

	if @tipodoc_l_TO in ( 'OFFERTA','MANIFESTAZIONE_INTERESSE','DOMANDA_PARTECIPAZIONE' ) or @tipodoc_l like 'ISTANZA%' 
	BEGIN
		select 
			@id_TEMPLATE_CONTEST_TO=CT.id 
			from ctl_doc C
				inner join ctl_doc CO on CO.id=C.LinkedDoc
				inner join ctl_doc CT on CT.LinkedDoc=CO.LinkedDoc and CT.TipoDoc='TEMPLATE_CONTEST' and CT.deleted=0				
			where C.id=@IdDoc_to
			--PRINT @id_TEMPLATE_CONTEST_FROM
	END

	IF  @tipodoc_l_TO = 'RICHIESTA_COMPILAZIONE_DGUE_RISPOSTA'
	BEGIN
		select 
			@id_TEMPLATE_CONTEST_TO=CT.id 
			from ctl_doc C
				inner join ctl_doc CRIS on C.LinkedDoc=CRIS.id
				inner join ctl_doc CRIC on CRIS.LinkedDoc=CRIC.id
				inner join ctl_doc CO on CO.id=CRIC.LinkedDoc
				inner join ctl_doc CT on CT.LinkedDoc=CO.LinkedDoc and CT.TipoDoc='TEMPLATE_CONTEST' and CT.deleted=0				
			where C.id=@IdDoc_to
			--PRINT @id_TEMPLATE_CONTEST_TO
	END
	
	*/
	

END





GO
