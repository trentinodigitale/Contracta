USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[STARTUPDBAPPLICATION]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE PROCEDURE [dbo].[STARTUPDBAPPLICATION] AS
BEGIN

	exec STARTUPDBAPPLICATION_GROUP_OCP_WS

	exec STARTUPDBAPPLICATION_GROUP_PARAMETRI_INFO_ADD
	
	exec STARTUPDBAPPLICATION_GROUP_NOTIER_PA

	exec STARTUPDBAPPLICATION_GROUP_SIMOG

	exec STARTUPDBAPPLICATION_attestazione_di_partecipazione

	exec STARTUPDBAPPLICATION_TED

	exec STARTUPDBAPPLICATION_SIMOG

	exec STARTUPDBAPPLICATION_GROUP_Affidamenti_Semplificati

	exec STARTUPDBAPPLICATION_MODULO_APPALTO_PNRR_PNC

	exec STARTUPDBAPPLICATION_MODULO_MERCATO_ELETTRONICO_AVANZATO
	
	exec STARTUPDBAPPLICATION_RIGETTO_AUTOMATICO_INTEGRAZIONE

	exec STARTUPDBAPPLICATION_SCELTA_RUP

	exec STARTUPDBAPPLICATION_MODULO_STRUTTURA_ENTI

	exec STARTUPDBAPPLICATION_CONTROLLI_OE

	exec STARTUPDBAPPLICATION_LISTINO_ORDINI_CONVENZIONI

	exec STARTUPDBAPPLICATION_GESTIONE_INIPEC

	exec STARTUPDBAPPLICATION_MODULO_GENDER_EQUALITY

	exec STARTUPDBAPPLICATION_GROUP_PROGRAMMAZIONE_INIZIATIVE

	--exec STARTUPDBAPPLICATION_TEMPLATE_GARA

	exec STARTUPDBAPPLICATION_MODULO_OPERATORI_ECONOMICI_ESTAR

	if exists (SELECT * FROM sys.objects  WHERE name='STARTUPDBAPPLICATION_MODULO_CONCORSI' )
	begin
		exec STARTUPDBAPPLICATION_MODULO_CONCORSI
	end

	exec STARTUPDBAPPLICATION_AMPIEZZA_DI_GAMMA

	exec STARTUPDBAPPLICATION_MODULO_CERTIFICAZIONE

	exec STARTUPDBAPPLICATION_MODULO_PBM

END


GO
