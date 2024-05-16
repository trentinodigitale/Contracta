USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_COM_DPE]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[OLD2_DASHBOARD_VIEW_COM_DPE]
AS
SELECT 
	IdCom
	, Name
	, Owner
	, DataCreazione
	, Protocollo
	, StatoCom
	, Obbligo
	, DataObbligo
	, pfuNome	
	, TipologiaAllegati
	, BloccoAccesso
	, DataScadenzaCom
	, Notacom
	, TipoComDPE
	, c.Deleted
	, IsPublic
	, RichiestaRisposta
	, DataScadenza
	, Richiesta_del_Prec
	, TipoDestinatarioMail
	, RichiestaProtocollo
	, case
		when DZT_Name IS not null and DOCER.id IS not null then 'si'
		else 'no'
		end as  ProtocolloAttivo
	FROM 
		Document_Com_DPE c with (nolock)
			inner join ProfiliUtente with (nolock) on Owner = IdPfu
			inner join aziende with (nolock) on pfuIdAzi = idazi and aziacquirente<>0
			left join lib_dictionary with (nolock) on  dzt_name = 'SYS_ATTIVA_PROTOCOLLO_GENERALE' and dzt_valuedef = 'YES'
			left join Document_protocollo_docER DOCER with (nolock)
											on tipoDoc= case 
															when isnull(TipoComDPE,'OE') ='OE' then 'COM_DPE_FORNITORE' 
															when isnull(TipoComDPE,'OE') ='ENTI' then 'COM_DPE_ENTE' 
														end 
												and aoo = dbo.getAOO( IdPfu ) and attivo=1
	WHERE  c.Deleted = 0
   



GO
