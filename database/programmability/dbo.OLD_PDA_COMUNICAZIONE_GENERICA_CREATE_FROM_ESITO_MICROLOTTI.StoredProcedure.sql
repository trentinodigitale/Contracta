USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PDA_COMUNICAZIONE_GENERICA_CREATE_FROM_ESITO_MICROLOTTI]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[OLD_PDA_COMUNICAZIONE_GENERICA_CREATE_FROM_ESITO_MICROLOTTI] 
	( @idDoc int , @IdUser int  )
AS
--Versione=1&data=2014-03-18&Attivita=54707&Nominativo=Enrico
--crea la nuova comunicazione di aggiudicazione provvisoria partecipanti
BEGIN
		 
	exec PDA_COMUNICAZIONE_GENERICA_CREATE_FROM_ESITO_SUB_MICROLOTTI @idDoc , @IdUser , 'AggiudicazioneProvv',''

END



GO
