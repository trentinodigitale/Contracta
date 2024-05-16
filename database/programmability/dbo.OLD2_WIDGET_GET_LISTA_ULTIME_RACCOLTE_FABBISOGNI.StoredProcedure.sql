USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_WIDGET_GET_LISTA_ULTIME_RACCOLTE_FABBISOGNI]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--WIDGET_FUNZIONE  ( widget è un costante, funzione è il nome funzionale del widget ). non mettere mai in transazione !
--exec WIDGET_GET_LISTA_ULTIME_RACCOLTE_FABBISOGNI 12, '', 1, ''
CREATE PROC [dbo].[OLD2_WIDGET_GET_LISTA_ULTIME_RACCOLTE_FABBISOGNI] 
(
	@idpfu      INT,
	@CallerType VARCHAR(500),
	@WidgetType INT,
	@Command VARCHAR(500),
	@suffix VARCHAR(50) = '',
	@Context VARCHAR(500) = ''
)
AS
    -- ex: exec [WIDGET_GET_NUMBERS_OE] 1, 'WEBAPI',  0, 'INIT'
    SET nocount ON

    DECLARE @strCause NVARCHAR(500)

  BEGIN try
		
      CREATE TABLE #lista1
        (
           [text]      NVARCHAR(max),
           [subText]   NVARCHAR(max),
           [rightText] NVARCHAR(max),
           [action]    NVARCHAR(max)
        )

      INSERT INTO #lista1
		SELECT DISTINCT totals.titolo													AS [text],
			'Stato: ' + totals.statofunzionale + ' - '
			+ 'Protocollo: ' + totals.protocollo										AS [subText],
			totals.datainvio															AS [rightText],
			'ShowDocument(' + '''BANDO_FABBISOGNI'',' + Convert(varchar(10), id) + ')'	AS [action]

			FROM   (SELECT id,
						   C.idpfu,
						   tipodoc,
						   statodoc,
						   data,
						   protocollo,
						   deleted,
						   titolo,
						   datainvio,
						   Cast(body AS NVARCHAR(4000)) AS Oggetto,
						   C.idpfu                      AS OWNER,
						   B.datapresentazionerisposte  AS DataRiferimentoFine,
						   C.statofunzionale,
						   -- (select count(*) from ctl_doc_destinatari where idheader=id ) as NumeroPartecipanti,
						   --(select count(*) from ctl_doc_destinatari where idheader=id and StatoIscrizione='Completato') as NumeroRisposte
						   Isnull(CV.value, 0)          AS NumeroPartecipanti,
						   Isnull(B.recivedistanze, 0)  AS NumeroRisposte,
						   tipodoc                      AS OPEN_DOC_NAME
					FROM   ctl_doc C
						   LEFT JOIN document_bando B
								  ON B.idheader = C.id
						   LEFT JOIN document_bando_riferimenti R
								  ON R.idheader = C.id
						   LEFT OUTER JOIN ctl_doc_value CV
										ON CV.idheader = C.id
										   AND dse_id = 'NUMERO_PARTECIPANTI'
										   AND dzt_name = 'NUMEROPARTECIPANTI'
					WHERE  tipodoc = 'BANDO_FABBISOGNI'
						   AND deleted = 0
					UNION
					SELECT id,
						   C.idpfu,
						   tipodoc,
						   statodoc,
						   data,
						   protocollo,
						   deleted,
						   titolo,
						   datainvio,
						   Cast(body AS NVARCHAR(4000)) AS Oggetto,
						   R.idpfu                      AS OWNER,
						   B.datapresentazionerisposte  AS DataRiferimentoFine,
						   C.statofunzionale,
						   -- (select count(*) from ctl_doc_destinatari where idheader=id ) as NumeroPartecipanti,
						   --(select count(*) from ctl_doc_destinatari where idheader=id and StatoIscrizione='Completato') as NumeroRisposte
						   Isnull(CV.value, 0)          AS NumeroPartecipanti,
						   Isnull(B.recivedistanze, 0)  AS NumeroRisposte,
						   tipodoc                      AS OPEN_DOC_NAME
					FROM   ctl_doc C
						   LEFT JOIN document_bando B
								  ON B.idheader = C.id
						   LEFT JOIN document_bando_riferimenti R
								  ON R.idheader = C.id
						   LEFT OUTER JOIN ctl_doc_value CV
										ON CV.idheader = C.id
										   AND dse_id = 'NUMERO_PARTECIPANTI'
										   AND dzt_name = 'NUMEROPARTECIPANTI'
					WHERE  tipodoc = 'BANDO_FABBISOGNI'
						   AND deleted = 0
					UNION
					SELECT id,
						   C.idpfu,
						   tipodoc,
						   statodoc,
						   data,
						   protocollo,
						   deleted,
						   titolo,
						   datainvio,
						   Cast(body AS NVARCHAR(4000)) AS Oggetto,
						   C.idpfuincharge              AS OWNER,
						   B.datapresentazionerisposte  AS DataRiferimentoFine,
						   C.statofunzionale,
						   -- (select count(*) from ctl_doc_destinatari where idheader=id ) as NumeroPartecipanti,
						   --(select count(*) from ctl_doc_destinatari where idheader=id and StatoIscrizione='Completato') as NumeroRisposte
						   Isnull(CV.value, 0)          AS NumeroPartecipanti,
						   Isnull(B.recivedistanze, 0)  AS NumeroRisposte,
						   tipodoc                      AS OPEN_DOC_NAME
					FROM   ctl_doc C
						   LEFT JOIN document_bando B
								  ON B.idheader = C.id
						   LEFT JOIN document_bando_riferimenti R
								  ON R.idheader = C.id
						   LEFT OUTER JOIN ctl_doc_value CV
										ON CV.idheader = C.id
										   AND dse_id = 'NUMERO_PARTECIPANTI'
										   AND dzt_name = 'NUMEROPARTECIPANTI'
					WHERE  tipodoc = 'BANDO_FABBISOGNI'
						   AND deleted = 0) AS totals
			WHERE  totals.statofunzionale = 'Inviato' or totals.StatoFunzionale = 'Completato'
			order by [rightText] desc


      SELECT * FROM   #lista1 

	  DROP TABLE #lista1

  END try

  BEGIN catch
      DECLARE @ErrorMessage NVARCHAR(max)
      DECLARE @ErrorSeverity INT
      DECLARE @ErrorState INT

      SET @ErrorMessage = @strCause + ' - ' + Error_message()
      SET @ErrorSeverity = Error_severity()
      SET @ErrorState = Error_state()

      RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)
  END catch


GO
