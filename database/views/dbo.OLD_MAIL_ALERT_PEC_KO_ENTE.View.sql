USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_MAIL_ALERT_PEC_KO_ENTE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD_MAIL_ALERT_PEC_KO_ENTE] AS 

	select  a.id as IDDOC
			,'I' as LNG
			, a.eMail
			, b.aziRagioneSociale
			, 'ENTE' as TipoAnag
			, coalesce(c.pfuNome, e.pfuNome,'') as UtenteModifica
			, case when isnull(a.tipodoc,'') <> '' then 
														case when a.tipodoc= 'REGISTRAZIONE' then 'con il documento "Censimento"'
															 else 'con il documento "' + dbo.CNV(a2.DOC_DescML,'I') + '"'
														end
					else ''
			  end as Documento
			, dbo.GETDATEDDMMYYYY (convert( VARCHAR(50) , a.DataIns, 126)) as DataModifica
		from CTL_Pec_Verify a with(nolock)
				left join LIB_Documents a2 with(nolock) on a2.DOC_ID = a.tipodoc
				inner join aziende b with(nolock) on b.IdAzi = a.idazi or ( a.idazi is null and b.aziE_Mail = a.eMail and aziVenditore = 0 and aziDeleted = 0 )

				left join ProfiliUtente c with(nolock) on c.IdPfu = a.idpfu --se l'idpfu è presente sulla pec verify

				left join ( --se l'idpfu NON è presente sulla pec verify

						select min(idpfu) as idpfu, pfuIdAzi
							from ProfiliUtente with(nolock)
							where pfuDeleted = 0
							group by pfuIdAzi

					) d on d.pfuIdAzi = b.IdAzi

				left join profiliutente e with(nolock) on e.IdPfu = d.idpfu
	
	--Attenzione
	--per l'anagrafica "Ragione Sociale" ( Ente / OE )  è stat o inserito un indirizzo di PEC non valido
	--Indirizzo mail : ( azie_mail )
	--la modifica è stata inserita dall'utente " Nome Cognome" con il documento "Tipo documento"
GO
