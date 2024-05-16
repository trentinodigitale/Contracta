USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PDA_COMUNICAZIONE_GENERICA_CREATE_FROM_ESITO_DEFINITIVO_INVITATI_MICROLOTTI_OEPV]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[PDA_COMUNICAZIONE_GENERICA_CREATE_FROM_ESITO_DEFINITIVO_INVITATI_MICROLOTTI_OEPV] 
	( @idDoc int , @IdUser int  )
AS
--Versione=1&data=2014-03-18&Attivita=54707&Nominativo=Enrico
--crea la nuova comunicazione di aggiudicazione definitiva invitati
BEGIN
	--declare @criterio as int
	--select @criterio=CriterioAggiudicazioneGara from PDA_MICROLOTTI_VIEW_TESTATA where id=@idDoc
	exec PDA_COMUNICAZIONE_GENERICA_CREATE_FROM_ESITO_SUB_INVITATI_MICROLOTTI @idDoc , @IdUser , 'AggiudicazioneDef', '15532'
--	

END


GO
