USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_BANDO_SDA_IN_APPROVE]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[OLD2_DASHBOARD_VIEW_BANDO_SDA_IN_APPROVE] as
select 
	tipoDoc + '_IN_APPROVE' as OPEN_DOC_NAME,
	id,
	d.idpfu ,
	iddoc,
	case when isnull( APS_IdPfu , '' ) = '' 
			then a.idpfu
			else cast( APS_IdPfu as int ) 
		end as InCharge,
	TipoDoc,
	StatoDoc,
	TipoBando,
	Data,
	Protocollo,
	PrevDoc,
	Deleted,
	cast(Body as nvarchar(4000)) as Titolo,
	Body,
	Azienda,
	StrutturaAziendale,
	DataInvio,
	DataScadenza,
	ProtocolloGenerale,
	Fascicolo,
	Note,
	DataProtocolloGenerale,
	LinkedDoc,
	StatoFunzionale,
	Destinatario_User,
	Destinatario_Azi ,
	RecivedIstanze , 
	DB.ProtocolloBando

from CTL_DOC  d 
	inner join dbo.Document_Bando DB on id = DB.idheader
--inner join Document_Bando_Commissione DC on DC.idHEader=id
	inner join CTL_ApprovalSteps s on tipodoc = APS_Doc_Type and APS_State = 'InCharge' and APS_ID_DOC = d.id and APS_IsOld=0
	
	-- recupero l'utente dal ruolo solamente se non è indicato in modo specifico 
	left outer join profiliutenteattrib a on isnull( APS_IdPfu , '' ) = '' and dztNome = 'UserRole' and APS_UserProfile = attValue

where deleted = 0 and TipoDoc in ( 'BANDO_SDA' , 'BANDO_SEMPLIFICATO','REVOCA_BANDO' )



--union all


--select 
--	d.tipoDoc + '_IN_APPROVE' as OPEN_DOC_NAME,
--	d.id,
--	d.idpfu ,
--	d.iddoc,
--	case when isnull( APS_IdPfu , '' ) = '' 
--			then a.idpfu
--			else cast( APS_IdPfu as int ) 
--		end as InCharge,
--	d.TipoDoc,
--	d.StatoDoc,
--	TipoBando,
--	d.Data,
--	d.Protocollo,
--	d.PrevDoc,
--	d.Deleted,
--	d.Titolo,
--	d.Body,
--	d.Azienda,
--	d.StrutturaAziendale,
--	d.DataInvio,
--	d.DataScadenza,
--	d.ProtocolloGenerale,
--	d2.Fascicolo,
--	d.Note,
--	d.DataProtocolloGenerale,
--	d.LinkedDoc,
--	d.StatoFunzionale,
--	d.Destinatario_User,
--	d.Destinatario_Azi ,
--	RecivedIstanze , 
--	DB.ProtocolloBando

--from CTL_DOC  d     
    
--    inner join CTL_DOC d2 on d.linkeddoc=d2.id
--	inner join dbo.Document_Bando DB on d.LinkedDoc = DB.idheader
--    inner join CTL_ApprovalSteps s on d.tipodoc = APS_Doc_Type and APS_State = 'InCharge' and APS_ID_DOC = d.id
--	-- recupero l'utente dal ruolo solamente se non è indicato in modo specifico 
--	left outer join profiliutenteattrib a on isnull( APS_IdPfu , '' ) = '' and dztNome = 'UserRole' and APS_UserProfile = attValue

--where d.deleted = 0 and d.TipoDoc in ( 'REVOCA_BANDO')




GO
