USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_AFV_Elenco_Lotti_Partecipanti]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW  [dbo].[OLD2_AFV_Elenco_Lotti_Partecipanti] as

	select 
			idBando
			, RegistroBando
			, CIG
			, NumeroLotto as Lotto

			, RegistroOfferta
			, case when isRTI = '0' then 'no' else 'si' end as isRTI
			
			, case when  isRTI = '1' and RuoloPartecipante = '' then 'Ausiliaria' else RuoloPartecipante  end as Ruolo
			
			, idAzienda
			, RagioneSociale
			, case when  isRTI = '1' and RuoloPartecipante = '' then idAziendaAusiliata else null end as idAziendaAusiliata
			, case when isRTI = '0' then '' else RagioneSocialeRTI end as RagioneSocialeRTI
			, Aggiudicatario
			, Posizione

		
		from Gare_Elenco_Invitati_Partecipanti 
		where 
			ISNULL( RegistroOfferta , '' ) <> ''


GO
