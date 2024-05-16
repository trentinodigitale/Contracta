USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_Service_SIMOG_Requests]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD_VIEW_Service_SIMOG_Requests] AS
	SELECT idRow AS id
	       , idRow
	       , idRichiesta
	       , operazioneRichiesta

	       , CASE
	       	    WHEN operazioneRichiesta = 'consultaNumeroGara' THEN 'consultaGara.aspx'
	       	    WHEN operazioneRichiesta = 'consultaCIG' THEN 'consultaCIG.aspx'
                -- *** --
	       	    WHEN operazioneRichiesta = 'garaInserisciGgap' THEN 'Crea'
	       	    WHEN operazioneRichiesta = 'garaModificaGgap' THEN 'Modifica'
                --
	       	    WHEN operazioneRichiesta = 'lottoInserisciGgap' THEN 'CreaLotto'
	       	    WHEN operazioneRichiesta = 'lottoModificaGgap' THEN 'ModificaLotto'
                --
	       	    WHEN operazioneRichiesta = 'consultaNumeroGaraGgap' THEN 'LeggiDatiProcedura'
	       	    WHEN operazioneRichiesta = 'consultaCigGgap' THEN 'LeggiDatiProcedura'
                --
	       	    WHEN operazioneRichiesta = 'consultaSmartCigGgap' THEN 'LeggiDatiProcedura'
                --
	       	    WHEN operazioneRichiesta = 'recuperaNumeroGaraGgap' THEN 'RecuperaDatiConNumeroGara'
                --
	       	    WHEN operazioneRichiesta IN ('creaAggiudicazioneLottoGgapPda', 'creaAggiudicazioneLottoGgapMicrolotto') THEN 'CreaAggiudicazioneLotto'
                -- *** --
                WHEN operazioneRichiesta like '%Ggap%' THEN 'TestDiagnostico' -- TODO: Rimuovere
                -- *** --
	       	    ELSE 'gestioneCIG.aspx'
	       	END AS PAGINAWEB
           
           --   , statoRichiesta
           --   , datoRichiesto
           --   , msgError
           --   , numRetry
           --   , inputWS 
           --   , outputWS
           --   , isOld 
           --   , dateIn
           --   , DataExecuted
           --   , DataFinalizza
           
           , CASE 
		        WHEN operazioneRichiesta LIKE '%Smart___Ggap%' THEN '/SimogGgapApi/SmartCig/'
		        WHEN operazioneRichiesta LIKE '%GGAP%' THEN '/SimogGgapApi/Gara/'
		        ELSE L.DZT_ValueDef + '/simog/'
            END AS WS

    FROM Service_SIMOG_Requests WITH (NOLOCK)
            LEFT JOIN LIB_Dictionary L WITH (NOLOCK) ON L.DZT_Name = 'SYS_strVirtualDirectory'

GO
