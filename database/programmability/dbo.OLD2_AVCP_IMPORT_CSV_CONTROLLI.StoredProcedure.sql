USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_AVCP_IMPORT_CSV_CONTROLLI]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OLD2_AVCP_IMPORT_CSV_CONTROLLI]  ( @idDoc int )
AS
BEGIN
	declare @ATTIVA_ALG_MINISTESTO nvarchar(50)
	select 	@ATTIVA_ALG_MINISTESTO=dbo.PARAMETRI('CONTROLLO_CIG_VALIDO','ATTIVA_ALG_MINISTESTO' ,'ATTIVO','YES',-1)
	
	-- CONTROLLO IL CAMPO OGGETTO SULLA GARA MENO 250 CARATTERI
	update document_AVCP_Import_CSV 
		set Warning=ISNULL(cast( Warning as nvarchar(max)),'') + ' Il Campo Oggetto non deve superare i 250 caratteri.' --+ '</br>'
				where idHeader=@idDoc and len(cast( Oggetto as nvarchar(max))) > 250

	-- NON LO FACCIAMO IN SEGUITO ALLA RICHIESTA DI IC, DIVENTATA DI SCAFFALE E PER PUGLIA
	-- CON ATT.351314 
	-- VERIFICO SE FARE IL CONTROLLO SUGLI AGGIUDICATARI MULTIPLI
	-- ( aggiunto per evitare la customizzazione per empulia che non voleva il controllo sugli aggiudicatari per colpa degli accordi quadro gestiti 'male' )
	--IF NOT EXISTS ( select * from CTL_Relations with(nolock) where REL_Type = 'AVCP_CONTROLLI_DOCUMENT_AVCP' and REL_ValueInput = 'aggiudicatari_multipli' and REL_ValueOutput = 'si' )
	--BEGIN

	--	---Controllo che sia un solo aggiudicatario per la gara
	--	select 	cig into #t
	--		from document_AVCP_Import_CSV 	with(nolock)
	--		where idheader=@idDoc and Aggiudicatario=1
	--			group by cig , Aggiudicatario
	--			having count(Aggiudicatario) > 1
		
	--	update document_AVCP_Import_CSV 
	--		set Warning = ISNULL(cast( Warning as nvarchar(4000)),'') + ' Sono presenti più operatori economici come aggiudicatari.' --+ '</br>' 
	--	where idheader=@idDoc and Cig in ( select Cig from #t )		
		
	--	drop table #t
	--END

	----------------------------------------
	--- CONTROLLO VALIDITÀ CODICE FISCALE --
	----------------------------------------
	update document_AVCP_Import_CSV 
		set Warning=ISNULL(cast( Warning as nvarchar(max)),'') + ' Codice Fiscale operatore economico errato.'-- + '</br>'
				where idHeader=@idDoc and dbo.fn_checkCF_ANAC(Codicefiscale, Estero) = 0 and Codicefiscale <> ''

	-------------------------------------
	--CONTROLLO SU NUMERO GARA AUTORITA -
	-------------------------------------
	update document_AVCP_Import_CSV 
		set Warning=ISNULL(cast( Warning as nvarchar(max)),'') + ' CIG non valido.'-- + '</br>'
				where idHeader=@idDoc  and dbo.controllo_cig_valido(cig,@ATTIVA_ALG_MINISTESTO) <> 1 and left(cig,4) <> 'INT-' and left(cig,4) <> 'EXT-'


	-----------------------------------------------------------------
	-- CONTROLLO SE SONO PRESENTI RAGGRUPAMENTI CON UN SOLO MEMBRO --
	-----------------------------------------------------------------
		select 	cig into #t1
			from document_AVCP_Import_CSV 	with(nolock)
			where idheader=@idDoc and Gruppo <> ''
				group by cig,gruppo
				having count(gruppo) < 2

	update document_AVCP_Import_CSV 
		set Warning=ISNULL(cast( Warning as nvarchar(max)),'') + ' Tutti i raggruppamenti devono avere almeno 2 membri.'-- + '</br>'
				where idheader=@idDoc and Cig in ( select Cig from #t1 )	
	drop table #t1

	-------------------------------------------- 
	-- WARNING PER LA SCELTA CONTRAENTE VUOTA --
	--------------------------------------------	
	select   cig into #t2
		from document_AVCP_Import_CSV with(nolock)
		where idheader=@idDoc 
			group by cig
			having max(Scelta_contraente) = ''

	update document_AVCP_Import_CSV 
		set Warning=ISNULL(cast( Warning as nvarchar(max)),'') + ' Scelta contraente vuota.'-- + '</br>'
				where idHeader=@idDoc  and Cig in ( select Cig from #t2 )
				
	drop table #t2
END
	
-------------------------------------
--FINE NUOVA STORED-
-------------------------------------
			
		
GO
