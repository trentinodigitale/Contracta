USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_MAIL_CENSIMENTO_utente]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD_MAIL_CENSIMENTO_utente] as

  select
    --azi.idAzi as iddoc,
	pfu.idpfu as iddoc,
	'I' as LNG,

    azi.aziLog as idAz,
    azi.aziLog,
    dbo.CNV('Adesione a AFLink on Web','I') + ' : ' + dbo.CNV('Utente censito','I') as Intestazione,

	pfu.pfuNomeUtente as Nome,
	pfu.pfucognome as Cognome,
	pfu.pfuTel as Telefono,
	pfu.pfuCell as Cellulare,
    pfu.pfuE_Mail as EMailUtente,

    aziAttr3.vatvalore_ft as EMailRif,
    azi.aziRagioneSociale as RagSociale,

    azi.aziE_Mail         as EMail,

    '<li style="margin-left:0px; padding-left:0px;"><strong>' + dbo.cnv('Nome Utente','I') + ':' + '</strong><span style="color:green">' + pfu.pfuLogin + '</span></li>'
	+ '<li style="margin-left:0px; padding-left:0px;"><strong>' + dbo.cnv('Password','I') + ':' + '</strong><span style="color:green">' + pfu.pfuPassword + '</span></li>'
    	   as DatiLogin,

     dbo.CNV('Adesione a','I') + ' ' + dbo.CNV('AFLink on Web','I') as ObjectMail,

	 case when pfu.pfuVenditore = 1 then 'La presente procedura di registrazione non costituisce iscrizione all''' + dbo.cnv('ML_ALBOTELEMATICO','I') + '.'
		else ''	
	 end as warning
	 
    from aziende azi
	   inner join profiliutente pfu ON azi.idazi = pfu.pfuIdAzi

	   left join ProfiliUtenteAttrib pfuAttrib ON pfu.idpfu = pfuAttrib.idPfu

	   left join TipiDatiRange tdr1 ON tdrIdTid = 131 and tdr1.tdrcodice = azi.aziIdDscFormaSoc
	   left join DescsI dsc1 ON dsc1.IdDsc = tdr1.tdrIdDsc

	   left join DM_Attributi aziAttr3 ON azi.idazi = aziAttr3.lnk and aziAttr3.dztnome = 'EMailRiferimentoAzienda'

	   left join lib_domainvalues dmVal ON dmVal.dmv_dm_id = 'GEO' and dmv_cod = azi.aziStatoLeg2

	   




GO
