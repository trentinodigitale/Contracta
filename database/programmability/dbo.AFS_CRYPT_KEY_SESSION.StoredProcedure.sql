USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[AFS_CRYPT_KEY_SESSION]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AFS_CRYPT_KEY_SESSION]( @idPfu int , @ValueKeyDoc int)
AS
BEGIN

	SET NOCOUNT ON

	declare @Ver varchar(10)
	declare @SqlScript nvarchar(max)

	-- verifico se il documento ha una versione specifica della cifratura
	select @Ver = CRYPT_VER from  CTL_DOC with(nolock) where Id = @ValueKeyDoc

	set @Ver = ISNULL( @Ver ,  '0' ) 

	set @SqlScript =  'exec AFS_CRYPT_KEY_ATTACH_VER_' + @Ver  + ' ' +   cast( @idPfu as varchar ) + ', ' + cast( @ValueKeyDoc as varchar )

	EXEC ( @SqlScript )

END

GO
