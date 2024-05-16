USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_MAIL_CENSIMENTO_utente_backoffice]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_MAIL_CENSIMENTO_utente_backoffice] as
  select
    
    --azi.idAzi as iddoc,
	pfu.idPfu as iddoc,
    'I' as LNG,

    azi.aziLog as idAz,
    azi.aziLog,
    dbo.CNV('Adesione a AFLink on Web','I') + ' : ' + dbo.CNV('Utente censito','I') as Intestazione,
    aziAttr2.vatvalore_ft as Cognome,
    aziAttr1.vatvalore_ft as Nome,
    --aziAttr3.vatvalore_ft as EMailRif,
	azi.aziE_Mail as EMailRif,
    azi.aziRagioneSociale as RagSociale,
    dsc1.dscTesto		 as NaturaGiuridica,
    azi.aziIndirizzoLeg   as Indirizzo,
    azi.aziLocalitaLeg    as Citta,
    azi.aziProvinciaLeg   as Provincia,
    azi.aziCAPLeg	      as cap,
    dmVal.dmv_DescML      as Stato,
    aziAttr6.vatvalore_ft as AnnoCostituzione,
    aziAttr7.vatvalore_ft as IscrCCIAA,
    aziAttr8.vatvalore_ft as SedeCCIAA,
    aziAttr5.vatvalore_ft as codicefiscale,
    azi.aziPartitaIva     as PartitaIva,
    azi.aziTelefono1      as Telefono,
    azi.aziFAX	           as NumeroFax,
    azi.aziE_Mail         as EMail,
    --aziAttr2.vatvalore_ft   as CognomeRapLeg,
    --aziAttr1.vatvalore_ft   as NomeRapLeg,
    --aziAttr9.vatvalore_ft   as TelefonoRapLeg,
    --aziAttr4.vatvalore_ft   as CellulareRapLeg,
	pfu.pfuCognome as CognomeRapLeg,
	pfu.pfunomeutente as NomeRapLeg,
	pfu.pfuTel as TelefonoRapLeg,
	pfu.pfuCell as CellulareRapLeg,
    pfu.pfuE_Mail	        as EMailRapLeg,
    aziAttr3.vatvalore_ft   as EMailRiferimentoAzienda,
    --aziAttr10.vatvalore_ft  as funzione_aziendale,
	pfu.pfuRuoloAziendale as funzione_aziendale,
    ''	   as DatiLogin,

    dbo.CNV('Adesione a','I') + ' ' + dbo.CNV('AFLink on Web','I') as ObjectMail

    from aziende azi

	   inner join profiliutente pfu ON azi.idazi = pfu.pfuIdAzi
	   left join ProfiliUtenteAttrib pfuAttrib ON pfu.idpfu = pfuAttrib.idPfu

	   left join TipiDatiRange tdr1 ON tdrIdTid = 131 and tdr1.tdrcodice = azi.aziIdDscFormaSoc
	   left join DescsI dsc1 ON dsc1.IdDsc = tdr1.tdrIdDsc

	   left join DM_Attributi aziAttr1 ON azi.idazi = aziAttr1.lnk and aziAttr1.dztnome = 'NomeRapLeg'
	   left join DM_Attributi aziAttr2 ON azi.idazi = aziAttr2.lnk and aziAttr2.dztnome = 'CognomeRapLeg'
	   left join DM_Attributi aziAttr3 ON azi.idazi = aziAttr3.lnk and aziAttr3.dztnome = 'EMailRiferimentoAzienda'
	   left join DM_Attributi aziAttr4 ON azi.idazi = aziAttr4.lnk and aziAttr4.dztnome = 'CellulareRapLeg'
	   left join DM_Attributi aziAttr5 ON azi.idazi = aziAttr5.lnk and aziAttr5.dztnome = 'codicefiscale'
	   left join DM_Attributi aziAttr6 ON azi.idazi = aziAttr6.lnk and aziAttr6.dztnome = 'ANNOCOSTITUZIONE'
	   left join DM_Attributi aziAttr7 ON azi.idazi = aziAttr7.lnk and aziAttr7.dztnome = 'IscrCCIAA'
	   left join DM_Attributi aziAttr8 ON azi.idazi = aziAttr8.lnk and aziAttr8.dztnome = 'SedeCCIAA'
	   left join DM_Attributi aziAttr9 ON azi.idazi = aziAttr9.lnk and aziAttr9.dztnome = 'TelefonoRapLeg'
	   left join DM_Attributi aziAttr10 ON azi.idazi = aziAttr10.lnk and aziAttr10.dztnome = 'RuoloRapLeg'

	   left join lib_domainvalues dmVal ON dmVal.dmv_dm_id = 'GEO' and dmv_cod = azi.aziStatoLeg2







GO
