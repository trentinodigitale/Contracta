USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_OE_DA_CONTROLLARE_ELENCO_OE]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_VIEW_OE_DA_CONTROLLARE_ELENCO_OE]  as 
Select
	
	C.Id,
	C.IdPfu,
	C.ProtocolloRiferimento ,
	C.StatoFunzionale,
	C.DataInvio,
	C.TipoDoc,
	C.linkeddoc,
	C.linkeddoc as idheader,
	Case 
		when C.StatoDoc = 'Saved' then '' 
		else C.StatoDoc
	 end as StatoDoc,
	C.TipoDoc as OPEN_DOC_NAME,
	A.aziRagioneSociale,
	C.DataScadenza,
	C.idPfuInCharge
	from CTL_DOC C with(nolock)
		inner join Aziende A with(nolock) on A.IdAzi=C.Destinatario_Azi
		where C.TipoDoc='CONTROLLI_OE' and Deleted=0
GO
