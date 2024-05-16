USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[AFS_CRYPT_KEY_SESSION_VER_0]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AFS_CRYPT_KEY_SESSION_VER_0] ( @idPfu int , @ValueKeyDoc int)
AS
BEGIN

	SET NOCOUNT ON

	insert into CTL_LOG_UTENTE ( idpfu , paginaDiArrivo, paginaDiPartenza , querystring )
		values( @idPfu  , 'Richiesta Chiave Cifratura Sessione', '' , 'Riferimento : ' + @ValueKeyDoc + ' - Ver : 0' )

	select '{' + cast( [guid] as varchar(1000)) + '}' as chiave , id as idDoc from CTL_DOC with(nolock) where Id = @ValueKeyDoc

END


GO
