USE [AFLink_TND]
GO
/****** Object:  View [dbo].[TEMPLATE_PRINT_OFFERTA_PRODOTTI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[TEMPLATE_PRINT_OFFERTA_PRODOTTI]
	as 

		select	d.id as iddoc,		
				a.aziRagioneSociale as StazioneAppaltante,
				Body as Oggetto,
				ProtocolloRiferimento as Registro_Bando,
				b.aziIndirizzoLeg ,
				b.aziCAPLeg ,
				b.aziLocalitaLeg ,
				b.aziProvinciaLeg ,
				isnull(x1.vatValore_FT,'') as cF,  
				b.aziPartitaIVA as PIVA,

				case when isnull(cv.value,'') <> '' then cv.value
				else b.aziRagioneSociale end as DenominazioneATI		

			from ctl_doc d with (nolock)

				inner join aziende a with (nolock) on a.idazi = Destinatario_Azi 
				inner join aziende b with (nolock) on b.idazi = azienda 
				left outer join DM_Attributi x1 with (nolock) on b.IdAzi=x1.lnk and x1.dztNome='codicefiscale'
				left outer join ctl_doc_value CV with (nolock) on CV.IdHeader=d.Id and DSE_ID='TESTATA_RTI' and CV.DZT_Name='DenominazioneATI'

					where d.Deleted = 0


			
GO
