USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_LOAD_SEC_PDA_LST_BUSTE_TEC_TESTATA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[DOCUMENT_LOAD_SEC_PDA_LST_BUSTE_TEC_TESTATA](  @DocName nvarchar(500) , @Section nvarchar (500),  @IdDoc as nvarchar(500) , @idUser int ) as

BEGIN
	set nocount on

	--declare @IdDoc as nvarchar(500)
	--set @IdDoc = 344420

	declare @IdGara as int
	declare @IdPda as int
	declare @COM_ID int

	--recupero le colonne dalla PDA_LISTA_MICROLOTTI_VIEW
	SELECT
			l.id -- id della Document_MicroLotti_Dettagli
			,l.CIG as CIG_LOTTO
			,l.NumeroLotto
			,l.Descrizione
			,l.StatoRiga
			,l.aziRagioneSociale
			,l.ValoreImportoLotto
			,l.num_criteri_eco
			,l.ValutazioneSoggettiva
			,case when l.StatoRiga in ( 'daValutare', 'InValutazione' ) then '1' else '0' end as InValutazione
			, l.idDoc -- PDA_MICROLOTTI nella CTL_DOC
            --, l.tipodoc -- PDA_MICROLOTTI

		into #L

	FROM 
		PDA_LISTA_MICROLOTTI_VIEW l with(nolock)
	WHERE 
		id = @IdDoc
        
	-- recupero id della PDA_MICROLOTTI
	select @IdPda = idDoc from #L


	--recupero le informazioni dalla sezione di testata PDA_MICROLOTTI_VIEW_TESTATA
	SELECT
			l.id -- PDA_MICROLOTTI
            , l.CIG_LOTTO, l.NumeroLotto, l.Descrizione, l.StatoRiga, l.aziRagioneSociale, l.ValoreImportoLotto, l.num_criteri_eco, l.ValutazioneSoggettiva
			, l.InValutazione
			, t.IdPfu
			, t.IdDoc
			, t.TipoDoc -- PDA_MICROLOTTI
			, t.StatoDoc
			, t.Data
			, t.Protocollo
			, t.PrevDoc
			, t.Deleted
			, t.Titolo
			, t.Body
			, t.Azienda
			, t.StrutturaAziendale
			, t.DataInvio
			, t.DataScadenza
			, t.ProtocolloRiferimento
			, t.ProtocolloGenerale
			, t.Fascicolo
			, t.Note
			, t.DataProtocolloGenerale
			, t.LinkedDoc -- BANDO_GARA
			, t.SIGN_HASH
			, t.SIGN_ATTACH
			, t.SIGN_LOCK
			, t.JumpCheck
			, t.StatoFunzionale
			, t.Destinatario_User
			, t.Destinatario_Azi
			, t.RichiestaFirma
			, t.NumeroDocumento
			, t.DataDocumento
			, t.Versione
			, t.VersioneLinkedDoc
			, t.idRow
			, t.idHeader -- PDA_MICROLOTTI
			, t.ImportoBaseAsta
			, t.ImportoBaseAsta2
			, t.DataAperturaOfferte
			, t.ModalitadiPartecipazione
			, t.CriterioFormulazioneOfferte
			, t.CUP
			, t.CIG
			, t.DataIISeduta
			, t.NumeroIndizione
			, t.DataIndizione
			, t.NRDeterminazione
			, t.Oggetto
			, t.DataDetermina
			, t.ListaModelliMicrolotti
			, t.ModelloPDA
			, t.ModelloPDA_DrillTestata
			, t.ModelloPDA_DrillLista
			, t.ModelloOfferta_Drill
			, t.divisione_lotti 
			, t.PresAgg
			, t.PresTec
			, t.Concessione
			, t.AttivaFilePending
			, t.Lista_Utenti_Commissione
			, t.UserRUP	
			, t.PresTec as presidente_commissione_b 
		into #L2

	FROM 
		#L l
		inner join PDA_MICROLOTTI_VIEW_TESTATA t with(nolock) on l.idDoc = t.id
  

	drop table #L


	--recupero id della Gara da id della PDA_MICROLOTTI
	select @IdGara = linkeddoc from ctl_doc with (nolock) where id = @IdPda


	--RECUPERO ID DELLA COMMISSIONE A PARTIRE DA ID DELLA GARA
	SELECT 
		@COM_ID = COM.ID
		FROM
			ctl_doc COM with(nolock) 
		WHERE 
			linkeddoc =  @IdGara and COM.tipodoc='COMMISSIONE_PDA' and COM.deleted=0 
			and COM.statofunzionale='pubblicato'
            

    --DECLARE @idPdaMicrolotti INT -- PDA_MICROLOTTI
    --DECLARE @idBando INT -- BANDO_GARA
    DECLARE @idRichiestaCig INT -- RICHIESTA_CIG

        --SELECT @idPdaMicrolotti = IdHeader FROM Document_MicroLotti_Dettagli MD WITH (NOLOCK) WHERE Id=@IdDoc -- Ottengo il doc PDA_MICROLOTTI
        --SELECT @idBando=LinkedDoc FROM CTL_DOC WHERE Id=@IdPda -- Ottengo il doc BANDO_GARA
        SELECT @idRichiestaCig=Id FROM CTL_DOC WHERE LinkedDoc=@IdGara AND TipoDoc='RICHIESTA_CIG' AND Deleted=0 -- Ottengo il doc RICHIESTA_CIG



	-- VERIFICHIAMO LA PRESENZA DELL'AMPIEZZA DI GAMMA
	declare @idmodelloAcquisto int
	declare @idmodelloAmpiezzaGamma int
			
	select @idmodelloAcquisto = Value						
		from CTL_DOC_Value with(nolock)
		where idheader = @IdGara and DSE_ID = 'TESTATA_PRODOTTI' and DZT_Name = 'id_modello' --idModello acquisto

	select @idmodelloAmpiezzaGamma = Value 
		from CTL_DOC_Value with(nolock)
		where IdHeader = @idmodelloAcquisto and DSE_ID = 'AMBITO' and DZT_Name = 'TipoModelloAmpiezzaDiGamma' --idmodelloAmpiezzaGamma
			
	declare @PresenzaAmpiezzaDiGamma varchar(2)
	set @PresenzaAmpiezzaDiGamma = 'no'

	--controllo se il modello di ampiezza di gamma prevede busta tecnica 
	if exists (select * from ctl_doc_value with(nolock) where IdHeader = @idmodelloAmpiezzaGamma and DZT_Name = 'MOD_OffertaINPUT' and DSE_ID = 'MODELLI' and Value <> '')  
	begin
		set @PresenzaAmpiezzaDiGamma = 'si'
	end

    -- Restituisco i dati
	SELECT 
			l.*
			,c.*
			,P.PUNTEGGI_ORIGINALI	
			, 1 as APERTURA_BUSTE_TECNICHE
			, dbo.CAN_CREATE_COMUNICAZIONI(@idUser , @COM_ID, 'VERIFICA_INTEGRATIVA') as CAN_CREATE_COM_INTEGRATIVA_TEC

            -- Per distinguere GGAP
            , CASE
                  WHEN (SELECT CHARINDEX('SIMOG_GGAP', (SELECT DZT_ValueDef FROM LIB_Dictionary WITH (NOLOCK) WHERE dzt_name = 'SYS_MODULI_GRUPPI'))) > 1
                      THEN 1
                  ELSE 0
              END AS isSimogGgap
            --, (SELECT [Value] FROM CTL_DOC_Value WHERE IdHeader = @idBando AND DSE_ID = 'GGAP' AND DZT_Name='idDocR') AS idDocR
            , @idRichiestaCig AS idDocR
            -- Per GGAP - fine

			, @PresenzaAmpiezzaDiGamma as PresenzaAmpiezzaDiGamma
	FROM 
		#L2 l
		inner join BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO c with(nolock) ON c.idBando  = l.LinkedDoc  and c.N_Lotto = l.NumeroLotto 
		cross join ( select dbo.PARAMETRI('PDA_MICROLOTTI','PUNTEGGI_ORIGINALI','SHOW','NO',-1) as PUNTEGGI_ORIGINALI  ) as P
	WHERE id = @IdDoc


	drop table #L2

END
GO
