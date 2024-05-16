USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_AVCP_BandiCtl]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Versione=1&data=2014-01-15&Attivita=51444&Nominativo=Leone
CREATE VIEW [dbo].[OLD2_AVCP_BandiCtl] as

	SELECT a.*, dm.vatValore_FT as CFenteProponente, /*dom.DMV_DescML as tipoprocedura, */ dom.DMV_Cod as CodTipoProcedura, NULL  as DataInizio, NULL  as DataFine
	  FROM (

		  SELECT 
            ctl_doc.id as IdMsg, 
            '' as IdDoc, 
            -1 as iType, 
            -1 as iSubType, 
            -- 'BANDO_SEMPLIFICATO' as OPEN_DOC_NAME,
            IdPfu as IdMittente,
            0 as TipoAppalto,

            case CriterioAggiudicazioneGara 
                  when 15531 then 1
                  when 15532 then 2
                  when 16291 then 3
				  when 25532 then 4
            end as CriterioAggiudicazione, 

            ProtocolloBando,
            Protocollo as CigAusiliare,
            ProceduraGara, 

            cast( Body as nvarchar(4000)) as Oggetto, 

            --'Bando' as Tipo, 
            dbo.FormatMoney(ImportoBaseAsta) AS a_base_asta,
            '' as di_aggiudicazione,

            DataInvio as DtPubblicazione, 
            isnull( DataScadenzaOfferta ,DataScadenzaOffIndicativa) AS DtScadenzaBando ,
            isnull( DataScadenzaOfferta ,DataScadenzaOffIndicativa) AS DtScadenzaBandoTecnical ,

            CIG, 
            --domVal.dmv_descml as TipoBando, -- per la vista del doc generico è un numero
            tipobandogara as TipoBando,

            aziRagioneSociale as DenominazioneEnteProponente,
            a.idazi as AziendaMittente,

            CASE WHEN document_bando.divisione_lotti = 0 THEN '0' 
                   ELSE '1' 
            END AS divisioneInLotti,

            'BANDO_SEMPLIFICATO' as TipoDoc,

			'INVITO' AS TipoProcedura

      FROM ctl_doc with(nolock) 

            INNER JOIN aziende a with(nolock) on azienda = a.idazi
            INNER JOIN document_bando  with(nolock)  on id = idheader

            --LEFT OUTER JOIN (
            --    select distinct id , ID_MSG_BANDO, DATEADD(day, 180, DataPubbEsito) AS DtScadenzaPubblEsito from Document_RisultatoDiGara with(nolock)  
            --          inner join DOCUMENT_RISULTATODIGARA_ROW with(nolock) on id = idheader 
            --          ) as r on r.ID_MSG_BANDO = -CTL_DOC.id

            -- inner join per recuperare la descrizione della colonna 'Contratto' corrispondente a tipoAppaltoGara
            INNER JOIN (
                        SELECT dmv_descml, dmv_cod from 
                             lib_domainvalues  with(nolock) where dmv_dm_id = 'Tipologia'
                        ) as domVal on domVal.dmv_cod = Document_Bando.TipoAppaltoGara


      WHERE tipodoc = 'BANDO_SEMPLIFICATO' and statofunzionale in ('Pubblicato', 'InEsame', 'InAggiudicazione', 'Chiuso','InRettifica','PresOfferte') and deleted = 0
      
UNION ALL

      SELECT 
            ctl_doc.id as IdMsg, 
            '' as IdDoc, 
            -1 as msgIType, 
            -1 as msgISubType, 
            --TipoDoc as OPEN_DOC_NAME,
            IdPfu as IdMittente,
            0 as TipoAppalto,

            case CriterioAggiudicazioneGara 
                  when 15531 then 1
                  when 15532 then 2
                  when 16291 then 3
				  when 25532 then 4
            end as CriterioAggiudicazione, 

            ProtocolloBando,
            Protocollo as CigAusiliare,
            ProceduraGara, 

            cast( Body as nvarchar(4000)) as Oggetto, 

            --'Bando' as Tipo, 
            dbo.FormatMoney(ImportoBaseAsta) AS a_base_asta,
            '' as di_aggiudicazione,


            DataInvio as DtPubblicazione, 

            isnull( DataScadenzaOfferta ,DataScadenzaOffIndicativa) AS DtScadenzaBando ,
            isnull( DataScadenzaOfferta ,DataScadenzaOffIndicativa) AS DtScadenzaBandoTecnical ,

            CIG, 

            --domVal.dmv_descml as TipoBando, -- per la vista del doc generico è un numero
            tipobandogara as TipoBando,

            aziRagioneSociale as DenominazioneEnteProponente,
            a.idazi as AziendaMittente,

            CASE WHEN document_bando.divisione_lotti = 0 THEN '0' 
                   ELSE '1' 
            END AS divisioneInLotti,

            'BANDO_GARA' as TipoDoc,

			CASE WHEN tipobandogara = '3' then 'INVITO' ELSE 'APERTA' end as TipoProcedura


      FROM ctl_doc with(nolock) 
            INNER JOIN aziende a with(nolock) on azienda = a.idazi
            INNER JOIN document_bando  with(nolock)  on id = idheader

            --LEFT OUTER JOIN (
            --    select distinct id , ID_MSG_BANDO, DATEADD(day, 180, DataPubbEsito) AS DtScadenzaPubblEsito from Document_RisultatoDiGara with(nolock)  
            --          inner join DOCUMENT_RISULTATODIGARA_ROW with(nolock) on id = idheader 
            --          ) as r on r.ID_MSG_BANDO = -CTL_DOC.id

                        
            -- inner join per recuperare la descrizione della colonna 'Contratto' corrispondente a tipoAppaltoGara
            INNER JOIN (
                        SELECT dmv_descml, dmv_cod from 
                             lib_domainvalues  with(nolock) where dmv_dm_id = 'Tipologia'
                        ) as domVal on domVal.dmv_cod = Document_Bando.TipoAppaltoGara


            -- Se è presente la StrutturaAziendale ed è avvalorata recupero la descrizione dell'ente espletante da li altrimenti 
            -- da dall'azienda presente nel campo 'azienda' del documento
            LEFT OUTER JOIN (
                                         SELECT DISTINCT 
                                               Descrizione AS DMV_DescML,
                                               CAST(IdAz AS varchar) + '#' + Path AS DMV_Cod
                                         FROM AZ_STRUTTURA  with(nolock)
                                         ) AS viewTipoAmmin1 ON viewTipoAmmin1.dmv_cod = ctl_doc.StrutturaAziendale

            --LEFT OUTER JOIN (
            --                            SELECT dmv_descml, dmv_cod FROM
            --                           lib_domainvalues  with(nolock) WHERE dmv_dm_id = 'TipoDiAmministr'
            --                      ) AS viewTipoAmmin2 ON viewTipoAmmin2.dmv_cod = a.TipoDiAmministr

      WHERE tipodoc = 'BANDO_GARA' and statofunzionale in ('Pubblicato', 'InEsame', 'InAggiudicazione', 'Chiuso', 'InRettifica','PresOfferte') and deleted = 0

  ) a 
       INNER JOIN Dm_Attributi dm ON dm.lnk = a.AziendaMittente and dm.dztnome = 'codicefiscale'
      LEFT JOIN (
            SELECT DISTINCT
              tdrcodice  as  DMV_Cod ,
              dscTesto as DMV_DescML
            FROM tipidatirange,dizionarioattributi, descsi
            WHERE dztnome='ProceduraGara' and dztidtid=tdridtid and tdrdeleted=0 and IdDsc = tdriddsc
                        ) dom ON dom.dmv_cod = a.ProceduraGara 

WHERE a.ProtocolloBando NOT LIKE 'Demo%' 

GO
