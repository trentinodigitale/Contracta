USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_REGISTRAZIONE_FORNITORE_CREATE_FROM_AZI_ENTE]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[OLD2_REGISTRAZIONE_FORNITORE_CREATE_FROM_AZI_ENTE] ( @IdDoc int  , @idUser int )
AS
BEGIN
	
	SET NOCOUNT ON

	DECLARE @id INT							-- ID CTL_DOC
	DECLARE @idDocument_Aziende INT			-- ID Document_Aziende
	DECLARE @Errore as nvarchar(2000)
	DECLARE @pfuIdAzi int

	-- Estraggo l'id azienda per l'utente @idUser
	SELECT @pfuIdAzi = pfuIdAzi  
		FROM ProfiliUtente 
		WHERE IdPfu = @idUser 

	set @Id = 0
	set @Errore=''
		
	-- Verifico l'esistenza del documento nella CTL_DOC, nello stato "InLavorazione" per l'utente @idUser e per l'azienda @pfuIdAzi non eliminato
	SELECT @Id = id
		from CTL_DOC with(nolock) 
		where tipodoc = 'REGISTRAZIONE_FORNITORE' 
			and azienda = @pfuIdAzi 
			and StatoFunzionale = 'InLavorazione' 
			and deleted = 0
			and IdPfu = @idUser 
	
	-- Se il documento non è presente lo creo nella CTL_DOC
	IF @Id = 0 and @Errore=''
		BEGIN
			--inserisco nella ctl_doc		
			insert into CTL_DOC ( IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda, StatoFunzionale,IdPfuInCharge )
				values			( @idUser, 'REGISTRAZIONE_FORNITORE', 'Saved' , 'Registrazione nuovo fornitore' , '' , @pfuIdAzi , 'InLavorazione', @idUser )

			set @Id = SCOPE_IDENTITY()
		END
	
		
	IF @Errore=''
		BEGIN
			set @idDocument_Aziende = 0 

			-- Se non ci sono stati errori, Verifico l'esistenza del record nella "Document_Aziende" legata al documento della CTL_DOC
			SELECT @idDocument_Aziende = id
				FROM Document_Aziende with(nolock) 
				WHERE idHeader = @Id 
					--and IdAzi = @pfuIdAzi 
					and IdPfu = @idUser 
					and TipoOperAnag ='REGISTRAZIONE_FORNITORE'

			-- Se il documento non è presente lo creo nella "Document_Aziende"
			IF @idDocument_Aziende = 0 and @Errore=''
			BEGIN
				--inserisco nella Document_Aziende		
				INSERT INTO Document_Aziende ( IdPfu, TipoOperAnag, Stato, idHeader) --IdAzi
					VALUES ( @idUser, 'REGISTRAZIONE_FORNITORE', 'Saved' ,  @Id) --@pfuIdAzi 

				SET @idDocument_Aziende = SCOPE_IDENTITY()
				END

			IF @Errore=''
				BEGIN
					SELECT @Id AS id , @Errore AS Errore
				END
			ELSE
				BEGIN
					SELECT 'Errore' AS id , @Errore AS Errore
				END
		END
	ELSE
		BEGIN
			SELECT 'Errore' AS id , @Errore AS Errore
		END
END


GO
