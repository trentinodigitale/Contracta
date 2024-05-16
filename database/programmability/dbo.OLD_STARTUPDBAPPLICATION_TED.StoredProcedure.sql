USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_STARTUPDBAPPLICATION_TED]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OLD_STARTUPDBAPPLICATION_TED]
AS
BEGIN

	-----------------------------------------------------------------------------------
	-- SE NON E' ATTIVA L'INTEGRAZIONE CON IL TED NASCONDIAMO IL CAMPO RichiestaTED PRESENTE SUI MODELLI DELLE PROCEDURE
	-----------------------------------------------------------------------------------
	IF dbo.IsTedActive(0) = 0
	BEGIN

		update CTL_Parametri 
				set Valore='1' 
			where Contesto IN ( 'BANDO_GARA_TESTATA', 'BANDO_GARA_TESTATA_RDO', 'BANDO_GARA_TESTATA_ACCORDOQUADRO', 'BANDO_GARA_TESTATA_AVVISO', 'BANDO_GARA_TESTATA_COTTIMO', 'BANDO_GARA_TESTATA_GAREINFORMALI', 'BANDO_SEMPLIFICATO_TESTATA','BANDO_SEMPLIFICATO_TESTATA2' )
					and Oggetto='RichiestaTED' and Proprieta='HIDE' 

	END
	ELSE
	BEGIN

		update CTL_Parametri 
				set Valore='0' 
			--where Contesto IN ( 'BANDO_GARA_TESTATA', 'BANDO_GARA_TESTATA_RDO', 'BANDO_GARA_TESTATA_ACCORDOQUADRO', 'BANDO_GARA_TESTATA_AVVISO', 'BANDO_GARA_TESTATA_COTTIMO', 'BANDO_GARA_TESTATA_GAREINFORMALI', 'BANDO_SEMPLIFICATO_TESTATA','BANDO_SEMPLIFICATO_TESTATA2' )
			where Contesto IN ( 'BANDO_GARA_TESTATA' ) and Oggetto='RichiestaTED' and Proprieta='HIDE' 
		
	END

END
GO
