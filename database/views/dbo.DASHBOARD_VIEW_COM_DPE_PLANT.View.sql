USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_COM_DPE_PLANT]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DASHBOARD_VIEW_COM_DPE_PLANT]
AS
SELECT   distinct Document_Com_DPE.IdCom
     , Document_Com_DPE.IdCom as IdComFor
     , Name
     , IdPfu AS owner
     , DataCreazione
     , Protocollo
     , StatoCom
     , StatoCom as StatoComFor
     , Obbligo
     , DataObbligo
     , TipologiaAllegati
     , BloccoAccesso
     , DataScadenzaCom
     , convert(varchar(100),DataScadenza,120) as DataScadenza
	 , convert(varchar(100),GetDate(),120) as DataCurr
	 , RichiestaRisposta
     --, StatoComDir as StatoComFor
     , '' as Accetta
     --, DataAccettazioneDir as DataAccettazione
     ,null as Rimanda
     ,null as Allegato
     , Notacom
     , 'COM_DPE_PLANT' as OPEN_DOC_NAME
  FROM Document_Com_DPE 
		inner join Document_Com_DPE_Plant on Document_Com_DPE_Plant.IdCom = Document_Com_DPE.IdCom
		inner join profiliutenteattrib on  profiliutenteattrib.dztnome='Filtropeg'
									   and profiliutenteattrib.attvalue=Document_Com_DPE_Plant.plant

 WHERE 
	StatoCom <> 'Salvato'  
	AND Deleted = 0


GO
