USE [AFLink_TND]
GO
/****** Object:  View [dbo].[RICHIESTA_ATTI_GARA_FROM_BANDO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[RICHIESTA_ATTI_GARA_FROM_BANDO]
AS
SELECT  	
	a.IdPfu,
	a.pfunomeutente + ' ' + a.pfuCognome as Nome,
	aziRagioneSociale,
	SedeEdile,
	IndirizzoEdile,
	PartitaIva,
	codicefiscale,
	ID as ID_FROM,
	protocollo as ProtocolloRiferimento,
	LegalPub,
	NotEditable,
	Descrizione,
	fascicolo,
	id as linkeddoc,
	pfuRuoloAziendale as RuoloRapLeg,
	CIG,
	Body
from CTL_DOC
left join Document_Bando on idHeader=id
cross join (  SELECT   IdPfu,pfunomeutente,pfuCognome,aziRagioneSociale,idazi AS LegalPub,aziPartitaIVA AS PartitaIva, pfuRuoloAziendale,
					   aziIndirizzoLeg AS IndirizzoEdile,aziLocalitaLeg AS SedeEdile, 
					   d5.vatValore_FV AS codicefiscale, ' Descrizione ' AS NotEditable, 'Richiesta Accesso' AS Descrizione

				  FROM profiliutente 
					   INNER JOIN aziende ON pfuidazi = idazi 
					   LEFT OUTER JOIN dm_attributi d5 ON d5.dztnome = 'CodiceFiscale' AND d5.idApp = 1 AND d5.lnk = idazi
					   where  pfuVenditore>0
			 ) a
where tipodoc like 'BANDO%'

GO
