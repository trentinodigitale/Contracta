USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Avcp_PopolaPartecipanti]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









--Versione=1&data=2014-01-17&Attivita=51444&Nominativo=Leone
CREATE  PROCEDURE [dbo].[Avcp_PopolaPartecipanti] ( 
                                         @cig varchar(100), @versioneGara varchar(100), 
                                         @fascicoloGara varchar(100), @idBando INT, 
                                         @tipoDoc varchar(200), @TipoProcedura varchar(100),
                                         @isLotti INT, @idDOCbando VARCHAR(100),  @importoAggiudicato float = 0 output
                                                                       )
AS
BEGIN


      DECLARE @debug int

      set @debug = 0
	  set @importoAggiudicato = 0

      if @debug = 1
            print 'Cancello i partecipanti con linkedDoc = ' + @versioneGara


      -- Cancello i partecipanti del lotto/cig della precedente versione base
	  IF isnull(@versioneGara,'') <> ''
	  BEGIN

		  delete from Document_AVCP_Partecipanti
				where idHeader in ( 
					  select id from ctl_doc with(nolock)
							where LinkedDoc = @versioneGara and idpfu = -20 and StatoFunzionale = 'Pubblicato' 
									   and TipoDoc in ('AVCP_OE','AVCP_GRUPPO') )

		  delete from ctl_doc where LinkedDoc = @versioneGara and idpfu = -20 and StatoFunzionale = 'Pubblicato' 
											 and TipoDoc in ('AVCP_OE','AVCP_GRUPPO') 

	  END

