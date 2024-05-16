USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_view_Document_Chiarimenti_portale]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD2_view_Document_Chiarimenti_portale] as
	
	select 
		a.*, 
		convert( VARCHAR(50) , a.DataRisposta, 126 ) as DataRispostaTecnical,
		dbo.UrlEncode ( Allegato) as Allegato_Encoded

		from Document_Chiarimenti a with(nolock)
				
				left join ctl_parametri  P with(nolock) on P.Contesto='PORTALE_PUBBLICO' and P.Oggetto='Quesiti_Inviti' 

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
																							)

		where 
			a.ChiarimentoPubblico = 1 and rtrim(rtrim(isnull(a.risposta,''))) <> '' and rtrim(rtrim(isnull(a.Domanda,''))) <> '' and ( t.IdMsg is not null OR b.idRow is not null )
			
			



GO
