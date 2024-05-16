USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_MONITORAGGIO_PROCEDIMENTI]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_MONITORAGGIO_PROCEDIMENTI]  AS
select 
			 P.IdPfu as Owner
			, ROW_NUMBER() over (partition by P.idpfu order by Richiesta.datainvio asc) as NumeroRiga		
			, Richiesta.id as id
			, RICHIESTA.TipoDoc 
			, RICHIESTA.ProtocolloGenerale
			, RICHIESTA.DataProtocolloGenerale
			, BANDO.Body as Oggetto
			, aziRagioneSociale
			, RISCONTRO.ProtocolloGenerale as ProtocolloRiferimento
			, RISCONTRO.DataProtocolloGenerale as Dataprot
			, Z.DataInvio as DataComunicazione
			, '' as UserRup
			, CV.Value as Utente
			, case 
				when DATEDIFF(day,RICHIESTA.DataProtocolloGenerale,RISCONTRO.DataProtocolloGenerale) > 30 then 'si'
				else 'no'
			   end as Differimento_Si_No							
			, '' as Motivo
			, '' as Risposta
			, '' as Nota
			,RICHIESTA.StatoDoc	 
			,convert( varchar(10) , RICHIESTA.DataProtocolloGenerale , 121 )   as DataDA 
			,convert( varchar(10) , RICHIESTA.DataProtocolloGenerale , 121 )   as DataA 
		  
	from CTL_DOC RICHIESTA with(nolock)
			inner join Document_Richiesta_Atti with(nolock)  on id = idHeader
			--hanno chiesto di accorpare le righe per richiesta, attualmente si ottiene il prodotto cartesiano con le risposte.Vogliono avere i dati solo dell'ultima risposta
			left join ( Select MAX(id) as IDRISCONTRO ,LinkedDoc from CTL_DOC with(nolock) where TipoDoc='INVIO_ATTI_GARA' and deleted=0 group by LinkedDoc ) as MAXRISCONTRO on RICHIESTA.Id=MAXRISCONTRO.LinkedDoc	
			left join CTL_DOC RISCONTRO with(nolock) on RISCONTRO.Id=MAXRISCONTRO.IDRISCONTRO
			---filtro per consentire la visualizzazione agli utenti di tutte le richieste di accesso agli atti della stessa P.A del BANDO 
			inner join ctl_doc BANDO with(nolock) on BANDO.Id=RICHIESTA.LinkedDoc
			inner join ProfiliUtente P with(nolock) on P.pfuIdAzi=BANDO.Azienda and P.pfuDeleted=0
			--RECUPERO IL RUP DEL BANDO
			inner join CTL_DOC_Value CV with(nolock) on CV.idHeader=BANDO.id and DZT_Name='UserRup' and DSE_ID='InfoTec_comune'			
			--RECUPERO LA PRIMA DATA DELLA COMUNICAZIONE DI AGGIUDICAZIONE DEFINITIVA
			left join ctl_doc PDA with(nolock) on BANDO.Id=PDA.LinkedDoc and PDA.Deleted=0 and PDA.TipoDoc='PDA_MICROLOTTI'		
			left join ( select MIN(COM.datainvio) as datainvio ,COM.linkeddoc 
								from CTL_DOC COM  with(nolock) 
									where  COM.TipoDoc='PDA_COMUNICAZIONE_GENERICA' and LEFT(COM.JumpCheck,18)='0-ESITO_DEFINITIVO' 
											and COM.StatoFunzionale='Inviato' 
						group by com.LinkedDoc
					   ) 
					   as Z on Z.LinkedDoc=PDA.Id
	WHERE RICHIESTA.StatoDoc <> 'Saved' and 
	RICHIESTA.tiPodoc = 'RICHIESTA_ATTI_GARA'

GO
