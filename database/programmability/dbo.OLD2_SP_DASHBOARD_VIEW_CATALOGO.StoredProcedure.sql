USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_SP_DASHBOARD_VIEW_CATALOGO]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE proc [dbo].[OLD2_SP_DASHBOARD_VIEW_CATALOGO]
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
	declare @IdpfuPO as varchar(30)
	declare @nPosStartPO as int

	set nocount on

	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp
	

	--se nella @Filter c'è PO recupero il valore e lo uso come idpfu 
	--vuol dire che sto chiamndo il viewer dall'ODC
	set @nPosStartPO = charindex('and PO=',@Filter)
	if @nPosStartPO > 0
	begin
		--recupero idpfu PO
		set @IdpfuPO = substring(@Filter,@nPosStartPO + 7,len(@Filter))
		
		--se valorizzato PO allora sostituisco utente loggato con PO
		--per filtrare gli articoli in base al PO
		if @IdpfuPO <> '' 
			set @IdPfu = @IdpfuPO


		--aggiusto la filter togliendo la condizione sul PO
		set @Filter = substring (@Filter,1, @nPosStartPO - 1 )
	end

	
	--select @IdPfu

	declare @SQLCmd			varchar(max)
	declare @SQLWhere		varchar(8000)
	set @SQLWhere = dbo.GetWhere( 'DASHBOARD_VIEW_CATALOGO' , 'V', @AttrName ,  @AttrValue ,  @AttrOp )


	print @SQLWhere

	declare @CrLf varchar (10)
	set @CrLf = '
'
	-- criteri di ricerca
	--print @Param
	--set @IdentificativoIniziativa	=  dbo.GetParam( 'IdentificativoIniziativa' , @Param ,1)
	--set @Convenzione	        	=  dbo.GetParam( 'Convenzione' , @Param ,1) 
	--set @Codice						=  dbo.GetParam( 'Codice' , @Param ,1) 
	--set @Descrizione				=  dbo.GetParam( 'Descrizione' , @Param ,1) 

	set @Macro_Convenzione			=  dbo.GetParam( 'Macro_Convenzione' , @Param ,1) 
	set @Convenzione_Lotto			=  dbo.GetParam( 'Convenzione_Lotto' , @Param ,1) 
	
	
	
	--AGGIUNGO IL FILTRO PER MOSTRARE SOLO I PRODOTTI RELATIVI
	--AI LOTTI PER I QUALI HO LA QUOTA SE SONO PRESENTI QUOTE PER LOTTO
	--ALTRIMENTI TUTTO COME PRIMA
	set @SQLCmd =  '

	select 
		case when max(isnull(NumeroLottoQ,0)) > 0 then ''SI'' else ''NO'' end  as QUOTA_LOTTO , convenzione as convenzioneT 
			into #t
		from 
			DASHBOARD_VIEW_CATALOGO where idpfu =' + cast( @IdPfu as varchar (20)) +  ' group by convenzione 

	select * 
		from 
			DASHBOARD_VIEW_CATALOGO 
				left join  #t Z on Z.ConvenzioneT=Convenzione 
		where idpfu = ' + cast( @IdPfu as varchar (20)) +  ' and ( ( QUOTA_LOTTO=''SI'' and NumeroLottoQ is not null ) or QUOTA_LOTTO = ''NO'' )  ' + @CrLf
	
	if rtrim( @SQLWhere ) <> ''
		set @SQLCmd = @SQLCmd + ' and ' + @SQLWhere + @CrLf


	if @Convenzione_Lotto <> '' 
	begin 

		--set @SQLCmd = @SQLCmd + ' and ''' + @Convenzione_Lotto + ''' like ''%###'' + cast( Lotto as varchar(100)) + ''###%'' ' +  @CrLf

		--siccome posso slezionare anche le convenzioni aggiungo la condizione per recuperare tutti i figli
		--di una convezione
		--@Convenzione_Lotto è nella forma ###cod1###....###codN###
		--ad esempio ###Conv-65367###200###
		--aggiungo alla condizione tutti i lotti delle convenzioni selezionate
		set @SQLCmd = @SQLCmd + ' and ( ( ''' + @Convenzione_Lotto + ''' like ''%###'' + cast( Lotto as varchar(100)) + ''###%'' ) or  ( ''Conv-'' + cast(idheader as varchar(100)) in ( select * from dbo.split(''' + @Convenzione_Lotto + ''',''###'') ) ) ) ' +  @CrLf

		--print @SQLCmd
	end



	if @Macro_Convenzione <> '' 
	begin 
		declare @OP_Macro_Convenzione as nvarchar(10)
		--print @Param
		set @OP_Macro_Convenzione = dbo.GetParamOperation( 'Macro_Convenzione' , @Param ,2)

		--print @OP_Macro_Convenzione
		declare @navigaAlbero as nvarchar(4000)
		
		--mi prende tutti i figli a partire dal nodo selezionato
		if rtrim(ltrim(@OP_Macro_Convenzione)) = '>'

			begin
					set @navigaAlbero = ' and Replace(Macro_Convenzione_Filtro,''###'','''' ) in (  
												select D1.DMV_COD 
													from lib_domainValues D with (nolock)
														inner join lib_domainValues D1 with (nolock) on D1.dmv_DM_ID=''Macro_Convenzione'' and D1.DMV_deleted=0 and left(D1.Dmv_father,len(D.Dmv_father))=D.Dmv_father
													where D.dmv_DM_ID=''Macro_Convenzione'' and charindex(''###''+D.DMV_COD+''###'', ''' + @Macro_Convenzione + ''' ) > 0 and D.DMV_deleted=0 )  '
			end
		--mi prende tutti gli antenati a partire dal nodo selezionato
		if rtrim(ltrim(@OP_Macro_Convenzione)) = '<'

			begin
					set @navigaAlbero = ' and Replace(Macro_Convenzione_Filtro,''###'','''' )  in (  
												select D1.DMV_COD 
													from lib_domainValues D with (nolock)
														inner join lib_domainValues D1 with (nolock) on D1.dmv_DM_ID=''Macro_Convenzione'' and D1.DMV_deleted=0 and left(D.Dmv_father,len(D1.Dmv_father))=D1.Dmv_father
													where D.dmv_DM_ID=''Macro_Convenzione'' and charindex(''###''+D.DMV_COD+''###'', ''' + @Macro_Convenzione + ''' ) > 0 and D.DMV_deleted=0 )  '
			end
		--solo il nodo selezionato
		if rtrim(ltrim(@OP_Macro_Convenzione)) = '='

			begin
					set @navigaAlbero = ' and Macro_Convenzione_Filtro =  ''' + @Macro_Convenzione + ' '' '
									
			end
			   
			set @SQLCmd = @SQLCmd + @navigaAlbero + @CrLf
	end



	if @Filter <> '' 
		set @SQLCmd = @SQLCmd + ' and ( ' + @Filter + ' ) ' + @CrLf


	if @Sort <> ''
		set @SQLCmd = @SQLCmd + ' ORDER BY ' + @Sort  + @CrLf

	exec (@SQLCmd)
	--print @SQLCmd






GO
