USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_CENSIMENTO_azienda]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[MAIL_CENSIMENTO_azienda] as

  select
    azi.idAzi as iddoc,
	--pfu.idpfu as iddoc,
	'I' as LNG,

    azi.aziLog as idAz,
    azi.aziLog,
    dbo.CNV('Adesione a AFLink on Web','I') + ' : ' + dbo.CNV('Azienda censita','I') as Intestazione,
    aziAttr2.vatvalore_ft as Cognome,
    aziAttr1.vatvalore_ft as Nome,
    aziAttr3.vatvalore_ft as EMailRif,
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
    aziAttr2.vatvalore_ft   as CognomeRapLeg,
    aziAttr1.vatvalore_ft   as NomeRapLeg,
    aziAttr9.vatvalore_ft   as TelefonoRapLeg,
    aziAttr4.vatvalore_ft   as CellulareRapLeg,
    pfu2.pfuE_Mail	        as EMailRapLeg,
    aziAttr3.vatvalore_ft   as EMailRiferimentoAzienda,
    aziAttr10.vatvalore_ft  as funzione_aziendale,
	aziAttr11.vatvalore_ft  as CodiceEORI,

    '<li style="margin-left:0px; padding-left:0px;"><strong>' + dbo.cnv('Nome Utente','I') + ':' + '</strong><span style="color:green">' + pfu2.pfuLogin + '</span></li>'
	+ '<li style="margin-left:0px; padding-left:0px;"><strong>' + dbo.cnv('Password','I') + ':' + '</strong><span style="color:green">' + pfu2.pfuPassword + '</span></li>'
    	   as DatiLogin,

     dbo.CNV('Adesione a','I') + ' ' + dbo.CNV('AFLink on Web','I') as ObjectMail

    from aziende azi with(nolock)
	   --inner join profiliutente pfu ON azi.idazi = pfu.pfuIdAzi
	   inner join ( select MIN(idpfu) as idpfu, pfuidazi from ProfiliUtente with(nolock) where isnull(pfuDeleted,0) = 0 group by pfuIdAzi ) pfu on pfu.pfuidazi = azi.IdAzi
	   inner join profiliutente pfu2  with(nolock) ON pfu2.IdPfu = pfu.idpfu

	   --left join ProfiliUtenteAttrib pfuAttrib with(nolock) ON pfu.idpfu = pfuAttrib.idPfu

	   left join TipiDatiRange tdr1 with(nolock) ON tdrIdTid = 131 and tdr1.tdrcodice = azi.aziIdDscFormaSoc
	   left join DescsI dsc1 with(nolock) ON dsc1.IdDsc = tdr1.tdrIdDsc

	   left join DM_Attributi aziAttr1 with(nolock) ON azi.idazi = aziAttr1.lnk and aziAttr1.dztnome = 'NomeRapLeg'
	   left join DM_Attributi aziAttr2 with(nolock) ON azi.idazi = aziAttr2.lnk and aziAttr2.dztnome = 'CognomeRapLeg'
	   left join DM_Attributi aziAttr3 with(nolock) ON azi.idazi = aziAttr3.lnk and aziAttr3.dztnome = 'EMailRiferimentoAzienda'
	   left join DM_Attributi aziAttr4 with(nolock) ON azi.idazi = aziAttr4.lnk and aziAttr4.dztnome = 'CellulareRapLeg'
	   left join DM_Attributi aziAttr5 with(nolock) ON azi.idazi = aziAttr5.lnk and aziAttr5.dztnome = 'codicefiscale'
	   left join DM_Attributi aziAttr6 with(nolock) ON azi.idazi = aziAttr6.lnk and aziAttr6.dztnome = 'ANNOCOSTITUZIONE'
	   left join DM_Attributi aziAttr7 with(nolock) ON azi.idazi = aziAttr7.lnk and aziAttr7.dztnome = 'IscrCCIAA'
	   left join DM_Attributi aziAttr8 with(nolock) ON azi.idazi = aziAttr8.lnk and aziAttr8.dztnome = 'SedeCCIAA'
	   left join DM_Attributi aziAttr9 with(nolock) ON azi.idazi = aziAttr9.lnk and aziAttr9.dztnome = 'TelefonoRapLeg'
	   left join DM_Attributi aziAttr10 with(nolock) ON azi.idazi = aziAttr10.lnk and aziAttr10.dztnome = 'RuoloRapLeg'
	   left join DM_Attributi aziAttr11 with(nolock) ON azi.idazi = aziAttr11.lnk and aziAttr11.dztnome = 'CodiceEORI'
	   

	   left join lib_domainvalues dmVal with(nolock) ON dmVal.dmv_dm_id = 'GEO' and dmv_cod = azi.aziStatoLeg2






GO
