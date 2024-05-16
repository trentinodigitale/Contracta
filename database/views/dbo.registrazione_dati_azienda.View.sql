USE [AFLink_TND]
GO
/****** Object:  View [dbo].[registrazione_dati_azienda]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[registrazione_dati_azienda] as
	select
		az.idAzi,
		az.aziRagioneSociale as RagioneSociale,
		isnull(descs.dscTesto,'') as FormaGiuridica,
		isnull(az.aziIndirizzoLeg,'') as Indirizzo,
		isnull(az.aziLocalitaLeg,'') as Comune,
		isnull(az.aziProvinciaLeg,'') as Provincia,
		isnull(az.aziCapLeg,'') as Cap,
		isnull(attr1.vatValore_FT,'') AS AnnoCCIAA ,
		isnull(attr2.vatValore_FT,'') as NumeroREA,
		isnull(attr3.vatValore_FT,'') as DellaCCIAA,
		isnull(az.aziTelefono1,'') as Telefono,
		isnull(az.aziFax,'') as Fax,
		isnull(az.aziE_Mail,'') as Email,
		isnull(attr4.vatValore_FT,'') as CodiceFiscale,
		isnull(az.aziPartitaIVA,'') as partitaIVA
	from aziende az

			LEFT JOIN tipidatirange dat ON dat.tdridtid = 131 and dat.tdrcodice = az.aziIdDscFormaSoc
			LEFT JOIN descsI descs ON dat.tdrdeleted=0 and descs.IdDsc =  dat.tdriddsc 

			LEFT JOIN DM_Attributi attr1 ON attr1.lnk = az.idAzi and attr1.dztNome = 'ANNOCOSTITUZIONE'
			LEFT JOIN DM_Attributi attr2 ON attr2.lnk = az.idAzi and attr2.dztNome = 'IscrCCIAA'
			LEFT JOIN DM_Attributi attr3 ON attr3.lnk = az.idAzi and attr3.dztNome = 'SedeCCIAA'
			LEFT JOIN DM_Attributi attr4 ON attr4.lnk = az.idAzi and attr4.dztNome = 'codicefiscale'
			
	 
GO