------------------------------------------------------------------------------------------------------------------
------ ***  PRENDERE I PARTECIPANTI SOLTANTO SE È STATA RAGGIUNTA LA DATA PRIMA SEDUTA DEL BANDO ***
------------------------------------------------------------------------------------------------------------------
------ *** SUI LOTTI APERTI SE E' SUPERATA LA GARA MA NON LA FASE AMMINISTRATIVA, PER OGNI
------                  OPERATORE ECONOMICO CHE HA PARTECIPATO ALLA GARA SI METTONO COME DESTINATARIO DEL LOTTO 
------            ALTRIMENTI SOLO PER I LOTTI A CUI STANNO PARTECIPANDO      ***
------------------------------------------------------------------------------------------------------------------

      if exists (
            select  * from tempdb.dbo.sysobjects o
                  where o.xtype in ('U') and o.id = object_id(N'tempdb..#partecipanti_avcp')
      )
            DROP TABLE #partecipanti_avcp

      CREATE TABLE #partecipanti_avcp 
      (
            id [INT] NULL,
            idHeader [INT] NULL,
            RuoloPartecipante [varchar](100) collate DATABASE_DEFAULT NULL,
            Estero [varchar](1) collate DATABASE_DEFAULT NULL,
            CodiceFiscale [varchar](50) collate DATABASE_DEFAULT NULL,
            RagioneSociale [varchar](500) collate DATABASE_DEFAULT NULL,
            Aggiudicatario [varchar](1) collate DATABASE_DEFAULT NULL,
            Azienda [INT] NULL,
            idCtlDoc_OffertaPartecipanti [INT] NULL, -- dismesso. 
			idOffertaInviata [INT] NULL, --Id dell'offerta inviata. mi serve per recuperare i gruppi nel ciclo di inserimento documenti
      )

      declare @dataAperturaOfferte datetime

      -- Popoliamo la tabella temporanea con la lista delle aziende partecipanti al bando

      if @debug = 1 
      begin
            print 'scelta su TipoDocumento per prendere i partecipanti'
            print 'TipoDoc : ' + @tipoDoc
            print 'TipoProcedura : ' + @TipoProcedura
      end

      -- Se è un nuovo documento
      if charindex(';', @tipoDoc ) = 0
      BEGIN

            -- Se la gara è un invito
            IF @TipoProcedura in ( 'INVITO' )
            BEGIN
                  
                  if @debug = 1
                        print 'Documento Nuovo.' + @tipoDoc + 'La gara ' + @cig + ' è ad INVITO. prendo i partecipanti tra gli invitati '

                  INSERT INTO #partecipanti_avcp 
                        (
                             id ,
                             RuoloPartecipante,
                             Estero ,
                             CodiceFiscale,
                             RagioneSociale,
                             Aggiudicatario ,
                             Azienda,
                             idCtlDoc_OffertaPartecipanti,
							 idOffertaInviata
                        )
                        SELECT
                             idPfu as id,
                             --@idBando as idHeader,
                             NULL as RuoloPartecipante,
                             CASE WHEN (upper(aziStatoLeg) = 'ITALIA' OR upper(aziStatoLeg) = 'ITALY') THEN '0'
                                         ELSE '1'
                             END AS Estero,

                             dm.vatValore_FT as CodiceFiscale,

							 --CASE WHEN (upper(aziStatoLeg) = 'ITALIA' OR upper(aziStatoLeg) = 'ITALY') THEN dm.vatValore_FT
        --                                 ELSE  right( '00000000000' +  isnull(azi.aziPartitaIVA ,'') , 11)
        --                     END AS CodiceFiscale,

                             azi.aziRagioneSociale as RagioneSociale,
                             '0' as Aggiudicatario,
                             idazi as Azienda,
                             NULL as idCtlDoc_OffertaPartecipanti,
							 NULL as idOffertaInviata
                        FROM Ctl_Doc_Destinatari azi with(nolock)
                                   INNER JOIN Dm_Attributi dm with(nolock) ON dm.lnk = azi.idazi and dm.dztnome = 'codicefiscale'									
									
						WHERE azi.idHeader = @idBando

            END
            ELSE
            BEGIN

                  -- Se è aperta mi prendo come partecipanti chi ha inviato un offerta relativamente a quel lotto
                  if @debug = 1
                        print 'Documento Nuovo.' + @tipoDoc + ' La gara ' + @cig + ' è APERTA. @isLotti = ' + cast( @isLotti as varchar )

                  -- Se la gara è a lotti mi verrà passato idLotto. le gare nuove per il momento sono sempre a lotti.
                  -- ma il bando_gara verrà implementato anche come 'non a lotti'
                  if isnull(@isLotti ,'') = '1'
                  BEGIN

                        select top 1 @dataAperturaOfferte = DataAperturaOfferte 
                            FROM Document_Bando bando with(nolock)
									INNER JOIN CTL_Doc b with(nolock) ON bando.idHeader = b.id --lotti
									INNER JOIN Document_Microlotti_dettagli a with(nolock) ON b.id = a.idHeader and a.TipoDoc in ('BANDO_SEMPLIFICATO','BANDO_GARA')
                            WHERE b.id = @idBando and voce = 0


                        if @debug = 1
                             print 'La gara ' + @cig + ' è APERTA ed a lotto.Inserisco i partecipanti. DataAperturaOfferta : ' + cast( @dataAperturaOfferte as varchar )                                                                                


                        
                        -- se TROVIAMO la PDA e non è in VERIFICA_AMMINISTRATIVA
                        if exists ( select * from  Ctl_Doc with(nolock) where tipodoc = 'PDA_MICROLOTTI' and statofunzionale <> 'VERIFICA_AMMINISTRATIVA' and linkeddoc = @idBando )
                        BEGIN

                                   -- questa va bene per quando la pda è ancora nella fase amministrativa
                                   -- quindi senza il vincolo sulla document_microlotti_dettagli, perchè
                                   -- non si conoscono (funzionalmente) i lotti ai quali l'operatore economico ha partecipato
                                   INSERT INTO #partecipanti_avcp 
                                         (
                                               id ,
                                               RuoloPartecipante,
                                               Estero ,
                                               CodiceFiscale,
                                               RagioneSociale,
                                               Aggiudicatario ,
                                               Azienda,
                                               idCtlDoc_OffertaPartecipanti,
											   idOffertaInviata
                                         )
                                         SELECT
                                               doc.idPfu as id,
                                               --@idBando as idHeader,
                                               NULL as RuoloPartecipante,
                                               CASE WHEN (upper(azi.aziStatoLeg) = 'ITALIA' OR upper(azi.aziStatoLeg) = 'ITALY') THEN '0'
                                                           ELSE '1'
                                               END AS Estero,

                                               dm.vatValore_FT as CodiceFiscale,


											 --   CASE WHEN (upper(aziStatoLeg) = 'ITALIA' OR upper(aziStatoLeg) = 'ITALY') THEN dm.vatValore_FT
												--	ELSE  right( '00000000000' +  isnull(azi.aziPartitaIVA ,'') , 11)
												--END AS CodiceFiscale,


                                               azi.aziRagioneSociale as RagioneSociale,
                                               '0' as Aggiudicatario,
                                               azi.idazi as Azienda,
                                               NULL as idCtlDoc_OffertaPartecipanti,
											   doc.Id as idOffertaInviata
                                         FROM  Ctl_Doc doc  with(nolock)
                                                           INNER JOIN document_microlotti_dettagli dett with(nolock) ON dett.idHeader = doc.id and dett.tipodoc = doc.tipodoc and voce = 0
                                                           INNER JOIN ProfiliUtente ut with(nolock) ON doc.idPfu = ut.idpfu
                                                           INNER JOIN Aziende azi with(nolock) ON ut.pfuIdAzi = azi.idAzi
                                                           LEFT  JOIN Dm_Attributi dm with(nolock) ON dm.lnk = azi.idazi and dm.dztnome = 'codicefiscale'
                                         WHERE doc.tipodoc = 'OFFERTA' and  doc.linkeddoc = @idBando and doc.StatoDoc = 'Sended' and doc.deleted = 0 and dett.cig = @cig --aggiungo la condizione per cig che mancava
                                                     -- and datediff( minute, convert ( datetime, @dataAperturaOfferte, 126 ),  getdate())  > 0

                        END
                        ELSE
                        BEGIN

                             -- questa va bene per quando la pda è ancora nella fase amministrativa
                             -- quindi senza il vincolo sulla document_microlotti_dettagli, perchè
                             -- non si conoscono (funzionalmente) i lotti ai quali l'operatore economico ha partecipato
                             INSERT INTO #partecipanti_avcp 
                                   (
                                         id ,
                                         RuoloPartecipante,
                                         Estero ,
                                         CodiceFiscale,
                                         RagioneSociale,
                                         Aggiudicatario ,
                                         Azienda,
                                         idCtlDoc_OffertaPartecipanti,
										 idOffertaInviata
                                   )
                                   SELECT
                                         doc.idPfu as id,
                                         --@idBando as idHeader,
                                         NULL as RuoloPartecipante,
                                         CASE WHEN (upper(azi.aziStatoLeg) = 'ITALIA' OR upper(azi.aziStatoLeg) = 'ITALY') THEN '0'
                                                     ELSE '1'
                                         END AS Estero,

                                         dm.vatValore_FT as CodiceFiscale,

										 -- CASE WHEN (upper(aziStatoLeg) = 'ITALIA' OR upper(aziStatoLeg) = 'ITALY') THEN dm.vatValore_FT
											--ELSE  right( '00000000000' +  isnull(azi.aziPartitaIVA ,'') , 11)
											--END AS CodiceFiscale,

                                         azi.aziRagioneSociale as RagioneSociale,
                                         '0' as Aggiudicatario,
                                         azi.idazi as Azienda,
                                         NULL as idCtlDoc_OffertaPartecipanti,
										 doc.id as idOffertaInviata

                                   FROM  Ctl_Doc doc with(nolock)
                                                     --INNER JOIN document_microlotti_dettagli dett ON dett.idHeader = doc.id and dett.tipodoc = doc.tipodoc and voce = 0
                                                     INNER JOIN ProfiliUtente ut with(nolock) ON doc.idPfu = ut.idpfu
                                                     INNER JOIN Aziende azi with(nolock) ON ut.pfuIdAzi = azi.idAzi
                                                     LEFT  JOIN Dm_Attributi dm with(nolock) ON dm.lnk = azi.idazi and dm.dztnome = 'codicefiscale'
                                   WHERE doc.tipodoc = 'OFFERTA' and  doc.linkeddoc = @idBando and doc.StatoDoc = 'Sended' and doc.deleted = 0 
                                               and datediff( minute, convert ( datetime, @dataAperturaOfferte, 126 ),  getdate())  > 0

                             
                        END
                                         
                                               

                  END
                  ELSE
                  BEGIN

                        select top 1 @dataAperturaOfferte = DataAperturaOfferte 
                                FROM Document_Bando bando with(nolock)
                                    INNER JOIN CTL_Doc b with(nolock) ON bando.idHeader = b.id --gara
                                    -- INNER JOIN Document_Microlotti_dettagli a ON b.id = a.idHeader and a.TipoDoc in ('BANDO_SEMPLIFICATO','BANDO_GARA')
                                WHERE b.id = @idBando 

                        if @debug = 1
                             print 'La gara ' + @cig + ' è APERTA e non è a lotto.Inserisco i partecipanti. DataAperturaOfferta : ' + cast( @dataAperturaOfferte as varchar )   

                        INSERT INTO #partecipanti_avcp 
                             (
                                   id ,
                                   RuoloPartecipante,
                                   Estero ,
                                   CodiceFiscale,
                                   RagioneSociale,
                                   Aggiudicatario ,
                                   Azienda,
                                   idCtlDoc_OffertaPartecipanti,
								   idOffertaInviata
                             )
							SELECT
								 doc.idPfu as id,
								 --@idBando as idHeader,
								 NULL as RuoloPartecipante,
								 CASE WHEN (upper(azi.aziStatoLeg) = 'ITALIA' OR upper(azi.aziStatoLeg) = 'ITALY') THEN '0'
											 ELSE '1'
								 END AS Estero,

								 dm.vatValore_FT as CodiceFiscale,
								 --CASE WHEN (upper(azi.aziStatoLeg) = 'ITALIA' OR upper(azi.aziStatoLeg) = 'ITALY') THEN dm.vatValore_FT
			--                                 ELSE  right( '00000000000' +  isnull(azi.aziPartitaIVA ,'') , 11)
			--                     END AS CodiceFiscale,


								 azi.aziRagioneSociale as RagioneSociale,
								 '0' as Aggiudicatario,
								 azi.idazi as Azienda,
								 NULL as idCtlDoc_OffertaPartecipanti,
								 doc.id as idOffertaInviata
							FROM  Ctl_Doc doc with(nolock)
											 INNER JOIN document_microlotti_dettagli dett  with(nolock)ON dett.idHeader = doc.id and dett.tipodoc = doc.tipodoc and voce = 0
											 INNER JOIN ProfiliUtente ut with(nolock) ON doc.idPfu = ut.idpfu
											 INNER JOIN Aziende azi with(nolock) ON ut.pfuIdAzi = azi.idAzi
											 LEFT  JOIN Dm_Attributi dm with(nolock) ON dm.lnk = azi.idazi and dm.dztnome = 'codicefiscale'
							WHERE doc.tipodoc = 'OFFERTA' and linkeddoc = @idBando and StatoDoc = 'Sended' and deleted = 0 --and dett.cig = @cig
									   and datediff( minute, convert ( datetime, @dataAperturaOfferte, 126 ),  getdate())  > 0

                  END

				  


            END

      END 
      ELSE
      BEGIN -- PER i documenti generici



            declare @subType INT
            set  @subType = cast( substring( @tipoDoc, charindex( ';', @tipoDoc ) +1, 100) as INT ) -- prendo da dopo il carattere ; 

            -- --> I RAGGRUPPAMENTI STANNO SOLTANTO SULLE OFFERTE ( 186 ( 171 in caso di bando tradizionale ) ) E SULLE DOMANDE ( 23 ) <--

            if @debug = 1
                  print 'Documento generico.subtype:' + cast(@subType as varchar) + '. La gara ' + @cig + ' è ' + @TipoProcedura + ' . @isLotti = ' + cast( @isLotti as varchar )

            -- Se la gara è un invito (quindi è una ristretta o una negoziata o un asta)
            IF @TipoProcedura = 'INVITO'
            BEGIN

                  DECLARE @subTypeInvito INT

                  if @subType = 167
                  BEGIN
                        SET @subTypeInvito = 168
                  END
                  if @subType = 20
                  BEGIN
                        SET @subTypeInvito = 21
                  END
                  if @subType = 48
                  BEGIN
                        SET @subTypeInvito = 49
                  END
                  if @subType = 68
                  BEGIN
                        SET @subTypeInvito = 69
                  END
                  if @subType = 78
                  BEGIN
                        SET @subTypeInvito = 79
                  END

                  --i 186 sono i lotti tradizionali/cartacei e i partecipanti (se presenti)
                  --dovranno essere inseriti a mano dall'interfaccia

                  ----------------------
                  -- I PARTECIPANTI DELLE GARE AD INVITO SONO GLI INVITATI
                  ---------------------

                  INSERT INTO #partecipanti_avcp 
                  (
                        id ,
                        --idHeader ,
                        RuoloPartecipante,
                        Estero ,
                        CodiceFiscale,
                        RagioneSociale,
                        Aggiudicatario ,
                        Azienda,
                        idCtlDoc_OffertaPartecipanti
                  )
                  SELECT
                        ut.idPfu as id,
                        --@idCtlDoc as idHeader,
                        NULL as RuoloPartecipante,
                        CASE WHEN (upper(azi.aziStatoLeg) = 'ITALIA' OR upper(azi.aziStatoLeg) = 'ITALY') THEN '0'
                                   ELSE '1'
                        END AS Estero,

                        dm.vatValore_FT as CodiceFiscale,
						 --CASE WHEN (upper(azi.aziStatoLeg) = 'ITALIA' OR upper(azi.aziStatoLeg) = 'ITALY') THEN dm.vatValore_FT
       --                                  ELSE  right( '00000000000' +  isnull(azi.aziPartitaIVA ,'') , 11)
       --                      END AS CodiceFiscale,


                        azi.aziRagioneSociale as RagioneSociale,
                        '0' as Aggiudicatario,
                        azi.idazi as Azienda,
                        NULL AS idCtlDoc_OffertaPartecipanti
					FROM tab_messaggi_fields tabm with(nolock)
							INNER JOIN MessageFields with(nolock) ON tabm.idmsg = mfidmsg and AdvancedState <> '6' --non prendo quelle rettificate.uscivano dei duplicati altrimenti
							INNER JOIN tab_utenti_messaggi with(nolock) ON umidmsg=mfidmsg
							INNER JOIN profiliutente ut with(nolock) ON umidpfu=ut.idpfu
							INNER JOIN aziende azi with(nolock) ON idAzi = ut.pfuidazi
							INNER JOIN Dm_Attributi dm with(nolock) ON dm.lnk = azi.idazi and dm.dztnome = 'codicefiscale'
					WHERE  mffieldvalue=@idDOCbando and  mfisubtype=@subTypeInvito

					--FROM MessageFields,tab_utenti_messaggi,profiliutente ut, aziende azi
     --                              INNER JOIN Dm_Attributi dm ON dm.lnk = azi.idazi and dm.dztnome = 'codicefiscale'
     --                   WHERE umidmsg=mfidmsg and mffieldvalue=@idDOCbando and  mfisubtype=@subTypeInvito
     --                                    and umidpfu=ut.idpfu and idAzi = ut.pfuidazi


            END
            ELSE
            BEGIN -- Se la gara non è ad invito


                  ------------------------------------------------------------------
                  -- per le gare aperte inserico i partecipanti solo se ho superato la data apertura offerte
                  ------------------------------------------------------------------
                  if exists( 
                             select * from tab_messaggi_fields  with(nolock)
                                   where IdMsg = (   select MAX(IdMsg) from tab_messaggi_fields  with(nolock) where IdDoc =  @idDOCbando and @tipoDoc = cast( iType as varchar(10)) + ';' + cast ( iSubType as varchar(10)) and Stato ='2' ) 
                                               and  cast ( dataaperturaOfferte as datetime )< GETDATE()
                  )
                  begin             
                        if @debug = 1
                             print 'Documento generico.subtype:' + cast(@subType as varchar) + '. La gara ' + @cig + ' è ' + @TipoProcedura + ' . @isLotti = ' + cast( @isLotti as varchar )

                        ----------------------
                        -- I PARTECIPANTI DELLE GARE APERTE SONO CHI HA INVIATO UN OFFERTA
                        ---------------------        

                        if isnull(@isLotti ,'') = ''
                        BEGIN

                             -- Se la gara non è alotti

                             INSERT INTO #partecipanti_avcp 
                             (
                                   id ,
                                   --idHeader ,
                                   RuoloPartecipante,
                                   Estero ,
                                   CodiceFiscale,
                                   RagioneSociale,
                                   Aggiudicatario ,
                                   Azienda,
                                   idCtlDoc_OffertaPartecipanti,
								   idOffertaInviata
                             )
                             SELECT
                                   ut.idPfu as id,
                                    --@idCtlDoc as idHeader,
                                   NULL as RuoloPartecipante,
                                   CASE WHEN (upper(azi.aziStatoLeg) = 'ITALIA' OR upper(azi.aziStatoLeg) = 'ITALY') THEN '0'
                                               ELSE '1'
                                   END AS Estero,

                                   dm.vatValore_FT as CodiceFiscale,
								 --   CASE WHEN (upper(aziStatoLeg) = 'ITALIA' OR upper(aziStatoLeg) = 'ITALY') THEN dm.vatValore_FT
         --                                ELSE  right( '00000000000' +  isnull(azi.aziPartitaIVA ,'') , 11)
									--END AS CodiceFiscale,

                                   azi.aziRagioneSociale as RagioneSociale,
                                   '0' as Aggiudicatario,
                                   idazi as Azienda,
                                   NULL AS idCtlDoc_OffertaPartecipanti,
								   tabMsg.idMsg as idOffertaInviata
                             FROM MessageFields msg with(nolock)
                                         INNER JOIN tab_utenti_messaggi tabM with(nolock) ON tabM.umidmsg = msg.mfidmsg
                                         INNER JOIN profiliutente ut with(nolock) ON  tabM.umidpfu=ut.idpfu 
                                         INNER JOIN aziende azi with(nolock) on idAzi = ut.pfuidazi
                                         INNER JOIN Dm_Attributi dm with(nolock) ON dm.lnk = azi.idazi and dm.dztnome = 'codicefiscale'
                                         INNER JOIN tab_messaggi_fields tabMsg with(nolock) ON tabMsg.idMsg = mfIdMsg and tabMsg.stato = '2' and tabMsg.advancedState IN ('0','')
                                         
                             WHERE   mffieldvalue=@idDOCbando and  mfisubtype=186 and mffieldname='IdDoc_Bando'
                                               and uminput=1 
                                               -- Prendo i partecipanti solo se è stata superata la dataPrimaSeduta
                                               -- and datediff( minute, (select  convert ( datetime, dataaperturaOfferte, 126 ) as AperturaOfferte from tab_messaggi_fields where idmsg = @idBando ),  getdate())  > 0


                                   --UNION
                                         ---- In linkeddoc c'è idmsg offerta inviata
                                         --LEFT JOIN ctl_doc DocOfferta ON DocOfferta.tipodoc='offerta_partecipanti' and DocOfferta.linkeddoc=tabMsg.idMsg
                                         --LEFT JOIN document_offerta_partecipanti Partecipanti ON Partecipanti.idheader=DocOfferta.id

                        END
                        ELSE
                        BEGIN
                        
                             ------------------------------------------
                             -- gara doc gen a lotti
                             ------------------------------------------
                             
                             
                             INSERT INTO #partecipanti_avcp 
                                   (
                                         id ,
                                         --idHeader ,
                                         RuoloPartecipante,
                                         Estero ,
                                         CodiceFiscale,
                                         RagioneSociale,
                                         Aggiudicatario ,
                                         Azienda,
                                         idCtlDoc_OffertaPartecipanti,
										 idOffertaInviata
                                   )
                                   SELECT
                                         ut.idPfu as id,
                                         --@idCtlDoc as idHeader,
                                         NULL as RuoloPartecipante,
                                         CASE WHEN (upper(azi.aziStatoLeg) = 'ITALIA' OR upper(azi.aziStatoLeg) = 'ITALY') THEN '0'
                                                     ELSE '1'
                                         END AS Estero,

                                         dm.vatValore_FT as CodiceFiscale,
										--  CASE WHEN (upper(aziStatoLeg) = 'ITALIA' OR upper(aziStatoLeg) = 'ITALY') THEN dm.vatValore_FT
										--	ELSE  right( '00000000000' +  isnull(azi.aziPartitaIVA ,'') , 11)
										--END AS CodiceFiscale,


                                         azi.aziRagioneSociale as RagioneSociale,
                                         '0' as Aggiudicatario,
                                         idazi as Azienda,
                                         NULL AS idCtlDoc_OffertaPartecipanti,
										 tabMsg.idMsg as idOffertaInviata
                                   FROM  MessageFields msg with(nolock)
                                               INNER JOIN tab_utenti_messaggi tabM  with(nolock) ON tabM.umIdMsg= msg.mfidmsg 
                                                                                                          and msg.mffieldvalue=@idDOCbando 
                                                                                                          and msg.mfisubtype=186 
                                                                                                          and msg.mffieldname='IdDoc_Bando' and tabM.uminput=1
																									 -- uminput = 1 è quello elaborato dall'agent, serve questo perchè questo idmsg sarà quello associato nella ctldoc come linkedDoc

                                               INNER JOIN tab_messaggi_fields tabMsg  with(nolock) ON tabMsg.idMsg = msg.mfIdMsg and tabMsg.stato = '2' and tabMsg.advancedState IN ('0','')

                                               INNER JOIN profiliutente ut  with(nolock) ON tabM.umidpfu=ut.idpfu 
                                               INNER JOIN aziende azi  with(nolock) ON azi.idAzi = ut.pfuidazi
                                               INNER JOIN Dm_Attributi dm  with(nolock) ON dm.lnk = azi.idazi and dm.dztnome = 'codicefiscale'
                                               INNER JOIN document_microlotti_dettagli dett  with(nolock) ON dett.idHeader = msg.mfidMsg
                                                                       and dett.tipodoc = (cast(msg.mfIType as varchar) + ';' +  cast(msg.mfISubType as varchar))
                                                                       and voce = 0
                                                                 --and datediff( minute, (select  convert ( datetime, dataaperturaOfferte, 126 ) as AperturaOfferte from tab_messaggi_fields where idmsg = @idBando ),  getdate())  > 0
                                   WHERE dett.cig = @cig --and convert ( datetime, dataaperturaOfferte, 126 )< GETDATE()

                                   -- uminput deve essere uguale a 0 ??? perchè nella document_microlotti_dettagli come link c'è l'idmsg
                                   -- di quella in partenza. VOgliamo le offerte inviate e non annullate, sia perchè ne è stata prodotta
                                   -- una successiva , sia perchè è stata scartata dalla PDA nella fase amministrativa

                        END
                  end
                  
                  if @debug = 1
                        print 'Documento generico. Inserisco i gruppi'


