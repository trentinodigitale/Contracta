USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_LISTA_ATTIVITA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO














CREATE VIEW [dbo].[OLD_LISTA_ATTIVITA] 
AS
select a.* from (

	SELECT distinct ATV_IDDOC                                AS Id
		 , ATV_Object                               AS Oggetto
		 , ATV_IdPfu                                AS Owner
		 , ATV_DateInsert                           AS Data
		 , ATV_ExpiryDate                           AS DataScadenza
		 , ATV_ExpiryDate                           AS DataScadenzaA
		 , ATV_Obbligatory                          AS Urgente
		 , ATV_DocumentName                         AS OPEN_DOC_NAME
		 , ATV_Execute
		 , ATV_IdPfu 
		 , ATV_IdAzi 
		 , ATV_obbligatory
		 , ATV_DocumentName
		 , ATV_IDDOC
		 , '' as Notacom
		 , ATV_Allegato as allegato
		 , ATV_Object 
		 , ispublic
		 , 'Sended' as StatoDoc

	  FROM CTL_Attivita WITH (NOLOCK)
		 , Aziende A  WITH (NOLOCK)
		 , MPAziende WITH (NOLOCK)
		 , ProfiliUtente WITH (NOLOCK)
		 , Document_Com_DPE_Fornitori  WITH (NOLOCK)
		 , Document_Com_DPE  WITH (NOLOCK)
     
	 WHERE ATV_IdPfu = IdPfu
	   AND pfuIdAzi = A.IdAzi
	   AND A.IdAzi = mpaIdAzi
	   AND aziDeleted = 0 
	   AND mpaDeleted = 0
	   AND mpaIdMp = 1
	   AND ATV_Execute = 'No'
	   and Document_Com_DPE_Fornitori.IdComFor=ATV_IDDOC
	   and Document_Com_DPE.IdCom=Document_Com_DPE_Fornitori.IdCom
	   and ispublic=0
	   and isnull( ATV_ExpiryDate , convert( datetime , '3000-01-01 00:00:00' , 121 ) )  >= getdate()
	   and Document_Com_DPE.StatoCom <> 'Richiamata'
	union 

	SELECT distinct ATV_IDDOC                                AS Id
		 , ATV_Object                               AS Oggetto
		 , ATV_IdPfu                                AS Owner
		 , ATV_DateInsert                           AS Data
		 , ATV_ExpiryDate                           AS DataScadenza
		 , ATV_ExpiryDate                           AS DataScadenzaA
		 , ATV_Obbligatory                          AS Urgente
		 , ATV_DocumentName                         AS OPEN_DOC_NAME
		 , ATV_Execute
		 , ATV_IdPfu 
		 , ATV_IdAzi 
		 , ATV_obbligatory
		 , ATV_DocumentName
		 , ATV_IDDOC
		 , ''
		 , ATV_Allegato as allegato
		 , NotaCom
		 , ispublic
 		 , 'Sended' as StatoDoc

	  FROM CTL_Attivita WITH (NOLOCK)
		 , Aziende  A WITH (NOLOCK)
		 , MPAziende WITH (NOLOCK)
		 , ProfiliUtente WITH (NOLOCK)
		 , Document_Com_DPE_Fornitori  WITH (NOLOCK)
		 , Document_Com_DPE  WITH (NOLOCK)
     
	 WHERE ATV_IdPfu = IdPfu
	   AND pfuIdAzi = A.IdAzi
	   AND A.IdAzi = mpaIdAzi
	   AND aziDeleted = 0 
	   AND mpaDeleted = 0
	   AND mpaIdMp = 1
	   AND ATV_Execute = 'No'
	   and Document_Com_DPE_Fornitori.IdComFor=ATV_IDDOC
	   and Document_Com_DPE.IdCom=Document_Com_DPE_Fornitori.IdCom
	   and ispublic=1
	   and isnull( ATV_ExpiryDate , convert( datetime , '3000-01-01 00:00:00' , 121 ) )  >= getdate()
	   and Document_Com_DPE.StatoCom <> 'Richiamata'

	UNION

	SELECT
		   case when ATV_DocumentName in ( 'RELEASE_NOTES_IA', 'FORMULARI_IA')
				then ATV_ID
				else ATV_IDDOC
		   end AS Id		 
		 , ATV_Object AS oggetto
		 , isnull( IdPfu , ATV_IdPfu )				AS Owner
		 , ATV_DateInsert                           AS Data
		 , ATV_ExpiryDate                           AS DataScadenza
		 , ATV_ExpiryDate                           AS DataScadenzaA
		 , case when ATV_DocumentName in ( 'RELEASE_NOTES_IA')
				then 'no_release_notes'
				else ATV_Obbligatory
		   end AS Urgente
		 , case when ATV_DocumentName='SCRITTURA_PRIVATA' then 'SCRITTURA_PRIVATA_FORN' 
				--when ATV_DocumentName='CONTRATTO_GARA' then 'CONTRATTO_GARA_FORN' 
				else ATV_DocumentName end           AS OPEN_DOC_NAME
		 , ATV_Execute
		 , ATV_IdPfu 
		 , ATV_IdAzi 
		 , ATV_obbligatory
		 , ATV_DocumentName
		 , ATV_IDDOC
		 , ''
		 , ATV_Allegato as allegato
		 , ATV_Object
		 , 0 as ispublic
		 , 'Sended' as StatoDoc

	  FROM CTL_Attivita  a WITH (NOLOCK)
		 inner join  Aziende  WITH (NOLOCK) on ATV_IdAzi = IdAzi 	   AND aziDeleted = 0 
		 inner join  MPAziende  WITH (NOLOCK) on IdAzi = mpaIdAzi  AND mpaDeleted = 0 AND mpaIdMp = 1
		 left outer join  ProfiliUtente  WITH (NOLOCK) on pfuIdAzi = IdAzi and ATV_IdPfu is null
		 --left outer join ProfiliUtente on pfuIdAzi = ATV_IdAzi

	 WHERE 
	    ATV_Execute = 'no'
	  and isnull( ATV_ExpiryDate , convert( datetime , '3000-01-01 00:00:00' , 121 ) )  >= getdate()
	 -- and IdPfu=35845
	  and ATV_DocumentName <> 'CHANGE_PWD_OBBLIG'


	union

	--RIGHE PER IL CAMBIO PWD
	SELECT distinct 
			ATV_IDDOC                                AS Id
		 , ATV_Object                               AS Oggetto
		 , ATV_IdPfu                                AS Owner
		 , ATV_DateInsert                           AS Data
		 , ATV_ExpiryDate                           AS DataScadenza
		 , ATV_ExpiryDate                           AS DataScadenzaA
		 , ATV_Obbligatory                          AS Urgente
		 , ATV_DocumentName + '.760.450'                    AS OPEN_DOC_NAME
		 , ATV_Execute
		 , ATV_IdPfu 
		 , ATV_IdAzi 
		 , ATV_obbligatory
		 , ATV_DocumentName
		 , ATV_IDDOC
		 , ''
		 , '' as allegato
		 , titolo 
		 , 0  
		 , 'Sended' as StatoDoc

	  FROM CTL_Attivita WITH (NOLOCK)
		 , ctl_doc WITH (NOLOCK)
	 WHERE 
		ATV_IdPfu = ctl_doc.IdPfu
	   AND ATV_Execute = 'No'
	   and id=ATV_IDDOC
	   and tipodoc='CHANGE_PWD_OBBLIG'
	) a
		--CONCETTO VALIDO SOLO PER LE ATTIVITA' RIVOLTE ALLE AZIENDE
		left join CTL_DOC_READ rd  WITH (NOLOCK) ON a.id = rd.id_doc and rd.DOC_NAME = 'LISTA_ATTIVITA'
	where rd.id is null










GO
