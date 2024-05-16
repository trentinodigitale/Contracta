USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[UPD_MERC_ADDITIONAL_INFO_CREATE_FROM_MERC_ADDITIONAL_INFO]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[UPD_MERC_ADDITIONAL_INFO_CREATE_FROM_MERC_ADDITIONAL_INFO] ( @iddoc int , @IdUser int  )
AS
BEGIN

	SET NOCOUNT ON;
	declare @Id as INT
	declare @NewIdRow int
	declare @idrow_from int
	declare @Idazi as INT
	declare @classe as nvarchar(MAX) 
	declare @out as int
	declare @ELENCO_PATH_CLASSI_MODELLO nvarchar(MAX) 
	set @ELENCO_PATH_CLASSI_MODELLO=''
	declare @ELENCO_CLASSI_MODELLO nvarchar(MAX) 
	set @ELENCO_CLASSI_MODELLO = ''


	declare @Errore as nvarchar(2000)
	set @Errore=''
	set @Id =0

	---VERIFICO SE ESISTE IL DOCUMENTO IN LAVORAZIONE
	select @Id=id from CTL_DOC where LinkedDoc=@iddoc and TipoDoc='UPD_MERC_ADDITIONAL_INFO' and StatoFunzionale='InLavorazione' and Deleted =0
																   
	if @Id=0  --NON ESISTE LO CREO
	BEGIn
		INSERT INTO CTl_DOC (titolo,tipodoc,IdPfu,LinkedDoc,Azienda)
		select 'Modifica In formazioni Aggiuntive','UPD_MERC_ADDITIONAL_INFO',@IdUser,@iddoc,Azienda
			from CTL_DOC where Id=@iddoc
		
		set @Id = SCOPE_IDENTITY()

		insert into CTL_DOC_Value ( DSE_ID,IdHeader,Row,DZT_Name,Value )
		select DSE_ID,@Id,Row,DZT_Name,Value 
			from CTL_DOC_Value where IdHeader=@iddoc and DSE_ID='CLASSE' and DZT_Name='ClasseIscriz'

		insert into CTL_DOC_Value ( DSE_ID,IdHeader,Row,DZT_Name,Value )
		select DSE_ID,@Id,Row,DZT_Name,Value 
			from CTL_DOC_Value where IdHeader=@iddoc and DSE_ID='CLASSE' and DZT_Name='Body'

		insert into CTL_DOC_SECTION_MODEL(DSE_ID,MOD_Name,IdHeader)
		select 'MERC_ADDITIONAL_INFO_CLASSE_DETTAGLI',MOD_Name,@Id
			from CTL_DOC_SECTION_MODEL where IdHeader=@iddoc and DSE_ID='MERC_ADDITIONAL_INFO_CLASSE_DETTAGLI'

		insert into CTL_DOC_SECTION_MODEL(DSE_ID,MOD_Name,IdHeader)
		select 'MERC_ADDITIONAL_INFO_CLASSE_DETTAGLI_SAVE',MOD_Name,@Id
			from CTL_DOC_SECTION_MODEL where IdHeader=@iddoc and DSE_ID='MERC_ADDITIONAL_INFO_CLASSE_DETTAGLI'

		---INFORMAZIONI
		Insert into Document_MicroLotti_Dettagli ( IdHeader , TipoDoc  )
		select @Id , 'UPD_MERC_ADDITIONAL_INFO'
			
		set @NewIdRow=SCOPE_IDENTITY()

		-- ricopio tutti i valori
		select @idrow_from=ID from Document_MicroLotti_Dettagli where IdHeader=@iddoc and TipoDoc='MERC_ADDITIONAL_INFO'
		exec COPY_RECORD  'Document_MicroLotti_Dettagli'  ,@idrow_from  , @NewIdRow, ',Id,IdHeader,tipodoc,'
			
		


	END
	ELSE --ESISTE AGGIORNO IL MODELLO
	BEGIN
		--AGGIORNO LE CLASSI
		update CTL_DOC_Value set Value= ( select Value from  CTL_DOC_Value where IdHeader=@iddoc and DSE_ID='CLASSE' and DZT_Name='ClasseIscriz')
			where IdHeader=@Id and DSE_ID = 'CLASSE' and DZT_Name='ClasseIscriz'
		
		--AGGIORNO IL MODELLO DINAMICO
		update CTL_DOC_SECTION_MODEL set MOD_Name=(select MOD_Name from CTL_DOC_SECTION_MODEL where IdHeader=@iddoc and DSE_ID='MERC_ADDITIONAL_INFO_CLASSE_DETTAGLI' )
			where IdHeader=@id and DSE_ID='MERC_ADDITIONAL_INFO_CLASSE_DETTAGLI'
		
		update CTL_DOC_SECTION_MODEL set MOD_Name=(select MOD_Name from CTL_DOC_SECTION_MODEL where IdHeader=@iddoc and DSE_ID='MERC_ADDITIONAL_INFO_CLASSE_DETTAGLI' )
			where IdHeader=@id and DSE_ID='MERC_ADDITIONAL_INFO_CLASSE_DETTAGLI_SAVE'
		
		---INFORMAZIONI
		-- ricopio tutti i valori
		--select @NewIdRow=ID from Document_MicroLotti_Dettagli where IdHeader=@id and TipoDoc='MERC_ADDITIONAL_INFO'
		--select @idrow_from=ID from Document_MicroLotti_Dettagli where IdHeader=@iddoc and TipoDoc='MERC_ADDITIONAL_INFO'
		--exec COPY_RECORD  'Document_MicroLotti_Dettagli'  ,@idrow_from  , @NewIdRow, ',Id,IdHeader,tipodoc,'

	END




	if @Errore = '' --and @Id > 0
	begin
		-- rirorna l'id del doc appena creato
		select @Id as id
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
	
END





GO
