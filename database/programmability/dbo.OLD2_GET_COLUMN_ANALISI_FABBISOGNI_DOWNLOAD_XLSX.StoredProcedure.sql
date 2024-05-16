USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_GET_COLUMN_ANALISI_FABBISOGNI_DOWNLOAD_XLSX]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec GET_COLUMN_ANALISI_FABBISOGNI_DOWNLOAD_XLSX 71495, 1

CREATE PROC [dbo].[OLD2_GET_COLUMN_ANALISI_FABBISOGNI_DOWNLOAD_XLSX] ( @idDoc INT, @colonneEnte INT ) as
BEGIN
	
	-- l'idDoc passato è l'id del documento ANALISI_FABBISOGNI

	--drop table #Temp

	DECLARE @RigaModello INT
	DECLARE @campo varchar(4000)
	DECLARE @descrizione nvarchar(4000)
	DECLARE @formula varchar(4000)
	DECLARE @filtroColonna varchar(500)
	DECLARE @idModello INT

	set @idModello = -1

	-- nel linkeddoc di 'ANALISI_FABBISOGNI' c'è il riferimento del BANDO_FABBISOGNI 
	select  @idModello = modello.id
		from ctl_doc analisi with(nolock) 
				INNER JOIN CTL_DOC modello ON modello.linkeddoc = analisi.linkeddoc and modello.tipodoc = 'CONFIG_MODELLI_FABBISOGNI'
		where analisi.id = @idDoc --ANALISI_FABBISOGNI


	-- se 1 do in output le colonne richieste dall'ente. se 0 do in outut quelle lato fornitori
	IF @colonneEnte = 1
		set @filtroColonna  = 'Fabb_Richiesta'
	else
		set @filtroColonna  = 'Fabb_Questionario'

	-- preparo una tabella temporanea dove inserire le colonne
	SELECT  top 0 MA_DZT_Name as DZT_Name , 0 as DZT_Type , MA_DescML as Caption , 0 as MA_Order, MA_DescML as DZT_Format
		into #Temp
		from LIB_ModelAttributes 
		where MA_MOD_ID = 'XXX'

	-- Recupero le righe che hanno per la colonna 'Richiesta' il valore 'obbligatorio' o 'scrittura'.
	DECLARE curs CURSOR STATIC FOR     
		select [Row] from CTL_DOC_Value with(nolock) where idheader = @idModello and dse_id = 'MODELLI' and dzt_name = @filtroColonna and value IN ( 'obblig' ,'scrittura' ) order by [Row] asc 

	OPEN curs 
	FETCH NEXT FROM curs INTO @RigaModello

	--print ' --- COLONNE FISSE PER LA PARTE ''RICHIESTA'' --- '

	WHILE @@FETCH_STATUS = 0   
	BEGIN

		set @campo = ''
		set @formula = ''
		set @descrizione = ''

		select @campo = Value from CTL_DOC_Value with(nolock) where idheader = @idModello and dse_id = 'MODELLI' and dzt_name = 'DZT_Name' and isnull(value,'') <> '' and [Row] = @RigaModello
		select @descrizione = Value from CTL_DOC_Value where idheader = @idModello and dse_id = 'MODELLI' and dzt_name = 'Descrizione' and isnull(value,'') <> '' and [Row] = @RigaModello

		--print @campo

		insert into #Temp ( DZT_Name , DZT_Type , Caption , MA_Order, DZT_Format)
			SELECT  @campo , L.DZT_Type , @descrizione as Caption , @RigaModello, isnull(DZT_Format,'') as dzt_format
			from LIB_Dictionary L 
			where dzt_name = @campo

		FETCH NEXT FROM curs INTO @RigaModello

	END  

	CLOSE curs   
	DEALLOCATE curs

	select DZT_Name , DZT_Type , dbo.CNV( Caption, 'I') as Caption, MA_Order, isnull(DZT_Format,'') as DZT_Format
				from #Temp order by MA_Order

END

GO
