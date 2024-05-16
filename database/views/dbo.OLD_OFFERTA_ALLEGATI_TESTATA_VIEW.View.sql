USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_OFFERTA_ALLEGATI_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_OFFERTA_ALLEGATI_TESTATA_VIEW] AS
	select 	C.Id as id,
			C.IdPfu,
			C.Data,
			C.Titolo,
			OFFERTA.Protocollo as Protocollo,
			OFFERTA.ProtocolloRiferimento as ProtocolloRiferimento,
			OFFERTA.Body as Body,
			OFFERTA.Azienda as destinatario_azi,
			cv.value as Note,
			cp.value as AttivaFilePending
		from CTL_DOC C with(nolock) 
				inner join CTL_DOC OFFERTA   with(nolock) on OFFERTA.id=C.LinkedDoc
				left join ctl_doc_value cp with(nolock) on cp.IdHeader = offerta.LinkedDoc and cp.DSE_ID = 'PARAMETRI' and cp.DZT_Name = 'AttivaFilePending' -- parametro della gara
				left join  CTL_DOC_Value CV  with(nolock) on CV.idheader= OFFERTA.id and CV.DSE_ID='TESTATA_RTI' and CV.DZT_Name='DenominazioneATI'  and CV.Row=0
		where C.TipoDoc='OFFERTA_ALLEGATI'


GO
