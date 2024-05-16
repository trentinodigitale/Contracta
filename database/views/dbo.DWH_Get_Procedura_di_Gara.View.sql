USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DWH_Get_Procedura_di_Gara]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[DWH_Get_Procedura_di_Gara]  as 

SELECT 
	
	  d.Protocollo        AS [Codice Procedura di Gara]
	, REPLACE(REPLACE(d.Titolo , ';', ' '), CHAR(13) + CHAR(10) , '')  AS Titolo
	, REPLACE(REPLACE(CAST(d.Body AS VARCHAR(150)), ';', ' '), CHAR(13) + CHAR(10), '')    AS Oggetto
	, db.CIG as [CIG o Numero Gara]
	, desc1.DMV_DescML   AS [Stato Procedura Gara]
	, desc2.DMV_DescML as [Criterio di Aggiudicazione Prevalente]
	, CI1.value AS Merceologia
	, convert( varchar(10) , DataScadenzaOfferta , 121 )	AS [Termine Presentazione Partecipazione]
	, convert( varchar(10) , DataTermineQuesiti , 121 )	AS [Termine Chiarimenti]
	, convert( varchar(10) , DataAperturaOfferte , 121 )	AS [Data Prima Seduta]
	, ImportoBaseAsta2 as [Importo Base d'Asta]
	, isnull(Appalto_Verde ,'') as [Appalto Verde]
	, isnull(Acquisto_Sociale ,'') as [Appalto Sociale]
	, desc3.DMV_DescML as [Identificativo Iniziativa]
	, desc4.DMV_DescML as [Criterio Formulazione Offerta Economica]
	, dbo.GetDescTipoProcedura ( d.Tipodoc , TipoProceduraCaratteristica , ProceduraGara , TipoBandoGara)  as [Tipo di Procedura]
	, TipoProceduraCaratteristica as Caratteristica
	, desc5.DMV_DescML as [Tipo di Appalto]
	, desc6.DMV_DescML as [Tipo Documento] 
	, case when desc7.DMV_DescML is null then 'Mono Fornitore' else desc7.DMV_DescML end as [Tipo Aggiudicazione]
	, case when GeneraConvenzione = 0 then 'no' when GeneraConvenzione = 1 then 'si'  else '' end as [Genera Convenzione Completa]
	, desc8.DMV_DescML as [Tipologia Lotto]
	--, convert( varchar(10) , DataPresentazioneRisposte , 121 )	AS [Data Inizio Presentazioni Offerte]
	, convert( varchar(10) , DataRiferimentoInizio , 121 )	AS [Data Inizio Presentazioni Offerte]
	, convert( varchar(10) , DataTermineRispostaQuesiti , 121 )	AS [Data Termine Risposte Quesiti]
	, ImportoBaseAsta as [Importo Appalto] 
	, Opzioni as [Importo Opzioni]
	, Oneri as [Oneri]
	, desc9.DMV_DescML as iva
	, p.pfuNome as RUP
	, a.aziRagioneSociale as [Ente Appaltante] 
	, sda.Protocollo as [Codice Bando Istitutivo] 
	, desc10.DMV_DescML  as [Ambito Prevalente] 
	

  FROM CTL_Doc d WITH (NOLOCK)
	  
		inner join Document_Bando db WITH (NOLOCK) on d.id = db.idheader
		inner join aziende a WITH (NOLOCK) on a.idazi = d.Azienda

		--left outer join CTL_Doc sda WITH (NOLOCK) on sda.id = d.LinkedDoc and sda.TipoDoc in ( 'BANDO_SDA' , 'BANDO' ) 
		left outer join CTL_Doc sda WITH (NOLOCK) on ( 
															(sda.TipoDoc =  'BANDO_SDA' and sda.id = d.LinkedDoc ) 
															or  
															(sda.TipoDoc = 'BANDO' and  db.listaalbi like '%###' + cast( sda.id as varchar(10)) + '###%' )
													  )
													  and sda.deleted = 0 and sda.statodoc <> 'Saved' 
	  
		-- RUP
		LEFT OUTER JOIN CTL_DOC_Value rup WITH (NOLOCK) on rup.idheader = d.id and rup.DZT_Name = 'UserRUP' and DSE_ID = 'InfoTec_comune'
		left outer join ProfiliUtente p WITH (NOLOCK) on p.IdPfu = rup.Value	  

		-- livello struttura ente
		left outer join DM_Attributi dmstr WITH (NOLOCK) on d.azienda  = dmstr.LNK   AND dmstr.dztNome = 'TIPO_AMM_ER'	

	   -- ambito
	   LEFT OUTER JOIN CTL_DOC_Value amb WITH (NOLOCK) on amb.idheader = d.id and amb.DZT_Name = 'ambito' and amb.DSE_ID =  'TESTATA_PRODOTTI' 
	   
		--classe iscrizione in forma visuale
		LEFT OUTER JOIN CTL_DOC_Value CI1 WITH (NOLOCK) on CI1.idheader = d.id and CI1.DZT_Name = 'ClassiMerceologiche' and CI1.dse_id='DESCRIZIONE_CLASSI_ISCRIZIONE'
	   
	   --classe iscrizione livello 1 in forma visuale
		LEFT OUTER JOIN CTL_DOC_Value CI2 WITH (NOLOCK) on CI2.idheader = d.id and CI2.DZT_Name = 'ClassiMerceologicheLiv' and CI2.dse_id='DESCRIZIONE_CLASSI_ISCRIZIONE'

		inner join LIB_DomainValues desc1 WITH (NOLOCK) on desc1.DMV_DM_ID = 'Statofunzionale' and desc1.DMV_Cod = d.StatoFunzionale

		inner join LIB_DomainValues desc2 WITH (NOLOCK) on desc2.DMV_DM_ID = 'criterio2' and desc2.DMV_Cod = db.CriterioAggiudicazioneGara --isnull( V.value ,db.CriterioAggiudicazioneGara )

		left outer join
		(
			SELECT DISTINCT 
					   
				NumeroDocumento					    AS DMV_Cod					
				,   
					CAST(
						CAST(
						case 
							when charindex('-',NumeroDocumento) = 0 then NumeroDocumento
							else left(NumeroDocumento , charindex('-',NumeroDocumento)-1) 
						end  as bigint)  as varchar(100)
						) + ' - ' + isnull( cast( Body as nvarchar(max)) , Titolo )  AS DMV_DescML 
					 
					 
		
				FROM ctl_doc C with(nolock)
					WHERE StatoDoc = 'Sended' and TipoDoc = 'INIZIATIVA'  
							and isnumeric(replace(numerodocumento,'-','')) = 1 and StatoFunzionale<>'Variato' and deleted=0

		) desc3 	 on desc3.DMV_Cod = IdentificativoIniziativa

		left outer join
		(
			select distinct

				  
				tdrcodice  as  DMV_Cod ,				  
				dscTesto as DMV_DescML 				   

			from tipidatirange with(nolock) ,dizionarioattributi with(nolock) , descsI with(nolock)

			where dztnome='CriterioFormulazioneOfferte'
				and dztidtid=tdridtid 
				and tdrdeleted=0 
				and IdDsc =  tdriddsc
				
		) desc4 	 on desc4.DMV_Cod = CriterioFormulazioneOfferte

		left outer join LIB_DomainValues desc5 WITH (NOLOCK) on desc5.DMV_DM_ID = 'Tipologia' and desc5.DMV_Cod = db.TipoAppaltoGara 

		left outer join
		(
			select distinct
  
				tdrcodice  as  DMV_Cod ,
				dscTesto as DMV_DescML    

			from tipidatirange with(nolock),dizionarioattributi with(nolock), descsI with(nolock)
			where dztnome='tipobando'
				and dztidtid=tdridtid 
				and tdrdeleted=0 
				and IdDsc =  tdriddsc
		) desc6 	 on desc6.DMV_Cod = TipoBandoGara 


		left outer join LIB_DomainValues desc7 WITH (NOLOCK) on desc7.DMV_DM_ID = 'TipoAggiudicazione' and desc7.DMV_Cod = TipoAggiudicazione
		left outer join LIB_DomainValues desc8 WITH (NOLOCK) on desc8.DMV_DM_ID = 'TipologiaLotto' and desc8.DMV_Cod = Divisione_lotti
		
		left outer join
		(

			select distinct

				tdrcodice  as  DMV_Cod ,  
				dscTesto as DMV_DescML    

			from tipidatirange with(nolock),dizionarioattributi with(nolock), descsI with(nolock)
			where dztnome='IVA'
				and dztidtid=tdridtid 
				and tdrdeleted=0 
				and IdDsc =  tdriddsc			

		) desc9 	 on desc9.DMV_Cod = TipoIVA 

		left outer join LIB_DomainValues desc10 WITH (NOLOCK) on desc10.DMV_DM_ID = 'ambito' and desc10.DMV_Cod = amb.Value 
		
			
 WHERE d.tipodoc in ( 'bando_gara' ,'BANDO_SEMPLIFICATO')

   --AND TipoProceduraCaratteristica = 'RDO' 
   AND d.deleted = 0
   AND d.statodoc = 'sended'
      




GO
