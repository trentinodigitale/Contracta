USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_PREGARA_HISTORY]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



 
CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_PREGARA_HISTORY]  AS

--DOCUMENTO DOVE SONO COMPILATORE
select 
	C.id,
	C.idpfu,
	C.Titolo,
	cast ( C.body as nvarchar(max)) as body,
	C.StatoFunzionale,
	C.DataInvio,
	C.Protocollo,
	idpfu as owner--,
	--data as APS_Date
	,TipoAppaltoGara
	from ctl_doc C  with(nolock)	
		inner join Document_Bando with(nolock) on idHeader=id	
	where C.TipoDoc='PREGARA' and C.Deleted=0

UNION
--DOCUMENTO DOVE HO IN CHARGE IL DOCUMENTO
select 
	C.id,
	C.idpfu,
	C.Titolo,
	cast ( C.body as nvarchar(max)) as body,
	C.StatoFunzionale,
	C.DataInvio,
	C.Protocollo,
	idPfuInCharge as owner--,
	--data as APS_Date
	,TipoAppaltoGara
		from ctl_doc C  with(nolock)		
			inner join Document_Bando with(nolock) on idHeader=id
	where C.TipoDoc='PREGARA' and C.Deleted=0
UNION 
--relativi alla ciclo di approvazione dove l'utente figura in uno dei passi 
select 
	C.id,
	C.idpfu,
	C.Titolo,
	cast ( C.body as nvarchar(max)) as body,
	C.StatoFunzionale,
	C.DataInvio,
	C.Protocollo,
	APS_IdPfu as owner--,
	--APS_Date
	,TipoAppaltoGara
		from ctl_doc C  with(nolock)		
			inner join Document_Bando with(nolock) on idHeader=id
			inner join CTL_ApprovalSteps CA with(nolock) on CA.APS_ID_DOC=C.Id and CA.APS_Doc_Type=C.TipoDoc and CA.APS_IdPfu <> ''
	where C.TipoDoc='PREGARA' and C.Deleted=0

UNION
--Nella cartella "Di competenza" aggiungiamo la visibilità ai RUP PROPONENTI 
select 
	C.id,
	C.idpfu,
	C.Titolo,
	cast ( C.body as nvarchar(max)) as body,
	C.StatoFunzionale,
	C.DataInvio,
	C.Protocollo,
	RupProponente as owner--,
	--data as APS_Date
	,TipoAppaltoGara
		from ctl_doc C  with(nolock)		
			inner join Document_Bando with(nolock) on idHeader=id
	where C.TipoDoc='PREGARA' and C.Deleted=0
GO
