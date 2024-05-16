USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CARICA_INIZIATIVE_CREATE_FROM_USER]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[OLD_CARICA_INIZIATIVE_CREATE_FROM_USER] (@idDoc INT, @IdUser INT)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Id AS INT

	set @Id = -1;
	
	--Controllo se esiste una versione in lavorazione per l'utente collegato
	Select @Id = id 
	from CTL_DOC with (nolock) 
	where tipodoc = 'CARICA_INIZIATIVE' 
		and statofunzionale = 'InLavorazione'
		and idpfu = @IdUser

	-- Se non trovo nessuno in lavorazione lo creo da zero
	IF @Id = -1
	BEGIN
		-- genero il record per il nuovo documento, cancellato logicamente per evitare che sia visibile se non finalizza le operazioni	
		INSERT INTO CTL_DOC (IdPfu, TipoDoc, Azienda, deleted, StrutturaAziendale, Caption, StatoFunzionale)
			SELECT idpfu
				   , 'CARICA_INIZIATIVE'
				   , pfuidazi AS Azienda
				   , 0
				   , cast(pfuidazi AS VARCHAR) + '#' + '\0000\0000' AS StrutturaAziendale
				   , 'Nuovo Carica Iniziative'
				   , 'InLavorazione'
			FROM profiliutente WITH(NOLOCK)
			WHERE idpfu = @IdUser

		SET @id = SCOPE_IDENTITY()

		----inserisco riga di raccordo per i dettagli
		--insert into Document_Programmazione_Iniziativa (idheader)
		--	select @id
	END

	-- La parte finale restituisce il documento
    select @Id as id

END
GO
