USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[STARTUPDBAPPLICATION_RIGETTO_AUTOMATICO_INTEGRAZIONE]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[STARTUPDBAPPLICATION_RIGETTO_AUTOMATICO_INTEGRAZIONE]
AS
BEGIN

	----------------------------------------------------------------------------------------------------
	--se attivo paraemtro per il rigetto automatico sulle istanze visualizzo i campi relativi sui modelli 
	----------------------------------------------------------------------------------------------------
	IF EXISTS (	select Id from ctl_parametri with (nolock) where contesto='ISTANZA' 
				and Oggetto='RIGETTO_AUTOMATICO_INTEGRAZIONE' and Proprieta='ATTIVA' and valore='NO')
	BEGIN
		
		update 
				CTL_Parametri
					set valore='1'
				where
					contesto='PARAMETRI_ALBO_COMUNICAZIONI' and Oggetto='TestoRigettoAutomatico' and Proprieta='HIDE'

		update 
				CTL_Parametri
					set valore='1'
				where
					contesto='PARAMETRI_ALBO_COMUNICAZIONI' and Oggetto='OggettoRigettoAutomatico' and Proprieta='HIDE'
		update 
				CTL_Parametri
					set valore='1'
				where
					contesto='PARAMETRI_SDA_COMUNICAZIONI' and Oggetto='TestoRigettoAutomatico' and Proprieta='HIDE'

		update 
				CTL_Parametri
					set valore='1'
				where
					contesto='PARAMETRI_SDA_COMUNICAZIONI' and Oggetto='OggettoRigettoAutomatico' and Proprieta='HIDE'

		update 
				CTL_Parametri
					set valore='1'
				where
					contesto='PARAMETRI_ALBO_FORN_COMUNICAZIONI' and Oggetto='TestoRigettoAutomatico' and Proprieta='HIDE'

		update 
				CTL_Parametri
					set valore='1'
				where
					contesto='PARAMETRI_ALBO_FORN_COMUNICAZIONI' and Oggetto='OggettoRigettoAutomatico' and Proprieta='HIDE'

		update 
				CTL_Parametri
					set valore='1'
				where
					contesto='PARAMETRI_ALBO_LAVORI_COMUNICAZIONI' and Oggetto='TestoRigettoAutomatico' and Proprieta='HIDE'

		update 
				CTL_Parametri
					set valore='1'
				where
					contesto='PARAMETRI_ALBO_LAVORI_COMUNICAZIONI' and Oggetto='OggettoRigettoAutomatico' and Proprieta='HIDE'

		update 
				CTL_Parametri
					set valore='1'
				where
					contesto='PARAMETRI_ALBO_PROF_COMUNICAZIONI' and Oggetto='TestoRigettoAutomatico' and Proprieta='HIDE'

		update 
				CTL_Parametri
					set valore='1'
				where
					contesto='PARAMETRI_ALBO_PROF_COMUNICAZIONI' and Oggetto='OggettoRigettoAutomatico' and Proprieta='HIDE'
	END
	ELSE
	BEGIN
		update 
				CTL_Parametri
					set valore='0'
				where
					contesto='PARAMETRI_ALBO_COMUNICAZIONI' and Oggetto='TestoRigettoAutomatico' and Proprieta='HIDE'

		update 
				CTL_Parametri
					set valore='0'
				where
					contesto='PARAMETRI_ALBO_COMUNICAZIONI' and Oggetto='OggettoRigettoAutomatico' and Proprieta='HIDE'
		update 
				CTL_Parametri
					set valore='0'
				where
					contesto='PARAMETRI_SDA_COMUNICAZIONI' and Oggetto='TestoRigettoAutomatico' and Proprieta='HIDE'

		update 
				CTL_Parametri
					set valore='0'
				where
					contesto='PARAMETRI_SDA_COMUNICAZIONI' and Oggetto='OggettoRigettoAutomatico' and Proprieta='HIDE'

		update 
				CTL_Parametri
					set valore='1'
				where
					contesto='PARAMETRI_ALBO_FORN_COMUNICAZIONI' and Oggetto='TestoRigettoAutomatico' and Proprieta='HIDE'

		update 
				CTL_Parametri
					set valore='0'
				where
					contesto='PARAMETRI_ALBO_FORN_COMUNICAZIONI' and Oggetto='OggettoRigettoAutomatico' and Proprieta='HIDE'

		update 
				CTL_Parametri
					set valore='0'
				where
					contesto='PARAMETRI_ALBO_LAVORI_COMUNICAZIONI' and Oggetto='TestoRigettoAutomatico' and Proprieta='HIDE'

		update 
				CTL_Parametri
					set valore='0'
				where
					contesto='PARAMETRI_ALBO_LAVORI_COMUNICAZIONI' and Oggetto='OggettoRigettoAutomatico' and Proprieta='HIDE'

		update 
				CTL_Parametri
					set valore='0'
				where
					contesto='PARAMETRI_ALBO_PROF_COMUNICAZIONI' and Oggetto='TestoRigettoAutomatico' and Proprieta='HIDE'

		update 
				CTL_Parametri
					set valore='0'
				where
					contesto='PARAMETRI_ALBO_PROF_COMUNICAZIONI' and Oggetto='OggettoRigettoAutomatico' and Proprieta='HIDE'
	END

END
GO
