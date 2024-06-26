USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_RICHIESTA_CODIFICA_PRODOTTI_CREATE_FROM_CODIFICA_PRODOTTI]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[OLD_RICHIESTA_CODIFICA_PRODOTTI_CREATE_FROM_CODIFICA_PRODOTTI] 
	( @idDoc int , @IdUser int )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @Idazi as INT
	declare @Errore as nvarchar(2000)
	declare @newid as int
	declare @idr as int

	set @Errore=''	
	
	if @Errore=''
	begin
		
		--Se e' ho già il profilo ACCESSO_DOC_OE esco 
		if not exists (select * from Document_MicroLotti_Dettagli where IdHeader=@idDoc and Tipodoc='CODIFICA_PRODOTTI' and StatoRiga='Rifiutato' )
			set @Errore='Non sono presenti prodotti da codificare sul documento di partenza'
	end
	
	if @Errore=''
	BEGIN
		---CERCO UNA RICHIESTA IN CORSO CREATA DA QUEL DOCUMENTO
		select @newId = id from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in (  'RICHIESTA_CODIFICA_PRODOTTI'  ) and StatoFunzionale='InLavorazione'
		
	END
	if @newId is null
	begin
	   -- CREO IL DOCUMENTO
		INSERT into CTL_DOC (IdPfu,  TipoDoc  , idpfuincharge ,Azienda ,body,LinkedDoc)
		select  @IdUser,'RICHIESTA_CODIFICA_PRODOTTI' , @IdUser ,Azienda,body,@idDoc
		from ctl_doc
		where id=@idDoc		

		set @newId = SCOPE_IDENTITY()

		--INSERISCO UN RECORD FITTIZIO PER LA SEZIONE PROTOCOLLO
		insert into Document_dati_protocollo (idHeader) values(@newId)

		--INSERISCO IL RECORD NELLA CRONOLOGIA DI CREAZIONE DOCUMENTO
				
		declare @userRole as varchar(100)
		select  @userRole= isnull( attvalue,'')
			from  profiliutenteattrib where idpfu = @IdUser and dztnome = 'UserRoleDefault'  
		IF ISNULL(@userRole ,'') = ''
		set @userRole ='UtenteEnte'

	    insert into CTL_ApprovalSteps 
			( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
				values ('RICHIESTA_CODIFICA_PRODOTTI' , @newId , 'Compiled' , '' , @IdUser     , @userRole       , 1         , getdate() )
		---RIPORTO IL MODELLO DINAMICO E LE INFO RELATIVE AL MODELLO PRESENTI SULLA RICHIESTA PRECEDENTE DALLA QUALE DERIVA LA CODIFICA
		declare @prev_ric as int
		select @prev_ric=linkeddoc from ctl_doc where id=@idDoc

		insert into CTL_DOC_SECTION_MODEL (IdHeader,DSE_ID,MOD_Name)
		select @newId,DSE_ID,MOD_Name
		from CTL_DOC_SECTION_MODEL where IdHeader=@prev_ric


		insert into CTL_DOC_Value(IdHeader,DSE_ID,Row,Dzt_name,value)
		select @newId,DSE_ID,Row,Dzt_name,value
		from CTL_DOC_Value where IdHeader=@prev_ric

		---RIPORTO I PRODOTTI CHE NON SONO STATI CODIFICATI IN PRECENDENZA

		declare CurProg Cursor Static for 
		select id from Document_MicroLotti_Dettagli  
		where idHEader=@IDDOC  and tipodoc='CODIFICA_PRODOTTI' and StatoRiga='Rifiutato'
		order by id

		open CurProg
		
		FETCH NEXT FROM CurProg INTO @id 

		WHILE @@FETCH_STATUS = 0
		BEGIN
			--CODIFICATO IL PRODOTTO LO DUPLICO CON TIPODOC='META_PRODOTTO'
			INSERT into Document_MicroLotti_Dettagli ( IdHeader,TipoDoc,EsitoRiga )
					select @newid , 'RICHIESTA_CODIFICA_PRODOTTI',''
				set @idr = SCOPE_IDENTITY()			
				-- ricopio tutti i valori
				exec COPY_RECORD  'Document_MicroLotti_Dettagli'  , @id , @idr , ',Id,IdHeader,TipoDoc,EsitoRiga, '	

							             
			FETCH NEXT FROM CurProg  INTO @id 
		END 

		CLOSE CurProg
		DEALLOCATE CurProg






	end

	if  ISNULL(@newId,0) <> 0
	begin
		-- rirorna l'id del doc da aprire
		select @newId as id
	
	end
	else
	begin

		select 'Errore' as id , 'ERROR' as Errore

	end
END











GO
