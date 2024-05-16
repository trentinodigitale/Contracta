USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_OFFERTA_ALLEGATI_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD2_OFFERTA_ALLEGATI_TESTATA_VIEW] AS
select 
	C.Id as id,
	C.IdPfu,
	C.Data,
	C.Titolo,
	OFFERTA.Protocollo as Protocollo,
	OFFERTA.ProtocolloRiferimento as ProtocolloRiferimento,
	OFFERTA.Body as Body,
	OFFERTA.Azienda as destinatario_azi,
	cv.value as Note

	from CTL_DOC C with(nolock) 
			inner join CTL_DOC OFFERTA with(nolock) on OFFERTA.id=C.LinkedDoc
			left join  CTL_DOC_Value CV  with(nolock) on CV.idheader= OFFERTA.id and CV.DSE_ID='TESTATA_RTI' and CV.DZT_Name='DenominazioneATI'  and CV.Row=0
		where C.TipoDoc='OFFERTA_ALLEGATI'

GO
