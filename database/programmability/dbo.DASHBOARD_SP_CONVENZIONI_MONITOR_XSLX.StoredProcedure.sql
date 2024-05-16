USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DASHBOARD_SP_CONVENZIONI_MONITOR_XSLX]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE proc [dbo].[DASHBOARD_SP_CONVENZIONI_MONITOR_XSLX]
(
	 @Filter                        varchar(8000)
)
as
begin

	declare @AttrName						varchar(8000)
	declare @AttrValue						varchar(8000)
	declare @AttrOp 						varchar(8000)

	declare @Descrizione as varchar(1500)

	set @AttrName	= dbo.GetPos(@Filter , '#~#'  , 1 )
	set @AttrValue	= dbo.GetPos(@Filter , '#~#'  , 2 )
	set @AttrOp		= dbo.GetPos(@Filter , '#~#'  , 3 )

	declare @Cnt int 

	--la chiamata arriva anche dalla cartella Gestione Convenzioni | Erosione Macroconvenzioni 
	--in cui alcuni campi si chiamano in modo diverso:
	--sostituisco Titolo e Mandataria perchè la vista XLSX_ESPORTA_LISTINI_VIEW li restituisce con i nomi
	--			  Doc_Name e AZI_Dest
	set @AttrName = replace (@AttrName, 'Titolo','Doc_Name')
	set @AttrName = replace (@AttrName, 'Mandataria','AZI_Dest')

	--sostituisco DESCRIZIONE_CODICE_REGIONALE con Descrizione perchè la stored gestisce Descrizione
	--esattamente come DESCRIZIONE_CODICE_REGIONALE
	set @AttrName = replace (@AttrName, 'DESCRIZIONE_CODICE_REGIONALE','Descrizione')

	declare @SQLCmd			nvarchar(max)
	declare @SQLWhere		nvarchar(max)
	declare @Param varchar(8000)
	declare @Profilo as varchar(1500)
	declare @Ambito as varchar(1500)
	declare @Macro_Convenzione as varchar(max) 
	declare @StatoFunzionale as varchar(100)
	declare @CodiceAIC as nvarchar(max)
	declare @CodiceATC as nvarchar(max)
	declare @CODICE_CND as nvarchar(max)
	declare @CODICE_CPV as nvarchar(max)
	declare @PrincipioAttivo as nvarchar(max)
	declare @HandleAttrib as int

	set @HandleAttrib = 0

	set nocount on

	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp

	set @Ambito			= dbo.GetParam( 'Ambito'		, @Param ,1)
	set @Descrizione	= dbo.GetParam( 'Descrizione'	, @Param ,1)	
	set @Macro_Convenzione	= dbo.GetParam( 'Macro_Convenzione'	, @Param ,1)	
	set @StatoFunzionale  = dbo.GetParam( 'StatoFunzionale'	, @Param ,1)	
	set @CodiceAIC  = dbo.GetParam( 'CodiceAIC'	, @Param ,1)	
	set @CodiceATC  = dbo.GetParam( 'CodiceATC'	, @Param ,1)
	set @CODICE_CND  = dbo.GetParam( 'CODICE_CND', @Param ,1)
	set @CODICE_CPV  = dbo.GetParam( 'CODICE_CPV', @Param ,1)
	set @PrincipioAttivo  = dbo.GetParam( 'PrincipioAttivo', @Param ,1)
	
	set @SQLCmd = ''

	if @CodiceAIC <> '' or @CodiceATC <> '' or @CODICE_CND <> '' or @CODICE_CPV <>'' or @PrincipioAttivo <> ''
	begin
		set @HandleAttrib = 1

		--metto in una tabella temporanea le convenzioni che hanno soddisfano questi attributi 
		set @SQLCmd = '
			
			select 
				idheader as Id
					into #tempConvLotti
				from 
					document_convenzione_lotti with (nolock)
				where 1=1 
					'
		if 	@CodiceAIC <> ''
			set @SQLCmd =  @SQLCmd  + '	and codiceAic like ''%' + replace ( @CodiceAIC  , '''' , '''''' ) + '%'' '

		if @CodiceATC <> ''
			set @SQLCmd =  @SQLCmd  + ' and dbo.fn_CheckMultiValue( CodiceATC ,  '' = '' ,  ''' + replace( @CodiceATC , '''' , '''''' ) + ''' ) = 1 ' 
		
		if @CODICE_CND <> ''
			set @SQLCmd =  @SQLCmd  + ' and dbo.fn_CheckMultiValue( CODICE_CND ,  '' = '' ,  ''' + replace( @CODICE_CND , '''' , '''''' ) + ''' ) = 1 ' 
		
		if @CODICE_CPV <> ''
			set @SQLCmd =  @SQLCmd  + ' and dbo.fn_CheckMultiValue( CODICE_CPV ,  '' = '' ,  ''' + replace( @CODICE_CPV , '''' , '''''' ) + ''' ) = 1 ' 
		
		if @PrincipioAttivo <> ''
			set @SQLCmd =  @SQLCmd  + ' and dbo.fn_CheckMultiValue( PrincipioAttivo ,  '' = '' ,  ''' + replace( @PrincipioAttivo , '''' , '''''' ) + ''' ) = 1 ' 
		

	end


	set @Macro_Convenzione = replace ( @Macro_Convenzione , '''' , '' )
	--print @Macro_Convenzione
	
	--costruisco select da eseguire
	
	
	--ricavo la condizone di where di base basata sulle colonne della vista  da cui tolgo l'ambito per gestirlo separatamente
	set @SQLWhere = dbo.GetWhere( 'XLSX_ESPORTA_LISTINI_VIEW' , 'V',replace( replace(  @AttrName , 'Ambito' , '' ) , 'Macro_Convenzione' , '' )  ,  @AttrValue ,  @AttrOp )

	set @SQLCmd =  @SQLCmd + '
			select 
				C.* 
			from 
				XLSX_ESPORTA_LISTINI_VIEW C '
	
	if @Descrizione <> '' 
	begin
		set @SQLCmd = @SQLCmd + ' 
			inner join ( 
						select 
							distinct idheader 
							from 
								document_microlotti_dettagli d with(nolock) 
							where 
								d.tipodoc = ''CONVENZIONE'' 
								and d.DESCRIZIONE_CODICE_REGIONALE like ''%' + replace ( @Descrizione  , '''' , '''''' ) + '%'' ) as D on d.idheader = C.idConvenzione '
	end
	
	--se devo gestire i nuovi attributi allora metto in join con la tabella temporanea delle convenzioni che
	--soddisfano quegli attributi
	if @HandleAttrib = 1
	begin

		--metto in join con le convenzioni che soddisfano la ricerca per @CodiceAIC
		set @SQLCmd = @SQLCmd + '
			
			inner join #tempConvLotti CL on CL.id =  C.idConvenzione
	
		'

	end


	if 	@SQLWhere <> ''
		set   @SQLCmd = @SQLCmd + ' WHERE ' + @SQLWhere
	else
		set   @SQLCmd = @SQLCmd + ' WHERE 1 = 1 '

	if @Ambito  <> ''
		set   @SQLCmd = @SQLCmd + ' and Ambito in ( ''' + replace( @Ambito , '###' , ''',''' ) + ''' )  '
	

	if @Macro_Convenzione <> ''
			set   @SQLCmd = @SQLCmd + ' and ''' +  @Macro_Convenzione +   ''' like ''%###'' + Macro_Convenzione + ''###%''  '

	--considero solo le convenzioni pubblicate
	--if @StatoFunzionale <>''
	--	set   @SQLCmd = @SQLCmd + ' and c.statofunzionale = ''' + @StatoFunzionale + ''' '

--		set   @SQLCmd = @SQLCmd + ' and Macro_Convenzione in ( ''' + replace( @Macro_Convenzione , '###' , ''',''' ) + ''' )  '


	--if @Filter <> ''
	--	set   @SQLCmd = @SQLCmd + ' and ( ' + @Filter + ' ) '
	
	--if rtrim( @Sort ) <> ''
	--	set @SQLCmd=@SQLCmd + ' order by ' + @Sort




	--print @SQLCmd
	exec (@SQLCmd)

	--select @cnt = count(*) from #temp
	--set @cnt = @@rowcount



end





GO
