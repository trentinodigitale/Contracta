USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_BANDO_QF_NOTIFICHE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[MAIL_BANDO_QF_NOTIFICHE]
AS
		SELECT    
				a.idrow  as IdHeader,
				a.idrow as IDDOC, 
				'I' as LNG,
				b.aziRagioneSociale ,
				c.Titolo ,
				c.Body ,
				c.Data ,
				c.Protocollo ,
				c.Fascicolo , 
				isnull(d.Protocollo,'') as ProtocolloIstanza,
				isnull(d.Titolo ,'') as TitoloIstanza,
				case when d.DataInvio IS null then d.Data else d.DataInvio end as DataIstanza
				

				from Document_Questionario_Fornitore_Punteggi a with (nolock) 
					inner join Aziende b with (nolock)  on b.IdAzi = a.IdAzi 
					inner join CTL_DOC c with (nolock) on c.Id=a.idHeader and c.TipoDoc='BANDO_QF' 
					left outer join CTL_DOC d with (nolock) on d.Id=a.IdDocForn  and d.TipoDoc='ISTANZA_AlboOperaEco_QF' 
					--inner join ProfiliUtente P on P.idpfu=CTL_DOC.idpfu
					--inner join dbo.Document_Bando DB on DB.idHeader=ctl_doc.ID
					--left join (select A.APS_NOTE,A.APS_ID_DOC from CTL_APPROVALSteps A, (Select MAX(APS_ID_ROW) as APS_ID_ROW,APS_ID_DOC from CTL_APPROVALSteps where APS_State <> 'Sent' group by APS_ID_DOC )B where A.APS_ID_ROW=B.APS_ID_ROW) C on ctl_doc.ID=C.APS_ID_DOC  
						
						--where 


GO
