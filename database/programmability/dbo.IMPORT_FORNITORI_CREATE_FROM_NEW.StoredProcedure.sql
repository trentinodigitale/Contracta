USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[IMPORT_FORNITORI_CREATE_FROM_NEW]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE PROCEDURE [dbo].[IMPORT_FORNITORI_CREATE_FROM_NEW] 
	( @idDoc int  , @idUser int )
AS
BEGIN

	BEGIN TRAN

	SET NOCOUNT ON	-- set nocount ON è importantissimo

	DECLARE @newId INT
	set @newId = -1

	--CERCO il documento precedente in lavorazione creato 
	--select @newId=id from ctl_doc with(nolock) where TipoDoc='IMPORT_FORNITORI'  and StatoFunzionale='InLavorazione' and Deleted=0 and idpfu = @idUser

	if @newId = -1
	BEGIN
		
		insert into CTL_DOC ( idpfu, TipoDoc, StatoDoc, Data,Caption ,JumpCheck,Titolo,PrevDoc)
			select @idUser,'IMPORT_FORNITORI','Saved',GETDATE(),'','','Senza Titolo',0
		
		set @newId=SCOPE_IDENTITY()


	END



	IF @@ERROR <> 0 
	BEGIN
		raiserror ('Errore creazione record in ctl_doc. [IMPORT_FORNITORI_CREATE_FROM_NEW] ', 16, 1)  --, CAST(@@ERROR AS NVARCHAR(4000)))
		rollback tran
		return 99
	END

	COMMIT TRAN

	-- rirorna l'id del documento appena creato
	select @newId as id

	return 

END






GO
