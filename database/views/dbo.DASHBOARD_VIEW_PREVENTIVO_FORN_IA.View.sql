USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_PREVENTIVO_FORN_IA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE  view [dbo].[DASHBOARD_VIEW_PREVENTIVO_FORN_IA] as
select 
			--u.idpfu as idDestinatario 
			 c.NumOrd as NumeroConvenzione 
			,p.Id
			,p.IdPfu
			,p.TipoDoc
			,p.StatoDoc
			,p.Data
			,p.Protocollo
			,p.Titolo
			,p.StrutturaAziendale
			,p.StrutturaAziendale as ODC_PEG
			,p.DataInvio
			,DOC_Name
			,o.LinkedDoc as Convenzione
			,p.StatoFunzionale
			,p. Destinatario_User
		from CTL_DOC p 
			inner join CTL_DOC o on o.id = p.LinkedDoc
			inner join Document_Convenzione c on c.ID = o.LinkedDoc
		 where p.TipoDoc = 'PREVENTIVO_FORN' and p.deleted = 0
			and p.StatoDoc <> 'Saved'


GO
