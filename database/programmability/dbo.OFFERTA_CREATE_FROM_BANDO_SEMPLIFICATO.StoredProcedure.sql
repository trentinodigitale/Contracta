USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OFFERTA_CREATE_FROM_BANDO_SEMPLIFICATO]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[OFFERTA_CREATE_FROM_BANDO_SEMPLIFICATO]( @idBando as int, @idPfu as int) 
as
BEGIN







	declare @Errore as nvarchar(2000)
	set @Errore=''
	IF EXISTS (Select * from ctl_doc where id=@idBando and tipodoc='OFFERTA' and statodoc='Saved')
	BEGIN
		set @Errore='Operazione non consentita per lo stato del documento'
	END
	if @Errore=''
	BEGIN
		--in questo caso sto facendo uno copia da una inviata
		IF EXISTS (Select * from ctl_doc where id=@idBando and tipodoc='OFFERTA')
		BEGIN
			exec  ISTANZA_COPY_FROM @idBando, @idPfu

			-- svuota la sezione dei totali se null
			declare @idNewDoc int
			select @idNewDoc =  max(id ) from ctl_doc where prevdoc = 	@idBando and tipodoc = 'OFFERTA' and deleted = 0		
			if isnull( @idNewDoc , 0 ) > 0 
				update ctl_doc_value set value = '' where idheader = @idNewDoc and value is null and DSE_ID = 'TOTALI' 

		END
		ELSE
		BEGIN
			exec ISTANZA_CREATE_FROM @idBando , @idPfu
		END
	END
	if @Errore <> ''
	BEGIN
		select 'ERRORE' as id , @Errore + '~~@TITLE=Attenzione~~@ICON=4'   as Errore
	END

END





GO
