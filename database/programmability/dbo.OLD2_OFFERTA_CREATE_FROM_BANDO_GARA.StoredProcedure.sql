USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_OFFERTA_CREATE_FROM_BANDO_GARA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[OLD2_OFFERTA_CREATE_FROM_BANDO_GARA]( @idBando as int, @idPfu as int) 
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
			exec  ISTANZA_COPY_FROM @idBando , @idPfu
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
