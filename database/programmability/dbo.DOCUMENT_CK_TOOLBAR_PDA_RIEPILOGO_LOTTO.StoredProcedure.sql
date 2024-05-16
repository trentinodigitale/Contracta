USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_CK_TOOLBAR_PDA_RIEPILOGO_LOTTO]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- in sostituzione della vista PDA_DRILL_MICROLOTTO_TESTATA_VIEW per il documento PDA_RIEPILOGO_LOTTO
CREATE PROCEDURE [dbo].[DOCUMENT_CK_TOOLBAR_PDA_RIEPILOGO_LOTTO]( @DocName nvarchar(500) , @IdDoc as nvarchar(500) , @idUser int )
AS
BEGIN
	
	SET NOCOUNT ON
	
	-- Appena possibile rimuovere l'uso della vista PDA_DRILL_MICROLOTTO_TESTATA_VIEW e spostare le logiche in questa stored, così da ottimizzare i tempi di risposta
	select * into #condizioni_toolbar from PDA_DRILL_MICROLOTTO_TESTATA_VIEW where id = @IdDoc

	declare @statoRiga varchar(1000)
	declare @idGara int = 0

	select  @statoRiga = StatoRiga,
			@idGara = b.LinkedDoc
		from document_microlotti_dettagli a with(nolock) 
				inner join ctl_doc b with(nolock) on b.id = a.IdHeader
		where a.id = @IdDoc

	DECLARE @bAttivaCan29 varchar(1) = '0'

	-- Per rendere la modifica retrocompatibile (quindi permettere il rilascio di questa stored senza le attività degli eforms ) testiamo l'esistenza della tabella
	IF exists (SELECT * FROM sys.objects  WHERE name='Document_E_FORM_PAYLOADS' and type='U' )
	BEGIN	

		--se sulla gara è stato generato con successo il contract notice 
		--	e se lo stato del lotto è terminale
		IF EXISTS ( select idrow from Document_E_FORM_PAYLOADS with(nolock) where idHeader = @idGara and operationType = 'CN16' )
				AND
			@StatoRiga in ('AggiudicazioneDef','interrotto','NonGiudicabile','Revocato','Deserta', 'NonAggiudicabile')
		BEGIN
			set @bAttivaCan29 = '1'
		END

	END

	-- Recupero il flag di attivazione relativo all'attivazione del requisito certification_req_33223 (Art.36 comma 2)
	declare @AttivaArt36 varchar(2) = (select dbo.Parametri('CERTIFICATION','certification_req_33223','Visible','0','-1'))

	declare @VisibleArt36 int = 0

	-- Salgo sui documenti PDA_ART_36 in left join per ottenere 2 informazioni: Se esite un Documento PDA_ART_36 e se quest'ultimo è in stato confermato.
	-- Se queste condizioni sono verificate allora posso settare il flag di attivazione Comunicazione a 1 altrimenti 0
	-- Se @VisibleArt36 è a 0 allora si può procedere, altrimenti vuol dire che ci sono righe null, ovvero condizioni non soddisfatte e la join va a vuoto
	select 
		@VisibleArt36 = Count(case when D.id is null then 1 end)
		from
			(
				select top 5 
					Id, idRowLottoBando, Graduatoria
					from 
						PDA_DRILL_MICROLOTTO_LISTA_VIEW PDA with (nolock)
					where idRowLottoBando = @IdDoc and Graduatoria is not null
					order by Graduatoria asc
			) as PDA
			left join CTL_DOC D with (nolock) on PDA.id = D.linkeddoc 
				and TipoDoc = 'PDA_ART_36' 
				and deleted = 0
				and statofunzionale = 'Confermato'


	select a.*
		  , @bAttivaCan29 as attivaCan29

          -- Per distinguere GGAP
          , CASE
                WHEN (SELECT CHARINDEX('SIMOG_GGAP', (SELECT DZT_ValueDef FROM LIB_Dictionary WITH (NOLOCK) WHERE dzt_name = 'SYS_MODULI_GRUPPI'))) > 1
                    THEN 1
                ELSE 0
            END AS isGgap
          -- Per GGAP - fine
		  ,@AttivaArt36 as AttivaArt36
		  ,@VisibleArt36 as VisibleArt36

		from #condizioni_toolbar a

	drop table #condizioni_toolbar

END

GO
