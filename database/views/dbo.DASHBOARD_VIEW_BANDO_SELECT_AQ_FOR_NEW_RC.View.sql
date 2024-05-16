USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_BANDO_SELECT_AQ_FOR_NEW_RC]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[DASHBOARD_VIEW_BANDO_SELECT_AQ_FOR_NEW_RC] as 


	--select d.Id as ID_FROM , p.idpfu as idPfu_aderente, d.* ,s.*

	--	from CTL_DOC  d  with(nolock) 
	--			inner join dbo.Document_Bando s  with(nolock) on id = idheader
	--			left outer join CTL_DOC_Value b  with(nolock) on b.IdHeader = d.id and DSE_ID = 'ENTI' and DZT_Name = 'AZI_Ente' 
	--			inner join aziende a on ( b.Value = a.idazi ) or ( a.aziAcquirente > 0 and b.value is null )
	--			inner join profiliutente p  with(nolock) on  a.IdAzi = p.pfuidazi 
	--			inner join CTL_DOC PDA with(nolock) on d.id = PDA.LinkedDoc and PDA.TipoDoc = 'PDA_MICROLOTTI' and PDA.deleted = 0 
	--			inner join ( select distinct idheader from Document_MicroLotti_Dettagli with(nolock) where TipoDoc = 'PDA_MICROLOTTI'  and Voce = 0 and StatoRiga = 'AggiudicazioneDef' ) PL on PL.idheader=PDA.id
	--	where d.deleted = 0 and d.TipoDoc in ( 'BANDO_GARA' ) and TipoSceltaContraente = 'ACCORDOQUADRO'
	--			and d.statoFunzionale in ( 'InAggiudicazione' , 'InEsame' , 'Pubblicato' )
	--			and getDate() <= isnull( s.DataRiferimentoFine , getdate())
	--			and TipoAccordoQuadro = 'multiround'


	

	--vengono visualizzati tutti gli AQ che:
	--  0) Dove sono abilitato personalmente ( idpfu AQ_ABILITAZIONE_RILANCIO )
	--	1) Sono Attivati (  presente il documento  ATTIVA_AQ. Confermato ), 
	--	2) che non sono scaduti 
	--	3) O ( è senza quote e sono negli enti aderenti ) O ( è senza quote e senza enti aderenti ) O ( Quote Richieste non scaduta) 


	--TIRA FUORI AQ senza quote e sono negli enti aderenti e rispetta 0) 1) 2)
	select d.Id as ID_FROM , P.idpfu as idPfu_aderente,d.Protocollo,cast(d.body as nvarchar(max)) as body, s.DataRiferimentoFine as  DataScadenza,d.Data
	-- d.* ,s.*

		from CTL_DOC  d  with(nolock) 
				inner join dbo.Document_Bando s  with(nolock) on id = idheader and s.GestioneQuote = 'senzaquote'
				inner join CTL_DOC_Value CV with(nolock) on CV.IdHeader=S.idHeader and CV.DSE_ID='ENTI' and CV.DZT_Name='AZI_Ente'
				inner join ProfiliUtente P with(nolock) on P.pfuIdAzi=CV.Value				
				inner join CTL_DOC PDA with(nolock) on d.id = PDA.LinkedDoc and PDA.TipoDoc = 'PDA_MICROLOTTI' and PDA.deleted = 0 
				inner join ( select distinct idheader from Document_MicroLotti_Dettagli with(nolock) where TipoDoc = 'PDA_MICROLOTTI'  and Voce = 0 and StatoRiga = 'AggiudicazioneDef' ) PL on PL.idheader=PDA.id
				--Sono Attivati (  presente il documento  ATTIVA_AQ. Confermato ), 
				inner join CTL_DOC C with(nolock) on C.LinkedDoc=D.id and C.TipoDoc='ATTIVA_AQ' and C.StatoFunzionale='Confermato'
				 --Dove sono abilitato personalmente ( idpfu AQ_ABILITAZIONE_RILANCIO )
				inner join CTL_DOC ABILITAZIONE with(nolock) on ABILITAZIONE.idpfu = P.idpfu  and ABILITAZIONE.LinkedDoc=D.id and ABILITAZIONE.TipoDoc='AQ_ABILITAZIONE_RILANCIO' and ABILITAZIONE.StatoFunzionale='Confermato'

		where d.deleted = 0 and d.TipoDoc in ( 'BANDO_GARA' ) and TipoSceltaContraente = 'ACCORDOQUADRO'
				and d.statoFunzionale in ( 'InAggiudicazione' , 'InEsame' , 'Pubblicato' )
				and getDate() <= isnull( s.DataRiferimentoFine , getdate())
				and TipoAccordoQuadro = 'multiround'
				--VERICA CHE GLI AQ NON SONO SCADUTI
				and DATEDIFF(DAY, s.DataRiferimentoFine, GETDATE()) < 0
	UNION 

	--TIRA FUORI AQ senza quote e senza enti aderenti e rispetta 0) 1) 2)
	select d.Id as ID_FROM , P.idpfu as idPfu_aderente,d.Protocollo,cast(d.body as nvarchar(max)) as body,s.DataRiferimentoFine as  DataScadenza,d.Data

		from CTL_DOC  d  with(nolock) 
				inner join dbo.Document_Bando s  with(nolock) on id = idheader and s.GestioneQuote = 'senzaquote'
				left join CTL_DOC_Value CV with(nolock) on CV.IdHeader=S.idHeader and CV.DSE_ID='ENTI' and CV.DZT_Name='AZI_Ente'
				inner join aziende a on  a.aziAcquirente > 0 and CV.value is null 
				inner join ProfiliUtente P with(nolock) on P.pfuIdAzi=a.IdAzi				
				inner join CTL_DOC PDA with(nolock) on d.id = PDA.LinkedDoc and PDA.TipoDoc = 'PDA_MICROLOTTI' and PDA.deleted = 0 
				inner join ( select distinct idheader from Document_MicroLotti_Dettagli with(nolock) where TipoDoc = 'PDA_MICROLOTTI'  and Voce = 0 and StatoRiga = 'AggiudicazioneDef' ) PL on PL.idheader=PDA.id
				--Sono Attivati (  presente il documento  ATTIVA_AQ. Confermato ), 
				inner join CTL_DOC C with(nolock) on C.LinkedDoc=D.id and C.TipoDoc='ATTIVA_AQ' and C.StatoFunzionale='Confermato'
				 --Dove sono abilitato personalmente ( idpfu AQ_ABILITAZIONE_RILANCIO )
				inner join CTL_DOC ABILITAZIONE with(nolock) on ABILITAZIONE.idpfu = P.idpfu  and ABILITAZIONE.LinkedDoc=D.id and ABILITAZIONE.TipoDoc='AQ_ABILITAZIONE_RILANCIO' and ABILITAZIONE.StatoFunzionale='Confermato'

		where d.deleted = 0 and d.TipoDoc in ( 'BANDO_GARA' ) and TipoSceltaContraente = 'ACCORDOQUADRO'
				and d.statoFunzionale in ( 'InAggiudicazione' , 'InEsame' , 'Pubblicato' )
				and getDate() <= isnull( s.DataRiferimentoFine , getdate())
				and TipoAccordoQuadro = 'multiround'
				--VERICA CHE GLI AQ NON SONO SCADUTI
				and DATEDIFF(DAY, s.DataRiferimentoFine, GETDATE()) < 0

		UNION 

	--TIRA FUORI AQ ( Quote Richieste non scaduta)  e rispetta 0) 1) 2)
	select d.Id as ID_FROM , P.idpfu as idPfu_aderente,d.Protocollo,cast(d.body as nvarchar(max)) as body,s.DataRiferimentoFine as  DataScadenza,d.Data

		from CTL_DOC  d  with(nolock) 
				inner join dbo.Document_Bando s  with(nolock) on id = idheader and s.GestioneQuote='quoterichieste'
				inner join CTL_DOC_Value CV with(nolock) on CV.IdHeader=S.idHeader and CV.DSE_ID='ENTI' and CV.DZT_Name='AZI_Ente'
				inner join CTL_DOC RQ with(nolock) on RQ.LinkedDoc=S.idHeader and RQ.TipoDoc='AQ_RICHIESTAQUOTA' and RQ.Azienda=CV.Value and RQ.StatoFunzionale='Approved'				
				inner join Document_Convenzione_Quote DCQ with(nolock) on DCQ.idHeader=RQ.Id and  DATEDIFF(DAY,DCQ.datascadenzaQ, GETDATE()) < 0
				inner join ProfiliUtente P with(nolock) on P.pfuIdAzi=CV.Value				
				inner join CTL_DOC PDA with(nolock) on d.id = PDA.LinkedDoc and PDA.TipoDoc = 'PDA_MICROLOTTI' and PDA.deleted = 0 
				inner join ( select distinct idheader from Document_MicroLotti_Dettagli with(nolock) where TipoDoc = 'PDA_MICROLOTTI'  and Voce = 0 and StatoRiga = 'AggiudicazioneDef' ) PL on PL.idheader=PDA.id
				--Sono Attivati (  presente il documento  ATTIVA_AQ. Confermato ), 
				inner join CTL_DOC C with(nolock) on C.LinkedDoc=D.id and C.TipoDoc='ATTIVA_AQ' and C.StatoFunzionale='Confermato'
				 --Dove sono abilitato personalmente ( idpfu AQ_ABILITAZIONE_RILANCIO )
				inner join CTL_DOC ABILITAZIONE with(nolock) on ABILITAZIONE.idpfu = P.idpfu  and ABILITAZIONE.LinkedDoc=D.id and ABILITAZIONE.TipoDoc='AQ_ABILITAZIONE_RILANCIO' and ABILITAZIONE.StatoFunzionale='Confermato'

		where d.deleted = 0 and d.TipoDoc in ( 'BANDO_GARA' ) and TipoSceltaContraente = 'ACCORDOQUADRO'
				and d.statoFunzionale in ( 'InAggiudicazione' , 'InEsame' , 'Pubblicato' )
				and getDate() <= isnull( s.DataRiferimentoFine , getdate())
				and TipoAccordoQuadro = 'multiround'
				--VERICA CHE GLI AQ NON SONO SCADUTI
				and DATEDIFF(DAY, s.DataRiferimentoFine, GETDATE()) < 0



GO
