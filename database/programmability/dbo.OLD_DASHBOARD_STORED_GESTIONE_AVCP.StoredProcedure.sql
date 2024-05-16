USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DASHBOARD_STORED_GESTIONE_AVCP]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[OLD_DASHBOARD_STORED_GESTIONE_AVCP]
(
	@IdPfu							int,
	@AttrName						varchar(8000),
	@AttrValue						varchar(8000),
	@AttrOp 						varchar(8000),
	@Filter                        varchar(8000),
	@Sort                          varchar(8000),
	@Top                           int,
	@Cnt                           int output
)
AS

	declare @Param varchar(8000)
	declare @Ente varchar(100)
	declare @Anno varchar(100)
	declare @codicefiscale varchar(50)
	declare @elenco_ente varchar(8000)
	declare @visualizza as varchar (50)	
	declare @Errore as nvarchar(2000)
	declare @Warning_Filtro as varchar(50)
	declare @CIG as varchar(50)
	declare @Oggetto as varchar(50)
	declare @DataPubblicazioneda    varchar(50)
	declare @DataPubblicazionea    varchar(50)

	set @Errore = ''

	SET NOCOUNT ON

	set @Param = Replace(@AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp,' ','')
	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp
    --print @Param

	declare @SQLCmd			varchar(8000)
	declare @SQLWhere		varchar(8000)

	set @SQLWhere=''

	--criteri di ricerca
	set @Ente	= dbo.GetParam( 'Azi_Ente' , @Param,1) 
	set @Anno =dbo.GetParam( 'Anno' , @Param,2) 
	set @visualizza =dbo.GetParam( 'Visualizza_Gara' , @Param,1) 
	set @Warning_Filtro=dbo.GetParam( 'Warning_Filtro' , @Param,1)
	set @CIG=dbo.GetParam( 'CIG' , @Param,1)
	set @Oggetto=dbo.GetParam( 'Oggetto' , @Param,1)

	set @DataPubblicazioneda		    = left( replace( dbo.GetParam( 'DataPubblicazioneda' , @Param ,1) ,'''','''''') , 10 )
	set @DataPubblicazionea		    = left( replace( dbo.GetParam( 'DataPubblicazionea' , @Param ,1) ,'''','''''') , 10 )

	Select @visualizza=
	case 
		when @visualizza = 'Attivi' then '''Pubblicato'''  
		when @visualizza = 'Cancellati'	then '''Annullato'''  
		else '''Pubblicato'',''Annullato'''  
	end

	--IF @Anno > year(getdate()) -1 
	--BEGIN
	--	set @Errore = 'Selezionare un anno inferiore al corrente'
	--END

	select @codicefiscale=vatValore_FT from dm_attributi where lnk = @Ente and dztnome='codicefiscale'

	IF @codicefiscale <> ''
	BEGIN
		set @elenco_ente = dbo.GetIdAzi_from_CodiceFiscale ( @codicefiscale )
	END
	ELSE
	BEGIN
		set @elenco_ente=@Ente
	END

	IF @Errore = ''
	BEGIN

		set @SQLCmd = 'select C.*,L.cig,L.Oggetto as Descrizione,
							C.tipodoc as OPEN_DOC_NAME, 
							case when REPLACE( ISNULL(cast(L.Warning as nvarchar(4000)),''''), ''<br>'','''') = '''' then ''../domain/ReportOK.gif'' else ''../domain/ReportWarning.gif'' end as FNZ_WARNING,
							case when C.StatoFunzionale = ''Pubblicato'' then ''../toolbar/Delete_Light.GIF'' else ''../toolbar/ripristina.png'' end as FNZ_DEL,
							L.DataPubblicazione
					   from CTL_DOC C with(nolock)
								inner join document_AVCP_lotti L with(nolock) on L.idheader=C.id and L.Anno='''+@Anno+'''
					   where C.azienda in ( '+ @elenco_ente + ') and C.tipodoc in ( ''AVCP_GARA'',''AVCP_LOTTO'') and ISNULL(C.LinkedDoc,0)=0 and C.deleted=0 and StatoFunzionale in (' + @visualizza + ')'

	END

	----se non sono presenti documenti per l'ente e per l'anno li popolo
	--IF NOT EXISTS ( select *
	--				   from CTL_DOC C 
	--				   inner join document_AVCP_lotti L on L.idheader=C.id and L.Anno=@Anno
	--				   where C.azienda in ( select * from dbo.split(@elenco_ente,',') ) and C.tipodoc in ( 'AVCP_GARA','AVCP_LOTTO') and
	--				    C.deleted=0 and StatoFunzionale in ('Pubblicato','Annullato')
	--			 )
	--BEGIN
	--	--Exec AVCP_POPOLA @Anno,@elenco_ente
	--	print  @Anno+','+@elenco_ente
	--END
		
	if @Errore = ''
	begin
		if @Oggetto <> ''
		begin
			set  @SQLCmd = @SQLCmd	+ ' and L.Oggetto like ''' + @Oggetto + ''''
		end	
		if @Warning_Filtro <> '' and @Warning_Filtro = 'NO'
		begin
			set @SQLCmd = @SQLCmd + ' and cast( isnull(L.Warning,'''') as nvarchar(4000)) ='''''
		end
		if @Warning_Filtro <> '' and @Warning_Filtro = 'SI'
		begin
			set @SQLCmd = @SQLCmd + ' and cast( isnull(L.Warning,'''') as nvarchar(4000)) <> '''''
		end
		if @CIG <> ''
		BEGIN
			set @SQLCmd = @SQLCmd + ' and C.id in (Select idheader from  document_AVCP_lotti where CIG like ''' + @CIG + ''')'
		END
		if @DataPubblicazioneda <> ''
		BEGIN
			set @SQLCmd = @SQLCmd + ' and  convert( varchar(10) , L.DataPubblicazione , 121 ) >= ''' + @DataPubblicazioneda + '''  '
		END
		if @DataPubblicazionea <> ''
		BEGIN
			set @SQLCmd = @SQLCmd + ' and  convert( varchar(10) , L.DataPubblicazione , 121 ) <= ''' + @DataPubblicazionea + '''  '
		END

		--set @SQLCmd = @SQLCmd + ' order by DataPubblicazione asc'
		if @Sort <> ''
			set @SQLCmd = @SQLCmd + ' order by ' + @Sort

		exec (@SQLCmd)
	    --print @SQLCmd

	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Descrizione
	end
	
	set nocount off


















GO
