USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_STARTUPDBAPPLICATION_GROUP_PROGRAMMAZIONE_INIZIATIVE]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OLD_STARTUPDBAPPLICATION_GROUP_PROGRAMMAZIONE_INIZIATIVE]
AS
BEGIN

	IF EXISTS (	select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI' and ',' + DZT_ValueDef + ',' like '%,GROUP_PROGRAMMAZIONE_INIZIATIVE,%'	)
	BEGIN
		-- DPCM
		update CTL_Parametri 
				set Valore='0' 
			where Contesto in ('BANDO_GARA_TESTATA','BANDO_GARA_TESTATA_AVVISO','BANDO_SEMPLIFICATO_TESTATA2','BANDO_GARA_TESTATA_GAREINFORMALI','BANDO_GARA_TESTATA_RDO')
			  and Oggetto='DPCM' 
			  and Proprieta='Hide'
		
		-- CategoriaDiSpesa
		update CTL_Parametri 
				set Valore='0' 
			where Contesto in ('BANDO_GARA_TESTATA','BANDO_GARA_TESTATA_AVVISO','BANDO_SEMPLIFICATO_TESTATA2','BANDO_GARA_TESTATA_GAREINFORMALI','BANDO_GARA_TESTATA_RDO')
			  and Oggetto='CategoriaDiSpesa' 
			  and Proprieta='Hide'

		-- CATEGORIE_MERC
		update CTL_Parametri 
				set Valore='0' 
			where Contesto in ('BANDO_GARA_TESTATA_AVVISO','BANDO_GARA_TESTATA_GAREINFORMALI','BANDO_GARA_TESTATA_RDO')
			  and Oggetto='CategoriaDiSpesa' 
			  and Proprieta='Hide'

		-- IdentificativoIniziativa
		update CTL_Parametri 
				set Valore='0' 
			where Contesto in ('BANDO_GARA_TESTATA_GAREINFORMALI','BANDO_GARA_TESTATA_RDO')
			  and Oggetto='IdentificativoIniziativa' 
			  and Proprieta='Hide'


		-- Merceologia
		update CTL_Parametri 
				set Valore='0' 
			where Contesto in ('BANDO_GARA_TESTATA_GAREINFORMALI','BANDO_GARA_TESTATA_RDO')
			  and Oggetto='Merceologia' 
			  and Proprieta='Hide'

	END
	ELSE
	BEGIN
		-- DPCM
		update CTL_Parametri 
				set Valore='1' 
			where Contesto in ('BANDO_GARA_TESTATA','BANDO_GARA_TESTATA_AVVISO','BANDO_SEMPLIFICATO_TESTATA2','BANDO_GARA_TESTATA_GAREINFORMALI','BANDO_GARA_TESTATA_RDO')
			  and Oggetto='DPCM' 
			  and Proprieta='Hide'    
		
		-- CategoriaDiSpesa
		update CTL_Parametri 
				set Valore='1' 
			where Contesto in ('BANDO_GARA_TESTATA','BANDO_GARA_TESTATA_AVVISO','BANDO_SEMPLIFICATO_TESTATA2','BANDO_GARA_TESTATA_GAREINFORMALI','BANDO_GARA_TESTATA_RDO')
			  and Oggetto='CategoriaDiSpesa' 
			  and Proprieta='Hide'

		-- CATEGORIE_MERC
		update CTL_Parametri 
				set Valore='1' 
			where Contesto in ('BANDO_GARA_TESTATA_AVVISO','BANDO_GARA_TESTATA_GAREINFORMALI','BANDO_GARA_TESTATA_RDO')
			  and Oggetto='CategoriaDiSpesa' 
			  and Proprieta='Hide'

		-- IdentificativoIniziativa
		update CTL_Parametri 
				set Valore='1' 
			where Contesto in ('BANDO_GARA_TESTATA_GAREINFORMALI','BANDO_GARA_TESTATA_RDO')
			  and Oggetto='IdentificativoIniziativa' 
			  and Proprieta='Hide'

		-- Merceologia
		update CTL_Parametri 
				set Valore='1' 
			where Contesto in ('BANDO_GARA_TESTATA_GAREINFORMALI','BANDO_GARA_TESTATA_RDO')
			  and Oggetto='Merceologia' 
			  and Proprieta='Hide'

	END
END
GO
