USE [AFLink_TND]
GO
/****** Object:  View [dbo].[view_Document_Chiarimenti_portale]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[view_Document_Chiarimenti_portale] as
	
	select a.id
			, a.[ID_ORIGIN]
			, a.[DataCreazione]
			, dbo.normStringInvisibleASCIIChars( a.[Domanda] ) as Domanda
			, dbo.normStringInvisibleASCIIChars( a.[Risposta] ) as Risposta
			, a.[Allegato]
			, a.[UtenteDomanda]
			, a.[UtenteRisposta]
			, a.[DataUltimaMod]
			, a.[Stato]
			, a.[ChiarimentoPubblico]
			, a.[aziragionesociale]
			, a.[azitelefono1]
			, a.[azifax]
			, a.[azie_mail]
			, a.[Protocol]
			, a.[ChiarimentoEvaso]
			, a.[Notificato]
			, a.[DataRisposta]
			, a.[ProtocolRispostaQuesito]
			, a.[Fascicolo]
			, a.[Document]
			, dbo.normStringInvisibleASCIIChars( a.[DomandaOriginale] ) as DomandaOriginale
			, a.[ProtocolloGenerale]
			, a.[DataProtocolloGenerale]
			, a.[StatoFunzionale]
			, a.[idPfuInCharge]
			, a.[ProtocolloGeneraleIN]
			, a.[DataProtocolloGeneraleIN]
			, a.[Pubblicazione_auto_Richiesta]
			, convert( VARCHAR(50) , a.DataRisposta, 126 ) as DataRispostaTecnical,
			dbo.UrlEncode ( Allegato) as Allegato_Encoded

		from Document_Chiarimenti a with(nolock)
				
				left join ctl_parametri  P with(nolock) on P.Contesto='PORTALE_PUBBLICO' and P.Oggetto='Quesiti_Inviti' 
				left join ctl_parametri  PAS with(nolock) on PAS.Contesto='PORTALE_PUBBLICO' and PAS.Oggetto='Appalto_Specifico' and PAS.Proprieta = 'HIDE' 

				-- la procedura collegata al chiarimento NON deve essere ad invito per mostrare i feed in un contesto di portale
				left join TAB_MESSAGGI_FIELDS t with(nolock) on a.Document is null and t.IdMsg = a.ID_ORIGIN and 
																			( 
																				( t.TipoBando <> '3' and (P.Valore='1' or P.Id is null ) )
																				or
																				P.Valore='0'
																			)
				
				left join Document_Bando b with(nolock) on a.Document is not null and b.idHeader= a.ID_ORIGIN and 
																			(
																				( ISNULL(b.TipoBandoGara,'') <> '3' and (P.Valore='1' or P.Id is null ))
																				or
																				P.Valore='0'
																				or 
																				-- visualizzo 
																				( a.document = 'BANDO_SEMPLIFICATO' and PAS.Valore = '0' )
																			)

		where a.ChiarimentoPubblico = 1 and rtrim(rtrim(isnull(a.risposta,''))) <> '' and rtrim(rtrim(isnull(a.Domanda,''))) <> '' and ( t.IdMsg is not null OR b.idRow is not null )
			
			


GO
