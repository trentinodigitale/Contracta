USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ISTANZA_CREATE_FROM]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[ISTANZA_CREATE_FROM]( @idBando as int, @idPfu as int = -20) 
as
	--Versione=1&data=2014-09-22&Attivita=63141&Nominativo=Federico

	

	declare @newId as int

	SET NOCOUNT ON

	declare @idDoc int
	declare @TipoDoc as varchar(200)
	declare @Stored as varchar(200)

	set @idDoc = @idBando

	set @TipoDoc = ''
	Select @TipoDoc=TipoDoc from CTL_DOC where id=@idDoc

	IF @TipoDoc <> '' 
	BEGIN

		set @Stored='ISTANZA_CREATE_FROM_'+@TipoDoc

		IF  EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE='PROCEDURE' AND ROUTINE_NAME=@Stored) 
		BEGIN
		
		      BEGIN TRAN
		      
                BEGIN TRY
                        
                        Exec @Stored @idBando, @idPfu, @newId output
	                      
                END TRY
                BEGIN CATCH
                        raiserror ('Errore. Chiamata a %s', 16, 1, @Stored)
                        rollback tran
                        return 99
                END CATCH
                
                COMMIT TRAN    
                 
		END
		ELSE
		BEGIN
			raiserror ('Errore. Stored %s non trovata', 16, 1, @Stored)
			--rollback tran
			return 99
		END

	END
	ELSE
	BEGIN
		
		-- Se non ci sono record sulla ctl_doc con l'id passato
		raiserror ('Errore. Bando non trovato con id : %d', 16, 1, @idDoc)
		--rollback tran
		return 99

	END

	select @newId as id




GO
