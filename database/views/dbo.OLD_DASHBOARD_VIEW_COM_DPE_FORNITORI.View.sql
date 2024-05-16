USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_COM_DPE_FORNITORI]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_COM_DPE_FORNITORI]
AS
SELECT Document_Com_DPE.IdCom
     ,Document_Com_DPE.IdCom as IdComFor
	 , Name
     , F.IdPfu                           AS owner
     , DataCreazione
     , Protocollo
     , StatoCom
     , Obbligo
     , DataObbligo
     , TipologiaAllegati
     , BloccoAccesso
     , DataScadenzaCom
     , StatoComFor
     , Accetta
     , DataAccettazione
     , Rimanda
     , Allegato
     , Notacom
      , 'COM_DPE_FORNITORE_APP' as OPEN_DOC_NAME
	 , '2' AS StatoGD
	 , isnull( convert(varchar(100),DataScadenza,120) , '3000-12-31' ) as DataScadenza
	 , convert(varchar(100),GetDate(),120) as DataCurr
	 , RichiestaRisposta
	 , case when isnull( FORNITORIGrid_ID_DOC , 0 ) <> 0 then 1 else 0 end Scrittura 
	 , Owner as Idpfu
	 , E.pfuidazi as Azienda
  FROM Document_Com_DPE 
     , Document_Com_DPE_Fornitori
     , ProfiliUtente F
     , Aziende 
	, ProfiliUtente E
 WHERE Document_Com_DPE_Fornitori.IdCom = Document_Com_DPE.IdCom
   AND Document_Com_DPE_Fornitori.IdAzi = Aziende.IdAzi
   AND F.pfuIdAzi = Aziende.IdAzi
   AND StatoCom <> 'Salvato'  
   AND E.idpfu=Owner
   AND Deleted = 0

union 

SELECT   distinct Document_Com_DPE.IdCom
     , Document_Com_DPE.IdCom as IdComFor
	 , Name
     , PA.IdPfu AS owner
     , DataCreazione
     , Protocollo
     , StatoCom
     , Obbligo
     , DataObbligo
     , TipologiaAllegati
     , BloccoAccesso
     , DataScadenzaCom
     , StatoComDir as StatoComFor
     , '' as Accetta
     , DataAccettazioneDir as DataAccettazione
     ,null as Rimanda
     ,null as Allegato
     ,null as Notacom
	 , 'COM_DPE_FORNITORE_APP' as OPEN_DOC_NAME
	 , '2' AS StatoGD
	 , convert(varchar(100),DataScadenza,120) as DataScadenza
	 , convert(varchar(100),GetDate(),120) as DataCurr
	 , RichiestaRisposta
	 , case when isnull( PLANTGrid_ID_DOC , 0 ) <> 0 then 1 else 0 end Scrittura 
	 , Owner as Idpfu
	 , E.pfuidazi as Azienda

  FROM Document_Com_DPE 
     , Document_Com_DPE_Plant
	 , profiliutenteattrib PA
	 , ProfiliUtente E
 WHERE Document_Com_DPE_Plant.IdCom = Document_Com_DPE.IdCom
   AND StatoCom <> 'Salvato'  
   AND Deleted = 0
   and PA.dztnome='Filtropeg'
   and PA.attvalue=Document_Com_DPE_Plant.plant
   AND E.idpfu=Owner




GO
