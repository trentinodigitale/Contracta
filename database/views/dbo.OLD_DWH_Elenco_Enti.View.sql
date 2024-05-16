USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DWH_Elenco_Enti]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--USE [AFLink_PA_Dev]
--GO

--/****** Object:  View [dbo].[DWH_Elenco_Enti]    Script Date: 30/06/2023 17:16:47 ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO

CREATE VIEW [dbo].[OLD_DWH_Elenco_Enti] AS
SELECT
		idAzi AS [IdAzi],
		aziAcquirente as [aziAcquirente],
		ATECO.DMV_DescML AS [Classificazione attività economica],
		aziCAPLeg AS [CAP],
		aziE_Mail AS [E-Mail (PEC)],
		aziFAX AS [FAX],
		DOM131.DMV_DescML AS [Forma giuridica],
		aziIndirizzoLeg AS [Indirizzo Sede Legale],
		aziLocalitaLeg AS [Località],
		aziLocalitaLeg2 AS [aziLocalitaLeg2],
		aziLog AS [Codice Ente],
		aziPartitaIVA AS [Partita IVA],  
		isnull( ml1.ml_description , DVProfili.DMV_DescML ) as [Profili Azienda],
		isnull( ml3.ml_description , DVProfilo.DMV_DescML ) as [Profilo Azienda],
		aziProvinciaLeg AS [Provincia],
		aziProvinciaLeg2 AS [aziProvinciaLeg2],
		aziRagioneSociale AS [Denominazione Ente],
		aziRegioneLeg AS [Regione],
		aziRegioneLeg2 AS [aziRegioneLeg2],
		aziSitoWeb AS [Indirizzo Web],
		aziStatoLeg AS [Stato],
		aziStatoLeg2 AS [aziStatoLeg2],
		aziTelefono1 AS [Telefono 1],
		aziTelefono2 AS [Telefono 2],
		aziVenditore AS [aziVenditore],
		codicefiscale AS [codicefiscale],
		isnull( ML4.ml_description , DVdisabilita_iscriz_peppol.DMV_DescML ) as [Disabilita Registrazione PEPPOL],
		isnull( ML5.ml_description , DVSetEnteProponente.DMV_DescML ) as [Scelta Ente Proponente],
		isnull( ML6.ml_description , DVTIPO_AMM_ER.DMV_DescML ) as [TIPO_AMM_ER],
		isnull( ML2.ml_description , DVAMM.DMV_DescML ) as [TipoDiAmministr]

	FROM
		AZI_ENTE_VISURA_TESTATA_VIEW

		LEFT JOIN [LIB_DomainValues] DVProfili with (nolock) ON DVProfili.DMV_Cod = aziProfili AND DVProfili.DMV_DM_ID = 'AziProfili'
		left outer join lib_multilinguismo ML1 with(nolock) on ML1.ml_key = DVProfili.DMV_DescML and  ML1.ml_context = 0 and ML1.ml_lng = 'I' 

		LEFT JOIN [LIB_DomainValues] DVAMM with (nolock) ON DVAMM.DMV_Cod = TipoDiAmministr AND DVAMM.DMV_DM_ID = 'TipoDiAmministr'
		left outer join lib_multilinguismo ML2 with(nolock) on ML2.ml_key = DVAMM.DMV_DescML and  ML2.ml_context = 0 and ML2.ml_lng = 'I'

		LEFT JOIN [LIB_DomainValues] DVProfilo  with (nolock) ON DVProfilo.DMV_Cod = aziProfilo AND DVProfilo.DMV_DM_ID = 'aziProfilo'
		left outer join lib_multilinguismo ML3 with(nolock) on ML3.ml_key = DVProfilo.DMV_DescML and  ML3.ml_context = 0 and ML3.ml_lng = 'I'

		LEFT JOIN [LIB_DomainValues] DVdisabilita_iscriz_peppol  with (nolock) ON DVdisabilita_iscriz_peppol.DMV_Cod = disabilita_iscriz_peppol AND DVdisabilita_iscriz_peppol.DMV_DM_ID = 'sino'
		left outer join lib_multilinguismo ML4 with(nolock) on ML4.ml_key = DVdisabilita_iscriz_peppol.DMV_DescML and  ml4.ml_context = 0 and ml4.ml_lng = 'I'

		LEFT JOIN [LIB_DomainValues] DVSetEnteProponente  with (nolock) ON DVSetEnteProponente.DMV_Cod = SetEnteProponente AND DVSetEnteProponente.DMV_DM_ID = '0_1'
		left outer join lib_multilinguismo ML5 with(nolock) on ML5.ml_key = DVSetEnteProponente.DMV_DescML and  ML5.ml_context = 0 and ML5.ml_lng = 'I'

		LEFT JOIN [LIB_DomainValues] DVTIPO_AMM_ER  with (nolock) ON DVTIPO_AMM_ER.DMV_Cod = TIPO_AMM_ER AND DVTIPO_AMM_ER.DMV_DM_ID = 'TIPO_AMM_ER'
		left outer join lib_multilinguismo ML6 with(nolock) on ML6.ml_key = DVTIPO_AMM_ER.DMV_DescML and  ML6.ml_context = 0 and ML6.ml_lng = 'I'

		LEFT JOIN ( 
				select  
						dgcodiceinterno  as  DMV_Cod ,   
				
						dsctesto as DMV_DescML
			
					from dizionarioattributi with (nolock) , dominigerarchici with (nolock) , descsI with (nolock) where dztnome='ATECO'    
						and dztidtid=dgtipogerarchia     
						and dztdeleted=0     
						and iddsc = dgiddsc 
						) as ATECO on ATECO.DMV_Cod  =   aziAtvAtecord
		LEFT JOIN ( 
				select distinct  
						tdrcodice  as  DMV_Cod ,   

						dscTesto as DMV_DescML    

					from tipidatirange  with (nolock), descsI  with (nolock)
						where tdridtid = 131     
						and tdrdeleted=0     
						and IdDsc =  tdriddsc 
			 
						) as DOM131 on DOM131.DMV_Cod  = aziIdDscFormaSoc 

GO
