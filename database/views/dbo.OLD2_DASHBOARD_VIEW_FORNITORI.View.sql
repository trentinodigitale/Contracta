USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_FORNITORI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--drop view [DASHBOARD_VIEW_FORNITORI]

CREATE VIEW [dbo].[OLD2_DASHBOARD_VIEW_FORNITORI]
AS

SELECT
		A.IdAzi,
		A.aziLog,
		A.aziDataCreazione,
		A.aziRagioneSociale,
		A.aziRagioneSocialeNorm,
		A.aziIdDscFormaSoc,
		A.aziPartitaIVA,
		A.aziE_Mail,
		A.aziAcquirente,
		A.aziVenditore,
		A.aziProspect,
		A.aziIndirizzoLeg,
		A.aziIndirizzoOp,
		A.aziLocalitaLeg,
		A.aziLocalitaOp,
		A.aziProvinciaLeg,
		A.aziProvinciaOp,
		A.aziStatoLeg,
		A.aziStatoOp,
		A.aziCAPLeg,
		A.aziCapOp,
		A.aziPrefisso,
		A.aziTelefono1,
		A.aziTelefono2,
		A.aziFAX,
		A.aziLogo,
		A.aziGphValueOper,
		A.aziDeleted,
		dbo.getAtecoAzi(A.IdAzi) AS aziAtvAtecord,
		A.azisitoWeb,
		A.TipodiAmministr,
		d1.vatValore_FT  as TIPO_AMM_ER,
		d2.vatValore_FT  as aziCodiceFiscale,
		d2.vatValore_FT  as codicefiscale,	 
		case 
			when d4.idVat is null and not d3.idVat is null then '10' -- hanno un participant id ma non hanno un idnotier
			when not d4.idVat is null and not d3.idVat is null then '11'-- hanno un idnotier ed un partecipad_id
			when not d4.idVat is null and d3.idVat is null then '01'-- hanno un idnotier 
			when not d3.idVat is null and d4.idVat is null then '10'-- hanno un participant id 
			--when d3.idVat is null then '00' -- non hanno un participant id
			else '00' -- non ha ndessuno dei due
		end as iscrittoPeppol,
		d3.vatValore_FT  as PARTICIPANTID,
		d4.vatValore_FT  as IDNOTIER,
		case 
			when d5.idVat is null then 0 
			else 1 
		end as aziAnomala,

		case 
			when d6.idVat is null then 0 
			else 1 
		end as aziToDelete,

		--	 , dbo.GetPos(  A.aziLocalitaLeg2 , '-' , 8) as CodiceComune

		case 
			when g.dmv_cod is null then '' 
			else right( '000000' + reverse( dbo.GetPos( reverse(  g.dmv_cod ) , '-' , 1 ) ) , 6 ) 
		end as CodiceComune,

		--	 , left( right( '00000' + dbo.GetPos(  A.aziLocalitaLeg2 , '-' , 8) , 6 ) , 3 ) as CodiceProvincia

		case 
			when g.dmv_cod is null then '' 
			else left( right( '000000' + reverse( dbo.GetPos( reverse(  g.dmv_cod ) , '-' , 1 ) ) , 6 ) , 3 ) 
		end as CodiceProvincia,

		case 
			when pv.Status = 'Elaborated' and pv.isPEC = 0 then 1 
			else 0 
		end as PecNonValida,

		del.Id as ID_AZI_TO_DELETE_VERIFICATO,
		del.DataInvio as AZI_TO_DELETE_VERIFICATO_DATE,
		--, isnull(d7.vatValore_FT, '1900-01-01 00:00:00') as AZI_TO_DELETE_LAST_UPD
		d7.vatValore_FT as AZI_TO_DELETE_LAST_UPD,

		case 
			when del.Id is null then '' 
			else '../Domain/State_OK.gif' 
		end as label1,

		case 
			when h.statoInipec = 'NonPresente' then 'NonPresente'
			when h.statoInipec = 'Presente' and isnull(isCambiato,0) = 1  then 'PresenteVariato'
			when h.statoInipec = 'Presente' and isnull(isCambiato,0) = 0  then 'PresenteNonVariato'
			else ''
		end as statoInipec,

		case
			when isnull(aziPartitaIVA,'') = '' then  1
			else 0
		end as AssenzaPIVA
	FROM Aziende A with(nolock)
		left outer join dbo.DM_Attributi d1 with(nolock) on d1.dztNome = 'TIPO_AMM_ER' and d1.idApp = 1 and d1.lnk = A.idazi
		left outer join dbo.DM_Attributi d2 with(nolock) on d2.dztNome = 'codicefiscale' and d2.idApp = 1 and d2.lnk = A.idazi
		left outer join dbo.DM_Attributi d3 with(nolock) on d3.dztNome = 'PARTICIPANTID' and d3.idApp = 1 and d3.lnk = A.idazi and isnull(d3.vatValore_FT,'') <> ''
		left outer join dbo.DM_Attributi d4 with(nolock) on d4.dztNome = 'IDNOTIER' and d4.idApp = 1 and d4.lnk = A.idazi and isnull(d4.vatValore_FT,'') <> ''
		left outer join dbo.DM_Attributi d5 with(nolock) on d5.dztNome = 'AZI_ANOMALA' and d5.idApp = 1 and d5.lnk = A.idazi and isnull(d5.vatValore_FT,'') <> ''
		left outer join dbo.DM_Attributi d6 with(nolock) on d6.dztNome = 'AZI_TO_DELETED' and d6.idApp = 1 and d6.lnk = A.idazi and isnull(d6.vatValore_FT,'') <> ''
		left outer join lib_domainvalues g  with(nolock) on g.dmv_dm_id = 'GEO' and g.dmv_cod = A.aziLocalitaLeg2  and g.dmv_level = 7 and right( g.dmv_cod , 3 ) <> 'xxx'
		--left join GEO_ISTAT_ripartizioni_regioni_province RP with(nolock)  on  RP.CodiceNUTS3_2010 = dbo.GetPos(  A.aziLocalitaLeg2 , '-' , 7)
		left join CTL_Pec_Verify pv         with(nolock) on pv.eMail = a.aziE_Mail
		left join (select max(id) as id, max(DataInvio) as DataInvio, Azienda 
				       from CTL_DOC         with(nolock) 
					   where TipoDoc = 'AZI_TO_DELETE_VERIFICATO' and StatoFunzionale = 'Confermato' and Deleted = 0 
					   group by Azienda) as del on del.azienda = a.IdAzi
		left outer join dbo.DM_Attributi d7 with(nolock) on d7.dztNome = 'AZI_TO_DELETE_LAST_UPD ' and d7.idApp = 1 and d7.lnk = A.idazi and isnull(d7.vatValore_FT,'') <> ''
		left join Document_INIPEC h         with(nolock) on a.IdAzi = h.idAzi and h.idHeader = 0
	WHERE 
		A.azivenditore > 0
		--escludo le aziende che sono RTI create dal sistema a fronte di una offerta
		and aziiddscformasoc <> 845326
		--and a.idazi not in (
		--		 select  value from 
		--			ctl_doc_value with(nolock) inner join ctl_doc with(nolock) on id=idheader and tipodoc='OFFERTA_PARTECIPANTI' 
		--				where dse_id='TESTATA' and dzt_name='IdAziRTI' and isnull(value,'')<>'' and statofunzionale='pubblicato'
		--		 )

GO
