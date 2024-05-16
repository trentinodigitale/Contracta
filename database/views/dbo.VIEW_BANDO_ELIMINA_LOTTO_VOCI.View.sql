USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_BANDO_ELIMINA_LOTTO_VOCI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[VIEW_BANDO_ELIMINA_LOTTO_VOCI]
as

	select 
		BV.id,
		BE.idpfu,
		BE.Protocollo,
		BE.DataInvio,
		BE.StatoFunzionale,
		BE.ProtocolloRiferimento,
		BE.Body
		,BE.id as ID_FROM
		from 
			ctl_doc BV inner join Document_MicroLotti_Dettagli BED on BV.linkeddoc=BED.id and BED.tipodoc='BANDO_ELIMINA_LOTTO'
				inner join ctl_doc BE on BE.id = BED.idheader
				--inner join ctl_doc BS on BE.linkedoc=BS.
			where 
				BV.tipodoc='BANDO_ELIMINA_LOTTO_VOCI'
GO
