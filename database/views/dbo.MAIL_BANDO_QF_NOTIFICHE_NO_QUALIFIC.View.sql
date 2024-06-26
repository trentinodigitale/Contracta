USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_BANDO_QF_NOTIFICHE_NO_QUALIFIC]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




create VIEW [dbo].[MAIL_BANDO_QF_NOTIFICHE_NO_QUALIFIC]
AS
		SELECT    
				a.idazi  as IdHeader,
				a.idazi as IDDOC, 
				'I' as LNG,
				a.aziRagioneSociale ,
				c.Titolo ,
				c.Body ,
				c.Data ,
				c.Protocollo ,
				c.Fascicolo , 
				isnull(d.Protocollo,'') as ProtocolloIstanza,
				isnull(d.Titolo ,'') as TitoloIstanza,
				case when d.DataInvio IS null then d.Data else d.DataInvio end as DataIstanza
				

				from Aziende a with (nolock) 
					
					
					inner join CTL_DOC d with (nolock) on d.Azienda=a.idazi  and d.TipoDoc='ISTANZA_AlboOperaEco_QF' 
															and d.Deleted = 0 and  StatoFunzionale = 'Inviato'
					inner join CTL_DOC c with (nolock) on c.Id=d.LinkedDoc and c.TipoDoc='BANDO_QF' 
					left outer join Document_Questionario_Fornitore_Punteggi with (nolock) on d.LinkedDoc=idHeader and d.Azienda=a.idazi
					--inner join ProfiliUtente P on P.idpfu=CTL_DOC.idpfu
					--inner join dbo.Document_Bando DB on DB.idHeader=ctl_doc.ID
					--left join (select A.APS_NOTE,A.APS_ID_DOC from CTL_APPROVALSteps A, (Select MAX(APS_ID_ROW) as APS_ID_ROW,APS_ID_DOC from CTL_APPROVALSteps where APS_State <> 'Sent' group by APS_ID_DOC )B where A.APS_ID_ROW=B.APS_ID_ROW) C on ctl_doc.ID=C.APS_ID_DOC  
						
						where idrow is null


GO
