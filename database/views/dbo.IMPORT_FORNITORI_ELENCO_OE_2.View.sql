USE [AFLink_TND]
GO
/****** Object:  View [dbo].[IMPORT_FORNITORI_ELENCO_OE_2]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








create VIEW [dbo].[IMPORT_FORNITORI_ELENCO_OE_2] as 
		select * from 
		(
			select idheader, 
					
					 value,
					
					
					dzt_name , 
					row

				from ctl_doc_value  p with(nolock)
					where dse_id = 'ELENCO' 
        
		) as P
			pivot
			(
				min(value)
				for p.dzt_name in (
		
							[aziCAPLeg],
							[aziDataCreazione],
							[aziE_Mail],
							[aziFAX],
							[aziIndirizzoLeg],

							[aziLocalitaLeg],
							[aziLocalitaLeg2],
							

							[aziProvinciaLeg2],
							[aziRagioneSociale],

							[aziSitoWeb],
							[aziStatoLeg2],
							[aziTelefono1],
							[aziTelefono2],
							[aziVenditore],
							[CARCodiceFornitore],
							[CG44_DITTA_CG18],
							[CodiceFiscale],
							[EsitoRiga],
							[aziPArtitaIVA],
							[EsitoImport]
		
				 )
			) as PIV

GO
