USE [AFLink_TND]
GO
/****** Object:  View [dbo].[LINKED_ISCRIZIONE_ALBO]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO














CREATE view [dbo].[LINKED_ISCRIZIONE_ALBO] as
--Versione=2&data=2012-12-17&Attivita=40053&Nominativo=Sabato
--Versione=3&data=2016-01-21&Attivita=97053&Nominativo=Enrico

select p.idpfu as idOwner , LFN_id as Folder , 1 as  display ,  Number , Fascicolo


from  
	LIB_Functions with (nolock) 
	cross join profiliutente p with (nolock) 
	left outer join 
		( 
			
			



			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
				( 
					select Fascicolo , IdPfu as owner , cast(bread as int) as Number ,
						case when  msgisubtype in ( 31,40,90,93,15,17) then '31_40_90_93' 
							when msgisubtype in (  138,143,145,147,148 ) then  '138_143_145_147_148'
							when msgisubtype in (  44,122  ) then  '44_122'
							when msgisubtype in ( 153, 154,157,158 ) then '153_154_157_158' 
							when msgisubtype in ( 47,125) then '47_125'
							when msgisubtype in ( 109,110,117,119,129,130,121,182,185 ) then '109_110_117_119_129_130_121_182'
							when msgisubtype in ( 113,114,134,135 ) then '113_114_134_135' 
							when msgisubtype in ( 3,11,21,22,25,27,37,38,49,50,53,54,64,69,70,73,75,
									79,80,82,87,88,103,105,162,164,165,176,168,186 ) then cast(msgisubtype as varchar)
							when msgisubtype in ( 97,84,99, 184) then 'PDA_COMUNICAZIONE_GARA'--'97_84_99_184'
							when msgisubtype in ( -1 ) or DocType='DETAIL_CHIARIMENTI' then '_1'
							when DocType in ( 'BANDO_GARA' , 'BANDO' ,'BANDO_ASTA' ) then 'BANDO'
							when DocType in ( 'BANDO_CONCORSO' ) then 'BANDO_CONCORSO'
							when DocType in ( 'BANDO_SDA'  ) then 'BANDO_SDA'
							when DocType in ( 'BANDO_SEMPLIFICATO_INVITO' ) then 'BANDO_SEMPLIFICATO'
							when DocType='ISTANZA_AlboOperaEco' then 'ISTANZA_AlboOperaEco'
							when left( DocType,15) = 'ISTANZA_Albo_ME' then 'ISTANZA_AlboOperaEco'
							when left( DocType,18) = 'ISTANZA_AlboLavori' then 'ISTANZA_AlboLavori'
							when left( DocType,21) = 'ISTANZA_AlboFornitori' then 'ISTANZA_AlboFornitori'
							when left( DocType,16) = 'ISTANZA_AlboProf' then 'ISTANZA_AlboProf'							
							when DocType='ISTANZA_SDA_FARMACI' then 'ISTANZA_SDA_FARMACI'
							when DocType='ISTANZA_SDA_2' then 'ISTANZA_SDA_2'							
							when DocType='ISTANZA_SDA_3' then 'ISTANZA_SDA_3'
							when DocType='ISTANZA_SDA_RP' then 'ISTANZA_SDA_RP'
							when DocType='ISTANZA_SDA_IC' then 'ISTANZA_SDA_IC'
							when DocType in ('COMUNICAZIONE_OE','COMUNICAZIONE_OE_RISP','PDA_COMUNICAZIONE_OFFERTA','PDA_COMUNICAZIONE_GARA','PDA_COMUNICAZIONE_RISP','COM_ESITO_GARA_FORNITORE','COM_AGGIUDICATARIA','COM_STIPULA_CONTRATTO') then 'PDA_COMUNICAZIONE_GARA'
							when DocType in ('PDA_COMUNICAZIONE_OFFERTA_RISP','OFFERTA','OFFERTA_ASTA','RITIRA_OFFERTA') then '186'
							--when DocType in ('MANIFESTAZIONE_INTERESSE','DOMANDA_PARTECIPAZIONE') then '1986'
							when DocType = 'DOMANDA_PARTECIPAZIONE' or ( DocType in ('MANIFESTAZIONE_INTERESSE') and TipoBandoGara not in ('4','5'))  then '1986'
							when DocType in ('MANIFESTAZIONE_INTERESSE') and TipoBandoGara in ('4','5') then 'risposteavvisi'
							when DocType in ('VERIFICA_REGISTRAZIONE','VERIFICA_REGISTRAZIONE_FORN') then 'PDA_COMUNICAZIONE_GARA'--'186'
							when DocType in ('SCRITTURA_PRIVATA','CONTRATTO_GARA_FORN') then 'SCRITTURA_PRIVATA'
							when DocType in ('RISPOSTA_CONCORSO') then 'RISPOSTA_CONCORSO'
							

							when msgisubtype in ( 12,177) then '12_177'
							--else  '12_177' 
							end as tipo 
						from MSG_LINKED_ISCRIZIONE_ALBO with (nolock) 
						where msgisubtype in ( 31,40,90,93,15,17, 12,177 ,  
												138,143,145,147,148 
												, 44,122    
												, 153, 154,157,158    
												,47,125
												, 109,110,117,119,129,130,121,182,185 
												,113,114,134,135 

												,3,11,21,22,25,27,37,38,49,50,53,54,64,69,70,73,75,
																	79,80,82,87,88,103,105,162,164,165,176,168,186
												,97,84,99, 184
												
											  )
								or  DocType in ( 'DETAIL_CHIARIMENTI' , 'BANDO' , 'BANDO_SDA' , 'BANDO_GARA' ,'BANDO_CONCORSO',
												 'ISTANZA_SDA_FARMACI' ,'ISTANZA_SDA_2','ISTANZA_SDA_RP','ISTANZA_SDA_3' ,'ISTANZA_SDA_IC', 'ISTANZA_AlboOperaEco',
												 'PDA_COMUNICAZIONE_GARA' , 'PDA_COMUNICAZIONE_RISP',
												 'COMUNICAZIONE_OE','COMUNICAZIONE_OE_RISP',
												 'PDA_COMUNICAZIONE_OFFERTA','PDA_COMUNICAZIONE_OFFERTA_RISP',
												 'COM_ESITO_GARA_FORNITORE','COM_AGGIUDICATARIA',
												 'COM_STIPULA_CONTRATTO','OFFERTA' , 'BANDO_SEMPLIFICATO_INVITO' ,'VERIFICA_REGISTRAZIONE','VERIFICA_REGISTRAZIONE_FORN','SCRITTURA_PRIVATA','SCRITTURA_PRIVATA_FORN','CONTRATTO_GARA_FORN',
												 'BANDO_ASTA' , 'OFFERTA_ASTA','MANIFESTAZIONE_INTERESSE','RITIRA_OFFERTA', 'DOMANDA_PARTECIPAZIONE','RISPOSTA_CONCORSO'
												 )
							or left( DocType,15) = 'ISTANZA_Albo_ME'
							or left( DocType,16) = 'ISTANZA_AlboProf'
							or left( DocType,18) = 'ISTANZA_AlboLavori'
							or left( DocType,21) = 'ISTANZA_AlboFornitori'
				) v
			group by Fascicolo , owner, tipo



		
--			union all
--
--			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
--			from 
--			(		select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '_1' as tipo 
--					from MSG_LINKED_ISCRIZIONE_ALBO 
--					where msgisubtype = -1
--			
--					union all
--			
--					select Fascicolo , idpfu as owner , cast(bread as int) as Number , '_1' as tipo 
--					from MSG_LINKED_ISCRIZIONE_ALBO
--					where DocType='DETAIL_CHIARIMENTI'
--			
--				
--			) v
--			group by Fascicolo , owner, tipo

			

--			union all 
--			
--			
--			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
--			from 
--			( 
--
--				
--				select Fascicolo , idpfu as owner , cast(bread as int) as Number , 'BANDO' as tipo 
--				from MSG_LINKED_ISCRIZIONE_ALBO
--				where DocType='BANDO'	
--				
--
--			) v
--			group by Fascicolo , owner, tipo
			
--			union all
--			
--			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
--			from 
--			( 
--
--				
--				select Fascicolo , idpfu as owner , cast(bread as int) as Number , 'ISTANZA_AlboOperaEco' as tipo 
--				from MSG_LINKED_ISCRIZIONE_ALBO
--				where DocType='ISTANZA_AlboOperaEco'						
--				
--
--			) v
--			group by Fascicolo , owner, tipo
			
			union all
			
			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( 
				select a.Fascicolo , p.IdPfu as owner ,case when DOC_NAME is null then 1 else 0 end as Number , 'COMUNICAZIONI_ALBO' as tipo 
					from ctl_doc as a  with (nolock) 
						inner join profiliutente p  with (nolock) on p.pfuidazi = a.Destinatario_Azi
						left outer join CTL_DOC_READ r  with (nolock) on  DOC_NAME = a.tipoDoc  and id_Doc = a.Id and p.idPfu = r.idPfu 
					where a.tipoDoc in ( 'CONFERMA_ISCRIZIONE' , 'SCARTO_ISCRIZIONE' , 'INTEGRA_ISCRIZIONE','CONFERMA_ISCRIZIONE_SDA','INTEGRA_ISCRIZIONE_SDA','SCARTO_ISCRIZIONE_SDA','CONFERMA_ISCRIZIONE_LAVORI','SCARTO_ISCRIZIONE_LAVORI')
							and a.Statodoc <> 'Saved'

				union all

				select a.Fascicolo , p.IdPfu as owner ,0 as Number , 'COMUNICAZIONI_ALBO' as tipo 
					from ctl_doc as a with (nolock) 
						inner join profiliutente p  with (nolock) on p.pfuidazi = a.Destinatario_Azi
					where a.tipoDoc in ( 'INTEGRA_ISCRIZIONE_RIS','INTEGRA_ISCRIZIONE_RIS_SDA' )

			) v
			group by Fascicolo , owner, tipo
			

			union all

			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
			from 
			( 

				select Fascicolo , CTL_DOC.IdPfu as owner ,case when DOC_NAME is null then 0 else 0 end as Number , '187_188' as tipo 
					from ctl_doc	 with (nolock) 
						left outer join CTL_DOC_READ r  with (nolock) on ( DOC_NAME = tipoDoc or DOC_NAME = tipoDoc + '_IA' )and id_Doc = ctl_doc.Id and CTL_DOC.idPfu = r.idPfu 
					where tipoDoc in ( 'RICHIESTA_ATTI_GARA'  )
				union
				select a.Fascicolo , b.IdPfu as owner ,case when DOC_NAME is null then 1 else 0 end as Number , '187_188' as tipo 
					from ctl_doc as a with (nolock) 
						inner join CTL_DOC as b  with (nolock) on a.LinkedDoc 	= b.id
						left outer join CTL_DOC_READ r  with (nolock) on ( DOC_NAME = a.tipoDoc + '_IA' )and id_Doc = a.Id and b.idPfu = r.idPfu 
					where a.tipoDoc in ( 'INVIO_ATTI_GARA'  )
				
			) as a
			
			group by Fascicolo , owner, tipo

--			union all
--			
--			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
--			from 
--			( select Fascicolo , IdPfu as owner , cast(bread as int) as Number , '97_84_99_184' as tipo 
--			from MSG_LINKED_ISCRIZIONE_ALBO 
--			where msgisubtype in ( 97,84,99, 184)) v
--			group by Fascicolo , owner, tipo
			
--			union all
--			
--
--			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
--				from 
--				( 
--
--					
--					select Fascicolo , idpfu as owner , bread as Number , 'PDA_COMUNICAZIONE_GARA' as tipo 
--					from MSG_LINKED_ISCRIZIONE_ALBO
--					where DocType='PDA_COMUNICAZIONE_GARA'						
--					
--
--				) v
--				group by Fascicolo , owner, tipo
				
--			union all
--			
--
--			select Fascicolo , owner, nullif(sum(Number),0) as Number, tipo
--				from 
--				( 
--
--					
--					select Fascicolo , idpfu as owner , bread as Number , 'PDA_COMUNICAZIONE_RISP' as tipo 
--					from MSG_LINKED_ISCRIZIONE_ALBO
--					where DocType='PDA_COMUNICAZIONE_RISP'						
--					
--
--				) v
--				group by Fascicolo , owner, tipo
--			
				
			
	) as a on p.idpfu = owner and LFN_id = tipo 
	

where LFN_GroupFunction = 'LINKED_ISCRIZIONE_ALBO'

















GO
