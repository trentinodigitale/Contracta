USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BANDO_GARA_CREATE_FROM_TEMPLATE_GARA]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[BANDO_GARA_CREATE_FROM_TEMPLATE_GARA] (@idDoc INT, @IdUser INT)
AS
BEGIN
  
  SET NOCOUNT ON;

  DECLARE @IdNewDoc AS INT = 0

	-- Making the copy the document with id in input varible @idDoc
	-- Returns the id of the new document created in the CTL_DOC table in the output variable @IdNewDoc
	EXEC BANDO_GARA_COPIA @idDoc, @IdUser, @IdNewDoc OUTPUT

	--setto sulla doument_bando Ente Proponente che sul template era vuoto
	--faccio la stessa cosa che viene fatta quando viene creata una gara di iniziativa (SP_NUOVA_PROCEDURA_SAVE)
	declare @enteprop nvarchar(MAX)
	set @enteprop=''

	select @enteprop=cast(pfuidazi as varchar(50)) from ProfiliUtente with(nolock) where IdPfu= @IdUser
	--valorizzo @idUser se posso essere RupProponente altrimenti vuoto
	IF NOT EXISTS (  Select DMV_COD from ELENCO_RESPONSABILI_AZI  where RUOLO in ('RUP','RUP_PDG') 
					and idpfu = (select top 1 idpfu from ProfiliUtente where pfuIdAzi=@enteprop) 
					and DMV_Cod=@idUser
				)
	BEGIN
		set @idUser=0
	END
	   
	update document_bando 	
		set 
			EnteProponente = @enteprop + '#\0000\0000'	, 				
			RupProponente =  @idUser , 
			GeneraConvenzione = case when replace( isnull(GeneraConvenzione ,'') , ' ' , '' ) = '' then '0' else GeneraConvenzione end 
		where idheader= @IdNewDoc


	-- Updating the new document copied so that it has 'BANDO_GARA' as TipoDoc
	UPDATE CTL_DOC SET TipoDoc = 'BANDO_GARA' , titolo=replace(titolo, 'Copia di','Nuova Procedura') WHERE Id = @IdNewDoc

	-- Aggiornmo tipodoc sui dettagli (prodptti)
	UPDATE Document_MicroLotti_Dettagli SET TipoDoc = 'BANDO_GARA' WHERE IdHeader = @IdNewDoc AND TipoDoc='TEMPLATE_GARA'

	-- Aggiorno il nome del modello di Testa nella Section_Model
	UPDATE CTL_DOC_SECTION_MODEL
		SET MOD_Name=REPLACE(MOD_Name, 'TEMPLATE_GARA', 'BANDO_GARA')
		WHERE IdHeader = @IdNewDoc AND DSE_ID='TESTATA'

	-- Return the string 'Errore' as the id if something went wrong
	-- Else return the id of the new document if everything went good
	IF @IdNewDoc = 0
	BEGIN
		SELECT 'Errore' AS Id
	END
	ELSE
	BEGIN
		SELECT @IdNewDoc AS Id
	END

END
GO