------------------------------------------------------------------------------------------------
-------------------------------- GRUPPI
------------------------------------------------------------------------------------------------

                  --INSERT INTO #partecipanti_avcp (id ,RuoloPartecipante,Estero,CodiceFiscale,RagioneSociale,Aggiudicatario,Azienda,idCtlDoc_OffertaPartecipanti)
                  --    SELECT top 1 P.idpfu, 'RTI', '0' AS Estero, '' as CodiceFiscale, RagSocRiferimento as RagioneSociale,'0', IdAziRiferimento as Azienda, DO.idRow
                  --          FROM ctl_doc D 
                  --                      INNER JOIN Document_offerta_partecipanti DO ON D.tipodoc='OFFERTA_PARTECIPANTI' and DO.idheader=D.id 
                  --                      INNER JOIN Profiliutente P ON P.pfuidazi=DO.idazi 
                  --          WHERE DO.TipoRiferimento = 'RTI' -- Prendo solo le RTI, in futuro capire cosa fare con TipoRiferimento = 'ESECUTRICI'
                  --                  and D.linkeddoc = ( select top 1 mfidmsg from MessageFields,tab_utenti_messaggi,profiliutente
                  --                                             where umidmsg=mfidmsg and  mffieldvalue=@idDOCbando
                  --                                                         and  mfisubtype=186 and mffieldname='IdDoc_Bando' and uminput=0 and umidpfu=idpfu )
                  --                -- in D.linkeddoc c'è idmsg offerta inviata
      
            END         

      END

	  ------------------------------------------------------
	  ---- ASSEGNO L'IMPORTO E IL FLAG DI AGGIUDICATARIO ---
	  ------------------------------------------------------

	  declare @ValoreImportoLotto FLOAT
	  declare @idAziAggiudicatrice INT -- se è un RTI qui ci sarà l'idazi della mandataria

	  set @ValoreImportoLotto = -1
	  set @idAziAggiudicatrice = -1

		SELECT top 1 @ValoreImportoLotto  = primoClassificato.ValoreImportoLotto,
					 @idAziAggiudicatrice = isnull(primoClassificato.Aggiudicata,-1)
			FROM CTL_DOC pda with(nolock) 
					INNER JOIN Document_Bando band with(nolock) on band.idheader = pda.LinkedDoc
					INNER JOIN document_microlotti_dettagli t with(nolock) ON t.IdHeader = pda.id and t.tipodoc = 'PDA_MICROLOTTI' and t.Voce = 0  and isnull(t.cig, band.CIG) = @cig
					INNER JOIN document_pda_offerte o1 with(nolock) ON o1.IdHeader = t.IdHeader
					INNER JOIN document_microlotti_dettagli primoClassificato with(nolock) ON primoClassificato.idheader = o1.idrow 
																									and primoClassificato.NumeroLotto = t.NumeroLotto 
																									and primoClassificato.tipodoc = 'PDA_OFFERTE' 
																									and isnull(primoClassificato.voce,0) = 0 and primoClassificato.Graduatoria = 1 
																									and primoClassificato.posizione in ( 'Aggiudicatario definitivo', 'Aggiudicatario definitivo condizionato' )
																									and primoClassificato.statoriga not in ( 'esclusoEco' ,'escluso' , 'anomalo' , 'decaduta' , 'NonConforme' )
		WHERE pda.TipoDoc = 'PDA_MICROLOTTI' and pda.LinkedDoc = @idBando


		if @idAziAggiudicatrice <> -1
		BEGIN
			
			UPDATE #partecipanti_avcp
					set Aggiudicatario = '1'
				where Azienda = @idAziAggiudicatrice

			-- setto l'importo aggiudicato alla variabile di output
			set @importoAggiudicato = @ValoreImportoLotto

		END

      --------------------------------------------------------------------------------
      ---------- CREO LA CATENA DI DOCUMENTI DEGLI OPERATORI ECONOMICI ---------------
      --------------------------------------------------------------------------------

      DECLARE @identity INT
      DECLARE @Prot varchar(50)
      DECLARE @idOE INT
      DECLARE @codFisc varchar(100)
      DECLARE @denom varchar(1000)
      DECLARE @versioneOE varchar(100)
      DECLARE @idHeaderOE INT
      DECLARE @gruppo INT
      DECLARE @Protocollo VARCHAR(100)
      declare @Azienda int
      declare @RuoloPartecipante varchar(200)
      declare @estero  varchar(10)
      declare @Aggiudicatario varchar( 10 )
      declare @idOffertaInviata INT

	  declare @is_gruppo int

	  set @is_gruppo = 0

      DECLARE db2_cursor CURSOR STATIC FOR     
            SELECT id,CodiceFiscale,RagioneSociale,idCtlDoc_OffertaPartecipanti , Azienda ,
                                   RuoloPartecipante, estero, Aggiudicatario, idOffertaInviata
				FROM #partecipanti_avcp

      OPEN db2_cursor 
      FETCH NEXT FROM db2_cursor INTO @identity,@codFisc,@denom,@gruppo , @Azienda
                                         ,@RuoloPartecipante, @estero, @Aggiudicatario,@idOffertaInviata


      WHILE @@FETCH_STATUS = 0   
      BEGIN   

			set @is_gruppo = 0

			-- Se presente l'id dell'offerta vuol dire che sto controllando un record relativo ad un bando aperto
			if not @idOffertaInviata is null 
			BEGIN

				-- Se all'offerta è associato un gruppo
				IF exists ( 
							 select * 
								FROM ctl_doc D  with(nolock)
									INNER JOIN Document_offerta_partecipanti DO  with(nolock) ON D.tipodoc='OFFERTA_PARTECIPANTI' and DO.idheader=D.id 
									-- INNER JOIN Profiliutente P ON P.pfuidazi=DO.idazi 
								WHERE DO.TipoRiferimento = 'RTI' -- Prendo solo le RTI, in futuro capire cosa fare con TipoRiferimento = 'ESECUTRICI'
									and D.linkeddoc = @idOffertaInviata
							)
				BEGIN

					
					if @debug = 1
						print 'GRUPPO. Itero sul partecipante con id ' + cast(@identity as varchar) + ' codFisc : ' + @codFisc

					set @is_gruppo = 1

					DECLARE @RagSocRiferimento varchar(4000)
					declare @aziendaGruppo INT

					set @aziendaGruppo = NULL
					set @RagSocRiferimento = NULL

					--select top 1 @RagSocRiferimento = RagSocRiferimento, @aziendaGruppo = IdAziRiferimento
					--	FROM ctl_doc D with(nolock)
					--				INNER JOIN Document_offerta_partecipanti DO with(nolock) ON D.tipodoc='OFFERTA_PARTECIPANTI' and DO.idheader=D.id 
					--				-- INNER JOIN Profiliutente P ON P.pfuidazi=DO.idazi 
					--			WHERE DO.TipoRiferimento = 'RTI' -- Prendo solo le RTI, in futuro capire cosa fare con TipoRiferimento = 'ESECUTRICI'
					--				and D.linkeddoc = @idOffertaInviata

					select @RagSocRiferimento = v.value from CTL_DOC_Value v with(nolock) where idheader = @idOffertaInviata and v.DZT_Name = 'DenominazioneATI' and v.DSE_ID = 'TESTATA_RTI'	

					select @aziendaGruppo = v.Value 
						from CTL_DOC o with(nolock) 
							left join CTL_DOC_Value v with(nolock) on v.idheader = o.id and v.DZT_Name = 'IdAziRTI' and v.DSE_ID = 'TESTATA'	
						where o.linkeddoc =  @idOffertaInviata and o.TipoDoc = 'OFFERTA_PARTECIPANTI' and o.deleted = 0  and o.StatoFunzionale = 'Pubblicato'


		            -- Se devo inserire/aggiornare il gruppo
					IF ( dbo.Avcp_Inserisco_Aggiorno_OE(@cig,'',@RagSocRiferimento) = 1 )
					BEGIN

							if @debug = 1
								print 'Inserisco aggiorno ' + cast(@identity as varchar) + ' codFisc : ' + @RagSocRiferimento
							
							declare @idGruppoVecchio INT

							declare @versioneGruppo varchar(100)

							set @idGruppoVecchio = NULL
							set @versioneGruppo = NULL
							


							SELECT TOP 1 @idGruppoVecchio = doc.id,  @versioneGruppo = doc.versione
								FROM Ctl_doc doc with(nolock) --gruppo
									LEFT JOIN ctl_doc_value val with(nolock) ON doc.id = val.idHeader and val.dse_id = 'TESTATA' and val.dzt_name = 'RagioneSociale'
									INNER JOIN Ctl_doc docLott with(nolock) ON cast( doc.LinkedDoc as varchar )= docLott.versione --lotto
									INNER JOIN Document_AVCP_Lotti lott with(nolock) ON  docLott.id = lott.idHeader and lott.cig = @cig
								WHERE val.Value =  @denom

							IF not @idGruppoVecchio is null
							BEGIN

								if @debug = 1
									print 'Cancello il vecchio gruppo con id ' + cast(@idGruppoVecchio as varchar)

								-- Cancello la versione precedente del gruppo
								DELETE FROM CTL_DOC WHERE id = @idGruppoVecchio
								DELETE FROM Document_AVCP_Partecipanti WHERE idHeader = @idGruppoVecchio --cancello i vecchi membri

							END

							--------------------------
							-- CREO IL DOCUMENTO GRUPPO
							--------------------------

							INSERT INTO ctl_doc (
									 tipodoc,
									 statoFunzionale,
									 deleted,
									 JumpCheck,
									 data,
									 PrevDoc,
									 LinkedDoc,
									 Note,
									 idpfu,
									 Azienda
								)
								SELECT
									 'AVCP_GRUPPO' as tipodoc,
									 'Pubblicato',
									 0,
									 '',
									 GETDATE() as data,
									 0 as prevdoc,
									 @versioneGara as LinkedDoc, -- versione del documento lotto
									 '' as note,
									 -20 as idpfu,
									 @aziendaGruppo


						  DECLARE @idCTLDocGruppo INT
						  DECLARE @fascicoloGruppo VARCHAR(200)

						  IF @versioneGruppo = '' 
						  BEGIN
								SET @idCTLDocGruppo = Scope_identity()



								set @versioneGruppo = @idCTLDocGruppo
								--SET @fascicoloGruppo = 'AVCP-' + cast(@idCTLDocGruppo as varchar ) 
						  END
						  ELSE
						  BEGIN
								SET @idCTLDocGruppo = Scope_identity()
								--SET @fascicoloGruppo = 'AVCP-' + cast(@versioneGruppo as varchar ) 
						  END

						  set @fascicoloGruppo = @fascicoloGara

						  -- Invoco la stored che mi restituisce un protocollo per il documento appena creato
						  --EXEC ctl_GetNewProtocol 'ANAC' , '', @Protocollo output

						  -- Aggiorno versione e fascicolo perchè dipendenti dall'id tabellare appena generato
						  UPDATE ctl_doc
								SET versione = @versioneGruppo ,
									 Fascicolo = @fascicoloGruppo,
									 Protocollo = @Protocollo
								WHERE id = @idCTLDocGruppo 

						  -- inserisco nella ctl_doc_value i dati relativi alla denominazione ( RagioneSociale ) e il Tipo del gruppo
						  INSERT INTO ctl_doc_value (IdHeader, dse_id, Row, dzt_Name, value)
											VALUES  (@idCTLDocGruppo, 'TESTATA',0,'RagioneSociale',@RagSocRiferimento)

						  INSERT INTO ctl_doc_value (IdHeader, dse_id, Row, dzt_Name, value)
											VALUES  (@idCTLDocGruppo, 'TESTATA',0,'aziIdDscFormaSoc','845326')

						  INSERT INTO ctl_doc_value (IdHeader, dse_id, Row, dzt_Name, value)
											VALUES  (@idCTLDocGruppo, 'TESTATA',0,'Aggiudicatario', @Aggiudicatario)

							--------------------------
							-- CREO I MEMBRI DEL GRUPPO
							--------------------------
							INSERT INTO Document_avcp_partecipanti
								 (
									IdHeader,
									RuoloPartecipante,
									Estero,
									CodiceFiscale,
									RagioneSociale,
									Aggiudicatario
								 )
								 SELECT	--inserisco N record
										@idCTLDocGruppo as idHeader,
										dbo.getRuoloGruppo_Avcp(DO.Ruolo_Impresa),
										 CASE WHEN (upper(aziStatoLeg) = 'ITALIA' OR upper(aziStatoLeg) = 'ITALY') THEN '0'
											  ELSE '1'
										 END AS Estero,

										 dm.vatValore_FT as CodiceFiscale,
										 --CASE WHEN (upper(aziStatoLeg) = 'ITALIA' OR upper(aziStatoLeg) = 'ITALY') THEN dm.vatValore_FT
           --                              ELSE  right( '00000000000' +  isnull(azi.aziPartitaIVA ,'') , 11)
											--END AS CodiceFiscale,


										 azi.aziRagioneSociale as RagioneSociale,
										 @Aggiudicatario as Aggiudicatario
									FROM ctl_doc D with(nolock)
										INNER JOIN Document_offerta_partecipanti DO with(nolock) ON DO.idheader=D.id and DO.TipoRiferimento = 'RTI' -- Prendo solo le RTI, in futuro capire cosa fare con TipoRiferimento = 'ESECUTRICI'
										--INNER JOIN Profiliutente P ON P.pfuidazi=DO.idazi 
										INNER JOIN Aziende azi with(nolock) ON azi.idazi = DO.idazi 
										INNER JOIN Dm_Attributi dm with(nolock) ON dm.lnk = azi.idazi and dm.dztnome = 'codicefiscale'
									WHERE D.linkeddoc = @idOffertaInviata and D.tipodoc='OFFERTA_PARTECIPANTI' 




					END

				END

			END -- FINE if - Se all'offerta è associato un gruppo
			ELSE
			BEGIN
				set @is_gruppo = 0
			END
			

			IF @is_gruppo = 0 
			BEGIN

				-------------------------------------
				-- CREO IL DOCUMENTO OPERATORE DI GARA
				--------------------------------------

				if @debug = 1
					  print 'OPERATORE ECONOMICO. Itero sul partecipante con id ' + cast(@identity as varchar) + ' codFisc : ' + @codFisc

				-- Se devo inserire/aggiornare un Operatore Economico
				IF ( dbo.Avcp_Inserisco_Aggiorno_OE(@cig,@codFisc,'') = 1 )
				BEGIN

						if @debug = 1
							print 'Inserisco/aggiorno il partecipante con id ' + cast(@identity as varchar) + ' codFisc : ' + @codFisc

						SET @versioneOE = ''

						SELECT TOP 1 @versioneOE = doc.versione, @idHeaderOE=part.idHeader 
							FROM Document_AVCP_Partecipanti part with(nolock)
								INNER JOIN Ctl_doc doc with(nolock) ON doc.id = part.idheader 
								INNER JOIN Ctl_doc docLott with(nolock) ON cast( doc.LinkedDoc as varchar )= docLott.versione 
								INNER JOIN Document_AVCP_Lotti lott with(nolock) ON  docLott.id = lott.idHeader and lott.cig = @cig
							WHERE part.codiceFiscale = @codFisc

					  IF @versioneOE <> '' 
					  BEGIN

							-- Cancello la versione precedente del documento
							DELETE FROM CTL_DOC WHERE id = @idHeaderOE
							DELETE FROM Document_AVCP_Partecipanti WHERE idHeader = @idHeaderOE

					  END

					  If @@error <> 0 
					  Begin

							--Rollback transaction
							CLOSE db2_cursor    
							DEALLOCATE db2_cursor 

							return
					  end

					  INSERT INTO ctl_doc (
								 tipodoc,
								 statoFunzionale,
								 deleted,
								 JumpCheck,
								 data,
								 PrevDoc,
								 --Fascicolo,
								 LinkedDoc,
								 Note,
								 idpfu,
								 Azienda
							)
							SELECT
								 CASE when isnull(@gruppo,'') = '' then 'AVCP_OE'
											 else 'AVCP_GRUPPO'
								 END  as tipodoc,
								 'Pubblicato',
								 0,
								 '',
								 GETDATE() as data,
								 0 as prevdoc,
								 --@fascicolo as Fascicolo,
								 @versioneGara as LinkedDoc, -- versione del documento lotto
								 '' as note,
								 -20 as idpfu,
								 @Azienda
							--FROM #partecipanti_avcp WHERE id  = @identity

					  If @@error <> 0 
					  Begin

							--Rollback transaction
							CLOSE db2_cursor    
							DEALLOCATE db2_cursor 

							return
					  end

					  DECLARE @idCTLDocOE INT
					  DECLARE @fascicoloOE VARCHAR(200)

					  IF @versioneOE = '' 
					  BEGIN
							SET @idCTLDocOE = Scope_identity()
							set @versioneOE = @idCTLDocOE
							--SET @fascicoloOE = 'AVCP-' + cast(@idCTLDocOE as varchar ) 
					  END
					  ELSE
					  BEGIN
							SET @idCTLDocOE = Scope_identity()
							--SET @fascicoloOE = 'AVCP-' + cast(@versioneOE as varchar ) 
					  END

					  set @fascicoloOE = @fascicoloGara

					  -- Invoco la stored che mi restituisce un protocollo per il documento appena creato
					  --EXEC ctl_GetNewProtocol 'ANAC' , '', @Protocollo output

					  -- Aggiorno versione e fascicolo perchè dipendenti dall'id tabellare appena generato
					  UPDATE ctl_doc
							SET versione = @versioneOE ,
								 Fascicolo = @fascicoloOE,
								 Protocollo = @Protocollo
							WHERE id = @idCTLDocOE 

					  If @@error <> 0 
					  Begin

							--Rollback transaction
							CLOSE db2_cursor    
							DEALLOCATE db2_cursor 

							return
					  end
          

					INSERT INTO Document_avcp_partecipanti
							(
								IdHeader,
								RuoloPartecipante,
								Estero,
								CodiceFiscale,
								RagioneSociale,
								Aggiudicatario
							)
							SELECT
								@idCTLDocOE as idHeader,
								@RuoloPartecipante,
								@estero,
								@codFisc,
								left(@Denom,80),
								@Aggiudicatario
							--FROM #partecipanti_avcp WHERE id  = @identity

					  If @@error <> 0 
					  Begin

							--Rollback transaction
							CLOSE db2_cursor    
							DEALLOCATE db2_cursor 

							return
					  end

					  --EXEC AVCP_CONTROLLI_DOCUMENT_AVCP @idCTLDocOE

				END

      
			END -- FINE IF CHECK GRUPPO

			FETCH NEXT FROM db2_cursor INTO @identity,@codFisc,@denom,@gruppo , @Azienda
                                         ,@RuoloPartecipante, @estero, @Aggiudicatario,@idOffertaInviata

      END

      CLOSE db2_cursor    
      DEALLOCATE db2_cursor 



	  -- effetua i controlli sul lotto
	  Declare @IdLotto int 
	  
	  -- risalgo al documento dalla versione
	  select @IdLotto = id from CTL_DOC with(nolock) where tipoDoc = 'AVCP_LOTTO' and deleted = 0 and versione = @versioneGara and Statofunzionale = 'Pubblicato'

	  EXEC AVCP_CONTROLLI_DOCUMENT_AVCP @IdLotto
      

END



























GO
