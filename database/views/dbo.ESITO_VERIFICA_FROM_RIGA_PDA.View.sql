USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ESITO_VERIFICA_FROM_RIGA_PDA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create view [dbo].[ESITO_VERIFICA_FROM_RIGA_PDA] as
select idRow as ID_FROM , o.idMsg as IdDoc, /*'ESITO_ESCLUSA' as TipoDoc,*/  /*p.pfuidazi*/ idAziPArtecipante as Azienda
					 ,  Fascicolo , idRow as LinkedDoc --, 'InLavorazione' as StatoFunzionale
			--,dbo.getLottiSenzaCampioni(idRow) as Body
			,o.idheader as idPda
			from Document_PDA_OFFERTE o
				inner join ctl_doc b on o.idheader = b.id
--					left outer join TAB_MESSAGGI_FIELDS  m on m.IdMsg = o.IdMsg
--					left outer join profiliutente p on m.idMittente = p.idpfu
--WHERE IDHEADER =5681



GO
