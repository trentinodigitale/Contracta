USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_BANDO_TEST_PCP_CRONOLOGIA_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD_BANDO_TEST_PCP_CRONOLOGIA_VIEW] as

	select	
		idRow as idRow,
		idRichiesta as idRichiesta,
		operazioneRichiesta as TipoDoc,
		statoRichiesta as Protocollo,
		dateIn as Data,
		DataExecuted as DataInvio,
		msgError as Titolo,

		inputWS as Name,
		outputWS as StatoFunzionale,

		CASE 
        WHEN CHARINDEX('@@@', datoRichiesto) > 0 THEN 
            SUBSTRING(datoRichiesto, 1, CHARINDEX('@@@', datoRichiesto) - 1)
        ELSE 
            ''
		END as TipoScheda
	from Services_Integration_Request with (nolock)
		where integrazione in ( 'PCP' ,  'INTEROPERABILITA' )
		and operazioneRichiesta != 'recuperaCDC'

	UNION ALL 	--aggiungo la cronologia sugli avvisi legati agli inviti (avviso negoziata / bando ristretta)

	select	
		I.idRow as idRow,
		G.id as idRichiesta,
		operazioneRichiesta as TipoDoc,
		statoRichiesta as Protocollo,
		dateIn as Data,
		DataExecuted as DataInvio,
		msgError as Titolo,
		
		inputWS as Name,
		outputWS as StatoFunzionale,

		CASE 
        WHEN CHARINDEX('@@@', datoRichiesto) > 0 THEN 
            SUBSTRING(datoRichiesto, 1, CHARINDEX('@@@', datoRichiesto) - 1)
        ELSE 
            ''
		END as TipoScheda
	from 
		--inviti
		ctl_doc G  with (nolock)
			inner join document_bando DG with (nolock) on DG.idheader = G.id
			--legati ad avvisi
			inner join ctl_doc AB with (nolock) on AB.id = G.linkeddoc and Ab.TipoDoc=G.tipodoc
			inner join document_bando DAB with (nolock) on DAB.idheader = AB.id
			--prendo le richieste legate all'avviso
			inner join Services_Integration_Request I with (nolock) on idrichiesta = AB.id
	where
		G.tipodoc='BANDO_GARA' and DG.TipoBandoGara='3'  and ( 
									( DAB.proceduragara = '15478' and DAB.TipoBandoGara ='1') 
									or
									( DAB.proceduragara = '15477' and DAB.TipoBandoGara ='2')
								)
		 
		
		and  integrazione in ( 'PCP' ,  'INTEROPERABILITA' )
		and operazioneRichiesta != 'recuperaCDC'
GO
