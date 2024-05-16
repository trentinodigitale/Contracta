USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AZI_ws_GETNEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[AZI_ws_GETNEW]
AS
select idazi,
		aziragionesociale as RAGIONESOCIALE,
		isnull(a1.vatvalore_ft,'') as CODICEFORNITORE,
		aziCAPLEG as CAPLEG,
		aziLOCALITALEG as LOCALITALEG,
		aziINDIRIZZOLEG as INDIRIZZOLEG,
		aziPROVINCIALEG as PROVINCIALEG,
		aziSTATOLEG as STATOLEG,
		aziPartitaIVA as PIVA,
		isnull(a2.vatvalore_ft,'') as codicefiscale,
		isnull(a3.vatvalore_ft,'') as CognomeRapLeg,
		isnull(a4.vatvalore_ft,'') as NOMERAPLEG,
		isnull(a5.vatvalore_ft,'') as NAGI,
		aziE_Mail as EMAIL,
		aziTelefono1 as NUMTEL,
		azifax as NUMFAX,
		isnull(a6.vatvalore_ft,'') as ANNOCOSTITUZIONE,
		isnull(a7.vatvalore_ft,'') as ISCRCCIAA,
		isnull(a8.vatvalore_ft,'') as PROVINCIARAPLEG,
		isnull(a9.vatvalore_ft,'') as DATARAPLEG,
		isnull(a10.vatvalore_ft,'') as EMAILRAPLEG,
		isnull(a11.vatvalore_ft,'') as CLASSEISCRIZ,
		isnull(a12.vatvalore_ft,'') as DATAISCRIZALBO,
		isnull(a13.vatvalore_ft,'') as FLAGISCRIZALBO
from aziende
left outer join dm_attributi a1 on a1.idapp=1 and a1.lnk=idazi and a1.dztnome='carCODICEFORNITORE'
left outer join dm_attributi a2 on a2.idapp=1 and a2.lnk=idazi and a2.dztnome='codicefiscale'
left outer join dm_attributi a3 on a3.idapp=1 and a3.lnk=idazi and a3.dztnome='CognomeRapLeg'
left outer join dm_attributi a4 on a4.idapp=1 and a4.lnk=idazi and a4.dztnome='NOMERAPLEG'
left outer join dm_attributi a5 on a5.idapp=1 and a5.lnk=idazi and a5.dztnome='NAGI'
left outer join dm_attributi a6 on a6.idapp=1 and a6.lnk=idazi and a6.dztnome='ANNOCOSTITUZIONE'
left outer join dm_attributi a7 on a7.idapp=1 and a7.lnk=idazi and a7.dztnome='ISCRCCIAA'
left outer join dm_attributi a8 on a8.idapp=1 and a8.lnk=idazi and a8.dztnome='PROVINCIARAPLEG'
left outer join dm_attributi a9 on a9.idapp=1 and a9.lnk=idazi and a9.dztnome='DATARAPLEG'
left outer join dm_attributi a10 on a10.idapp=1 and a10.lnk=idazi and a10.dztnome='EMAILRAPLEG'
left outer join dm_attributi a11 on a11.idapp=1 and a11.lnk=idazi and a11.dztnome='CLASSEISCRIZ'
left outer join dm_attributi a12 on a12.idapp=1 and a12.lnk=idazi and a12.dztnome='DATAISCRIZALBO'
left outer join dm_attributi a13 on a13.idapp=1 and a13.lnk=idazi and a13.dztnome='FLAGISCRIZALBO'


GO
