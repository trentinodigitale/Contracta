USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DASHBOARD_SP_VIEW_CONVENZIONI]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[DASHBOARD_SP_VIEW_CONVENZIONI] 
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
--Versione=1&data=2015-02-12&Attivita=69685&Nominativo=Francesco
--Versione=2&data=2015-03-18&Attivita=68663&Nominativo=Sabato


	declare @Param						varchar(8000)
	declare @IdentificativoIniziativa	varchar(250)
	declare @Convenzione				varchar(250)
	declare @Codice						varchar(250)
	declare @Descrizione				varchar(250)
	declare @Macro_Convenzione			varchar(250)
	declare @Convenzione_Lotto			varchar(8000)
	declare @ambito						varchar(250)
	
	set nocount on

	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp
	
	--tolgo gli attributi che gestisco in modo personalizzato
	set @AttrName =REPLACE( @AttrName , 'Ambito' , '')

	declare @SQLCmd			varchar(max)
	declare @SQLWhere		varchar(8000)
	set @SQLWhere = dbo.GetWhere( 'DASHBOARD_VIEW_CONVENZIONI' , 'V', @AttrName ,  @AttrValue ,  @AttrOp )

	declare @CrLf varchar (10)
	set @CrLf = '
'
	-- criteri di ricerca
	--print @Param
	--set @IdentificativoIniziativa	=  dbo.GetParam( 'IdentificativoIniziativa' , @Param ,1)
	--set @Convenzione	        	=  dbo.GetParam( 'Convenzione' , @Param ,1) 
	set @Codice						=  dbo.GetParam( 'Codice' , @Param ,1) 
	set @Descrizione				=  dbo.GetParam( 'Descrizione' , @Param ,1) 
	set @ambito						=  dbo.GetParam( 'Ambito' , @Param ,1) 
	
	

	set @SQLCmd =  '
	select * from DASHBOARD_VIEW_CONVENZIONI C  '  + @CrLf

	

	if @Codice <> '' or @Descrizione <> ''
	begin 

		if @Descrizione <> '' 
		begin
			set @SQLCmd = @SQLCmd + ' inner join ( select distinct idheader from document_microlotti_dettagli d with(nolock) where d.tipodoc = ''CONVENZIONE'' and d.DESCRIZIONE_CODICE_REGIONALE like ''%' + replace ( @Descrizione  , '''' , '''''' ) + '%'' ) as D on d.idheader = C.id ' + @CrLf
		end

		if @Codice <> '' 
		begin
			set @SQLCmd = @SQLCmd + ' inner join ( select distinct idheader from document_microlotti_dettagli d with(nolock) where d.tipodoc = ''CONVENZIONE'' and d.CODICE_REGIONALE like ''%' + replace ( @Codice  , '''' , '''''' ) + '%'' ) as D1 on d1.idheader = C.id '  + @CrLf
		end


		
		
	end
	
	set @SQLCmd = @SQLCmd + ' where owner = ' + cast( @IdPfu as varchar(20))
	
	if rtrim( @SQLWhere ) <> ''
		set @SQLCmd = @SQLCmd + ' and ' + @SQLWhere + @CrLf

	if @ambito <> ''
	begin	
		
		set @SQLCmd = @SQLCmd + ' and Ambito in (  select items from dbo.Split(''' + @ambito + ''',''###'')  where items <> '''' )'		
		
	end	

	if @Filter <> '' 
		set @SQLCmd = @SQLCmd + ' and ( ' + @Filter + ' ) ' + @CrLf


	if @Sort <> ''
		set @SQLCmd = @SQLCmd + ' ORDER BY ' + @Sort  + @CrLf

	exec (@SQLCmd)
	--print @SQLCmd






GO
