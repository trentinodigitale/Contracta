USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_REPORT_QUESTIONARIO_FORNITORE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE VIEW [dbo].[DASHBOARD_VIEW_REPORT_QUESTIONARIO_FORNITORE]  AS

		select 

		a.idrow ,
		a.IdHeader as idmsg,
		a.idazi,
		a.idazi as idazi2,
		iddocforn,
		punteggio as punteggioForn,
		b.aziragionesociale as ragsoc,
		x.body as oggetto,
		y.ArtClasMerceologica ,
		merceologia,
		'BANDO_QF' as OPEN_DOC_NAME ,
		PunteggioGenerale,PunteggioTecnico,DataUltimaValutazione,DataScadenzaAbilitazione,
		DataPrimaValutazione,
		StatoAbilitazione,
		PunteggioMedio,
		PunteggioReqFacolt,
		b.azipartitaiva,
		x.protocollo,
		b.aziindirizzoleg + ' - ' + b.azilocalitaleg as aziindirizzoleg,
		b.azie_mail,
		vatvalore_ft as EMAIL,
		NumeroQuestionariNonConformi,
		DataUltimaComunicazione,
		mercforn,
		x.id as idbando,
		p.idpfu,
		DataScadenzaAbilitazione as DataDa,
		DataScadenzaAbilitazione as DataA



			from Document_Questionario_Fornitore_Punteggi a with (nolock)

				inner join aziende b with (nolock) on a.idazi=b.idazi
				inner join ctl_doc x with (nolock) on x.id=a.IdHeader
				inner join document_bando y with (nolock) on y.idheader=a.IdHeader
				inner join profiliutente p with (nolock) on  p.pfuidazi = x.azienda
				left outer join dm_attributi with (nolock) on idapp=1 and lnk=b.idazi and dztnome='EmailRapLeg'

				inner join (
								select idazi, idHeader , max(idrow) as idrow
									from Document_Questionario_Fornitore_Punteggi with (nolock)
										group by idazi, idHeader
							) vv on vv.IdAzi = a.IdAzi and vv.idHeader = a.idHeader and vv.idrow = a.idrow 

						where x.Deleted = 0











GO
