USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_Document_Com_DPE_Fornitori_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_Document_Com_DPE_Fornitori_VIEW]
AS
select 
	d.*
	, 'COM_DPE_RISPOSTA' as FornitoriGrid_OPEN_DOC_NAME
	--,null as FornitoriGrid_ID_DOC
	, a.azipartitaiva
	,case when isnull(FornitoriGrid_ID_DOC,0) > 0 then '1' else '' end as OpenDettaglio
 from Document_Com_DPE_Fornitori d with (nolock)
	inner join aziende A with (nolock) on a.idazi = d.idazi
	inner join Document_Com_DPE e with (nolock) on e.idCom=d.idCom
	--left outer join (select id from CTL_DOC a where a.linkeddoc = e.idCom and tipodoc = 'COM_DPE_RISPOSTA' and statodoc = 'Sended') 
where d.idcom=e.idcom and (IsPublic=0 or (IsPublic=1 and StatoComFor='Accettato'))
	
GO
