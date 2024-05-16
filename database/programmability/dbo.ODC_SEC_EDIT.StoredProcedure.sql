USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ODC_SEC_EDIT]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ODC_SEC_EDIT] ( @idProc INT, @secName varchar(100) = '' )
AS

	SET NOCOUNT ON

	-- Questa stored serve per accentrare le logiche di editabilità di tutte le sezioni del BANDO_GARA.

	--	E' stata creata a seguito della necessità di aggiungere una readonly condition su tutte le sezioni meno che sul quelle degli atti.
	--	La condizione di readonly di default bloccherà l'editabilità della gara se (condizioni in AND ) :
	--		1. ho creato l'appalto lato PCP/ANAC ( quindi ho valorizzato il campo "Id Appalto ANAC", colonna pcp_CodiceAppalto )
	--		2. NON sono sul secondo giro di una procedura in 2 fasi con interop ( nella seconda fase quindi NON devo rendere readonly tutto anche se ho pcp_CodiceAppalto, ottenuto nella prima fase )
	--	NOTA : In questa condizione per sbloccare la gara bisogna passare da un cancella appalto

	--	Per tutte quelle sezioni che invece avevano gia una condizione di readonly la spostiamo qui sotto un IF con il nome della sezione ed alla precedente
	--		logica aggiungiamo quella di default sopra citata.

	DECLARE @pcp_CodiceAppalto VARCHAR(100) = ''
	DECLARE @garaInterop INT = 0
	DECLARE @secondaFaseInterop INT = 0
	DECLARE @tipobandogara varchar(10)
	DECLARE @readOnly INT = 0
	DECLARE @TipoProceduraCaratteristica varchar(100) = ''
	DECLARE @TipoSceltaContraente varchar(100) = ''
	DECLARE @GestioneQuote varchar(100) = ''

	select @pcp_CodiceAppalto = pcp_CodiceAppalto
		from Document_PCP_Appalto with (nolock)
		where idHeader = @idProc

	set @garaInterop = dbo.attivo_INTEROP_Gara(@idProc) --select sulla Document_E_FORM_CONTRACT_NOTICE e lib_dictionary

	--select  @tipobandogara = tipobandogara,
	--		@TipoProceduraCaratteristica = TipoProceduraCaratteristica,
	--		@TipoSceltaContraente = TipoSceltaContraente,
	--		@GestioneQuote = GestioneQuote
	--	from Document_Bando with(nolock)
	--	where idHeader = @idProc

	

	------------------------
	-- CONDIZIONE DI BASE --
	------------------------
	IF @garaInterop = 1 and @pcp_CodiceAppalto <> '' 
		set @readOnly = 1

	


	IF @readOnly = 1
		select 'SEZIONE_READONLY' as SEC_READ_ONLY
	ELSE
		select top 0 'SEZIONE_EDITABILE' as SEC_READ_ONLY

	
GO
