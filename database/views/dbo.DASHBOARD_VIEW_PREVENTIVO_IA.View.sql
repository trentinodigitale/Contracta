USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_PREVENTIVO_IA]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  view [dbo].[DASHBOARD_VIEW_PREVENTIVO_IA] as
select 
           
           --l.DOC_NAME
			u.idpfu as idDestinatario 
			,case when l.DOC_NAME is not null then '0' else '1'end as bRead 
			, c.NumOrd as NumeroConvenzione 
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
			,c.DOC_Name
			,c.ID as Convenzione
			,p.StatoFunzionale
			
		from CTL_DOC p
			--inner join 
			,Document_Convenzione c --on c.ID = p.LinkedDoc
			--inner join 
			,profiliutente  u --on Azi_Dest = pfuidazi 
			--,CTL_DOC_READ l
		left outer join CTL_DOC_READ as l on u.idpfu=l.idpfu  and id=l.id_Doc and 'PREVENTIVO_IA'=l.DOC_NAME	
		 where TipoDoc = 'PREVENTIVO' and p.deleted = 0
			and StatoDoc <> 'Saved'
			and c.ID = p.LinkedDoc
			and Azi_Dest = pfuidazi


GO
