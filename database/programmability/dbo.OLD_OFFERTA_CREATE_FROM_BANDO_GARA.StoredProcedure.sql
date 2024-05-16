USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_OFFERTA_CREATE_FROM_BANDO_GARA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[OLD_OFFERTA_CREATE_FROM_BANDO_GARA]( @iddocumento as int, @idPfu as int) 
as
BEGIN
	--------------------------------------------------------------------------------------------
	--La stored viene chiamata dal viewer riepilogo offerte:
	-- quando clicco sul comando "Nuovo" in quel caso IdDocumento è id del bando 
	-- quando clicco sul comando "Modifica Documento" in quel caso IdDocumento è id dell'offerta selezionata
	--NUOVO crea sempre una nuova offerta
	--MODIFICA controllo lo stato offerta, se saved errore altrimenti fa una copia della stessa
	--------------------------------------------------------------------------------------------
	declare @Errore as nvarchar(2000)
	set @Errore=''
	IF EXISTS (Select * from ctl_doc where id=@iddocumento and tipodoc='OFFERTA' and statodoc='Saved')
	BEGIN
		set @Errore='Operazione non consentita per lo stato del documento'
	END
	if @Errore=''
	BEGIN
		--in questo caso sto facendo uno copia da una inviata
		IF EXISTS (Select * from ctl_doc where id=@iddocumento and tipodoc='OFFERTA')
		BEGIN
			exec  ISTANZA_COPY_FROM @iddocumento , @idPfu
		END
		ELSE
		BEGIN
			exec ISTANZA_CREATE_FROM @iddocumento , @idPfu
		END
	END
	if @Errore <> ''
	BEGIN
		select 'ERRORE' as id , @Errore + '~~@TITLE=Attenzione~~@ICON=4'   as Errore
	END

END




GO
