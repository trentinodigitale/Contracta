USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DETAIL_CHIARIMENTI_CREATE_FROM_DETAIL_CHIARIMENTI]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DETAIL_CHIARIMENTI_CREATE_FROM_DETAIL_CHIARIMENTI] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT


	-- verifica l'esistenza di un documento salvato
	set @id = 0
		
	if isnull( @id , 0 ) = 0
	begin


		---Insert nella document_chiarimenti per creare la nuova risposta
		insert into dbo.Document_Chiarimenti
		(ID_ORIGIN, DataCreazione, Domanda, Risposta, Allegato, UtenteDomanda, UtenteRisposta, DataUltimaMod, aziragionesociale, azitelefono1, azifax, azie_mail, Protocol, Fascicolo, Document, DomandaOriginale)
		select ID_ORIGIN, DataCreazione,'', '', '', UtenteDomanda, null, getdate(),  aziragionesociale, azitelefono1, azifax, azie_mail, Protocol, Fascicolo, Document, DomandaOriginale
		from Document_Chiarimenti where id=@idDoc
					
			
		set @Id = @@identity	

   end

	-- ritorna l'id della nuovo quesito appena creato
	select @Id as id

END

GO
