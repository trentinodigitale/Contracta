USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_ELENCO_PUBBLICITA_LEGALE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[DASHBOARD_VIEW_ELENCO_PUBBLICITA_LEGALE] AS

select 
		C.id,
		C.idpfu,
		C.Titolo,
		C.TipoDoc,
		C.Data,
		C.datainvio,
		C.idPfuInCharge,
		C.StatoFunzionale,
		C.Protocollo,
		cast (C.Body as nvarchar(max)) as Body,
		C.StatoDoc,
		P.idpfu as owner,
		--TipoAppaltoGara
		--,ProtocolloBando
		Pratica,
		Tipologia,
		JumpCheck as Guri_Quotidiani,
		protocol
	from ctl_doc C  with(nolock)
		--inner join Document_Bando with(nolock) on idHeader=id
		inner join ProfiliUtente P with(nolock) on P.pfuIdAzi=C.Azienda and pfuDeleted=0
		LEFT JOIN Document_RicPrevPubblic With(nolock) ON C.ID=Document_RicPrevPubblic.idheader
	where C.TipoDoc='PUBBLICITA_LEGALE' and C.StatoFunzionale <> 'InLavorazione' and C.Deleted=0

--UNION

--select 
--		C.id,
--		C.idpfu,
--		C.Titolo,
--		C.TipoDoc,
--		C.Data,
--		C.datainvio,
--		C.idPfuInCharge,
--		C.StatoFunzionale,
--		C.Protocollo,
--		cast (C.Body as nvarchar(max)) as Body,
--		C.StatoDoc,
--		P.idpfu as owner,	
--		--TipoAppaltoGara
--		--,ProtocolloBando
--		Pratica,
--		Tipologia,
--		JumpCheck as Guri_Quotidiani
--	from ctl_doc C  with(nolock)
--		--inner join Document_Bando with(nolock) on idHeader=id
--		inner join ProfiliUtente P with(nolock) on cast(P.pfuIdAzi as varchar(50)) + '#\0000\0000'=cast(c.Azienda as varchar (50))+'#\0000\0000' and pfuDeleted=0
--		LEFT JOIN Document_RicPrevPubblic With(nolock) ON C.ID=Document_RicPrevPubblic.idheader
--	where C.TipoDoc='PUBBLICITA_LEGALE' and C.StatoFunzionale <> 'InLavorazione' and C.Deleted=0






GO
