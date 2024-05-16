USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_STARTUPDBAPPLICATION_attestazione_di_partecipazione]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OLD_STARTUPDBAPPLICATION_attestazione_di_partecipazione]
AS
BEGIN

	-----------------------------------------------------------------------------------
	--SE IL PARAMETRO attestazione_di_partecipazione E' ATTIVO SUL CLIENTE LE PROPRIETA'
	--VENGONO MESSE PER RENDERE VISIBILI I CAMPI	
	--ALTRIMENTI METTE HIDE	
	-----------------------------------------------------------------------------------
	IF dbo.PARAMETRI('ATTIVA_MODULO','attestazione_di_partecipazione','ATTIVA','YES',-1) = 'NO'
	BEGIN
		update CTL_Parametri 
			set Valore='1' 
			where Contesto='CONFIG_MODELLI_LOTTI_MODELLI' and Oggetto='MOD_Cauzione' 
			and Proprieta='Hide'
		
		update CTL_Parametri 
			set Valore='1' 
			where Contesto='BANDO_SEMPLIFICATO_TESTATA2' and Oggetto='ClausolaFideiussoria' 
			and Proprieta='Hide'
		update CTL_Parametri 
			set Valore='1' 
			where Contesto='BANDO_SEMPLIFICATO_IN_APPROVE_TESTATA' and Oggetto='ClausolaFideiussoria' 
			and Proprieta='Hide'
		update CTL_Parametri 
			set Valore='1' 
			where Contesto='BANDO_GARA_TESTATA_AVVISO' and Oggetto='ClausolaFideiussoria' 
			and Proprieta='Hide'
		update CTL_Parametri 
			set Valore='1' 
			where Contesto='BANDO_GARA_TESTATA_ACCORDOQUADRO' and Oggetto='ClausolaFideiussoria' 
			and Proprieta='Hide'
		update CTL_Parametri 
			set Valore='1' 
			where Contesto='BANDO_GARA_TESTATA' and Oggetto='ClausolaFideiussoria' 
			and Proprieta='Hide' 
	END
	ELSE
	BEGIN
		update CTL_Parametri 
			set Valore='0' 
			where Contesto='CONFIG_MODELLI_LOTTI_MODELLI' and Oggetto='MOD_Cauzione' 
			and Proprieta='Hide' 

		update CTL_Parametri 
			set Valore='0' 
			where Contesto='BANDO_SEMPLIFICATO_TESTATA2' and Oggetto='ClausolaFideiussoria' 
			and Proprieta='Hide'
		update CTL_Parametri 
			set Valore='0' 
			where Contesto='BANDO_SEMPLIFICATO_IN_APPROVE_TESTATA' and Oggetto='ClausolaFideiussoria' 
			and Proprieta='Hide'
		update CTL_Parametri 
			set Valore='0' 
			where Contesto='BANDO_GARA_TESTATA_AVVISO' and Oggetto='ClausolaFideiussoria' 
			and Proprieta='Hide'
		update CTL_Parametri 
			set Valore='0' 
			where Contesto='BANDO_GARA_TESTATA_ACCORDOQUADRO' and Oggetto='ClausolaFideiussoria' 
			and Proprieta='Hide'
		update CTL_Parametri 
			set Valore='0' 
			where Contesto='BANDO_GARA_TESTATA' and Oggetto='ClausolaFideiussoria' 
			and Proprieta='Hide' 
	END


END
GO
