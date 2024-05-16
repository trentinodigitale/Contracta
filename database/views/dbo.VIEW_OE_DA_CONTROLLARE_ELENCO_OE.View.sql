USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_OE_DA_CONTROLLARE_ELENCO_OE]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[VIEW_OE_DA_CONTROLLARE_ELENCO_OE]  as 
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
	C.idPfuInCharge,
	a.azipartitaiva,
	d.vatvalore_ft as azicodicefiscale

		from CTL_DOC C with(nolock)
			inner join Aziende A with(nolock) on A.IdAzi=C.Destinatario_Azi
			left outer join dm_attributi d with(nolock) on d.idapp=1 and d.lnk=a.idazi and d.dztnome='codicefiscale'
				where C.TipoDoc='CONTROLLI_OE' and Deleted=0
GO
