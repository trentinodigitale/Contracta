USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SP_DASHBOARD_VIEW_CATALOGO_ME]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--USE [AFLink_PA_Dev]
--GO

--/****** Object:  StoredProcedure [dbo].[SP_DASHBOARD_VIEW_CATALOGO]    Script Date: 16/09/2022 12:44:29 ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO


--	select * from DASHBOARD_VIEW_PRODOTTI_CATALOGO_MEA  where 1 = 1 
-- --and   ALL_FIELD  like  '%%%' ----
-- ORDER BY descrizione , id asc


--exec SP_DASHBOARD_VIEW_CATALOGO_ME 45094 , 'ALL_FIELD' , '''%%%''' , ' like ' , '' , 'descrizione , id asc' , 20, 1





CREATE proc [dbo].[SP_DASHBOARD_VIEW_CATALOGO_ME]
(@IdPfu							int,
 @AttrName						varchar(8000),
 @AttrValue						varchar(8000),
 @AttrOp 						varchar(8000),
 @Filter                        varchar(8000),
 @Sort                          varchar(8000),
 @Top                           int,
 @Cnt                           int output
)
as

	declare @Operatore as varchar(10)

	declare @Param						varchar(8000)
	declare @IdentificativoIniziativa	varchar(250)
	declare @Convenzione				varchar(250)
	declare @Codice						varchar(250)
	declare @Descrizione				varchar(250)
	declare @AREA_DI_CONSEGNA			varchar(max)
	declare @ClasseIscrizFILTRO				varchar(max)
	
	set nocount on


	set @Param = replace ( replace( @AttrName , 'ClasseIscriz' , 'ClasseIscrizFiltro' ) , 'AREA_DI_CONSEGNA' , 'AREA_DI_CONSEGNAFiltro' )  + '#~#' + @AttrValue + '#~#' + @AttrOp
	


	declare @SQLCmd			varchar(max)
	declare @SQLWhere		varchar(8000)
	set @SQLWhere = dbo.GetWhere( 'DASHBOARD_VIEW_PRODOTTI_CATALOGO_MEA' , 'V',  replace ( replace( @AttrName , 'ClasseIscriz' , 'ClasseIscrizFiltro' ) , 'AREA_DI_CONSEGNA' , 'AREA_DI_CONSEGNAFiltro' ) ,  @AttrValue ,  @AttrOp )



	declare @CrLf varchar (10)
	set @CrLf = '
'
	-- criteri di ricerca
	--print @Param
	--set @IdentificativoIniziativa	=  dbo.GetParam( 'IdentificativoIniziativa' , @Param ,1)
	--set @Convenzione	        	=  dbo.GetParam( 'Convenzione' , @Param ,1) 
	--set @Codice						=  dbo.GetParam( 'Codice' , @Param ,1) 
	--set @Descrizione				=  dbo.GetParam( 'Descrizione' , @Param ,1) 

	--set @Macro_Convenzione			=  dbo.GetParam( 'Macro_Convenzione' , @Param ,1) 
	
	
	set @ClasseIscrizFILTRO			= replace( dbo.GetParam( 'ClasseIscrizFiltro' , @Param ,1) ,'''','''''')

	set @AREA_DI_CONSEGNA		=  dbo.GetParam( 'AREA_DI_CONSEGNAFiltro' , @Param ,1) 
	
	
	
	set @SQLCmd =  'select 
	distinct C.* from DASHBOARD_VIEW_PRODOTTI_CATALOGO_MEA C '
	--case
	--	when C.FotoProdotto = '' then ''qui va immagine''
	--	else C.FotoProdotto 
	--end 

	if @ClasseIscrizFILTRO <> ''
	begin	

		declare @ColPathFather as varchar(500)
		declare @ColPath as varchar(500)
		
		-- preparo una tabella temporanea con i percorsi gerarchici selezionati
		select top 0 DMV_Father as ColPath into #temp_ClasseIscriz from lib_domainvalues  WITH (NOLOCK)
		exec recuperaPathDaDominio 'ClasseIscriz', @ClasseIscrizFILTRO,'#temp_ClasseIscriz'

		-- recupera il path della classe iscriz selezionata
		set @SQLCmd =  @SQLCmd + ' inner join ClasseIscriz CI on CI.dmv_cod = c.ClasseIscriz_S ' + @CrLf

		-- verifica che il percorso della classe selezionata sia sullo stesso ramo scelto
		set @SQLCmd =  @SQLCmd + ' inner join #temp_ClasseIscriz FC on  left( ci.dmv_father , len ( fc.ColPath)) =  fc.ColPath '  + @CrLf

	end

	
	if @AREA_DI_CONSEGNA <> ''
	begin
	
		-- preparo una tabella temporanea con i percorsi gerarchici selezionati
		select top 0 DMV_Father as ColPath into #temp_AREA_DI_CONSEGNA from lib_domainvalues  WITH (NOLOCK)
		exec recuperaPathDaDominio 'GEO', @AREA_DI_CONSEGNA,'#temp_AREA_DI_CONSEGNA'		


		-- recupera il path della @AREA_DI_CONSEGNA
		set @SQLCmd =  @SQLCmd + ' left join  LIB_DomainValues AC with(nolock) on  AC.dmv_DM_ID = ''GEO'' and    CHARINDEX( ''###'' + AC.dmv_cod + ''###'' ,  c.AREA_DI_CONSEGNA ) > 0 ' + @CrLf

		-- verifica che il luogo di consegna del filtro sia inferiore rispetto alla capacità di consegna del prodotto
		-- esempio se io sono in grado di consegnare in provincia di salerno e nella mia ricerca metto battipaglia allora la ricerca mi darà il risultato
		-- invertendo
		-- se io sono in grado di consegnare a battipaglia e cerco provincia di salerno allora non esco perchè non sono in grado di consengnare sulla provincia
		set @SQLCmd =  @SQLCmd + ' inner join #temp_AREA_DI_CONSEGNA FAC on  left( FAC.ColPath , len ( AC.dmv_father)) =  AC.dmv_father  or  c.AREA_DI_CONSEGNA = '''' '  + @CrLf
	end

	
	
	set @SQLCmd =  @SQLCmd +'	where 1 = 1 ' + @CrLf
	
	if rtrim( @SQLWhere ) <> ''
		set @SQLCmd = @SQLCmd + ' and ' + @SQLWhere + @CrLf


	if @Filter <> '' 
		set @SQLCmd = @SQLCmd + ' and ( ' + @Filter + ' ) ' + @CrLf


	if @Sort <> ''
		set @SQLCmd = @SQLCmd + ' ORDER BY ' + @Sort  + @CrLf

	exec (@SQLCmd)
	--print @SQLCmd






GO
