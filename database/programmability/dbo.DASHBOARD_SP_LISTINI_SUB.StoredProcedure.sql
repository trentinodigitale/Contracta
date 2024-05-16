USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DASHBOARD_SP_LISTINI_SUB]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE proc [dbo].[DASHBOARD_SP_LISTINI_SUB]
(
	@Idpfu						int, 
	@Azione						varchar(20),
 	@Param						varchar(max),
		

	@Filter                     varchar(8000),
	@Sort                       varchar(8000),

	@Top                        int,
	@Cnt                        int output
)
as

	--declare 	@IdPfu							int,

	declare @AttrName						varchar(8000)
	declare @AttrValue						varchar(8000)
	declare @AttrOp 						varchar(8000)


	declare @IdentificativoIniziativa	varchar(250)
	declare @Convenzione				varchar(250)
	declare @Codice						varchar(250)
	declare @Descrizione				varchar(250)
	declare @Macro_Convenzione			varchar(250)
	declare @Convenzione_Lotto			varchar(8000)
	declare @ConvenzioniScadute			varchar(10)
	declare @ProdottiAttivi varchar(10)
	declare @AziUtente as int

	set nocount on

	--set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp
	
	set @AttrName = dbo.GetPos(@Param , '#~#' ,1 ) 
	set @AttrValue = dbo.GetPos(@Param , '#~#' ,2 ) 
	set @AttrOp = dbo.GetPos(@Param , '#~#' ,3 ) 


	--recupero azienda utente collegato
	select @AziUtente = pfuidazi from profiliutente with (nolock) where IdPfu = @Idpfu


	declare @SQLCmd			varchar(max)
	declare @SQLWhere		varchar(8000)
	set @SQLWhere = dbo.GetWhere( 'DASHBOARD_VIEW_LISTINI_CONVENZIONI' , 'V', @AttrName ,  @AttrValue ,  @AttrOp )

	declare @CrLf varchar (10)
	set @CrLf = '
'

	set @Macro_Convenzione			=  dbo.GetParam( 'Macro_Convenzione' , @Param ,1) 
	set @Convenzione_Lotto			=  dbo.GetParam( 'Convenzione_Lotto' , @Param ,1) 
	set @ConvenzioniScadute			=  dbo.GetParam( 'ConvenzioniScadute' , @Param ,1) 
	set @ProdottiAttivi			=  dbo.GetParam( 'ProdottiAttivi' , @Param ,1) 
	

	if @Azione = 'MODELLI'
	begin
		set @SQLCmd =  
			'select 
				distinct 
					model.value as idModello 
				from 
					DASHBOARD_VIEW_LISTINI_CONVENZIONI c
						inner join CTL_DOC_Value model with(nolock) ON model.IdHeader = c.Convenzione and model.dse_id = ''TESTATA_PRODOTTI'' and model.DZT_Name = ''id_modello'' and isnull(model.value,'''') <> ''''
				where 1 = 1 ' + @CrLf

	end
	else
	begin
		set @SQLCmd =  'select 
								c.* from DASHBOARD_VIEW_LISTINI_CONVENZIONI C 
									--salgo sull''azienda del compilatore della convenzione
									--per aprire la ricerca agli utenti dello stesso ente del compilatore
									left join profiliutente P on P.idpfu = C.idpfu
									
							where 1 = 1 and P.pfuidazi = ' + cast(@AziUtente as varchar(50)) + '
						
		
		' + @CrLf
	end



	if rtrim( @SQLWhere ) <> ''
		set @SQLCmd = @SQLCmd + ' and ' + @SQLWhere + @CrLf


	if @Convenzione_Lotto <> '' 
	begin 

		--@Convenzione_Lotto Ã¨ nella forma ###cod1###....###codN###
		--ad esempio ###Conv-65367###200###
		--aggiungo alla condizione tutti i lotti delle convenzioni selezionate
		set @SQLCmd = @SQLCmd + ' and ( ( ''' + @Convenzione_Lotto + ''' like ''%###'' + cast( Lotto as varchar(100)) + ''###%'' ) or  ( ''Conv-'' + cast(c.idheader as varchar(100)) in ( select * from dbo.split(''' + @Convenzione_Lotto + ''',''###'') ) ) ) ' +  @CrLf

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
					set @navigaAlbero = ' and Replace(Macro_Convenzione_Filtro,''###'','''' ) in (  select D1.DMV_COD from lib_domainValues D
										inner join lib_domainValues D1 on D1.dmv_DM_ID=''Macro_Convenzione'' and D1.DMV_deleted=0 and left(D1.Dmv_father,len(D.Dmv_father))=D.Dmv_father
										where D.dmv_DM_ID=''Macro_Convenzione'' and charindex(''###''+D.DMV_COD+''###'', ''' + @Macro_Convenzione + ''' ) > 0 and D.DMV_deleted=0 )  '
			end
		--mi prende tutti gli antenati a partire dal nodo selezionato
		if rtrim(ltrim(@OP_Macro_Convenzione)) = '<'

			begin
					set @navigaAlbero = ' and Replace(Macro_Convenzione_Filtro,''###'','''' )  in (  select D1.DMV_COD from lib_domainValues D
										inner join lib_domainValues D1 on D1.dmv_DM_ID=''Macro_Convenzione'' and D1.DMV_deleted=0 and left(D.Dmv_father,len(D1.Dmv_father))=D1.Dmv_father
										where D.dmv_DM_ID=''Macro_Convenzione'' and charindex(''###''+D.DMV_COD+''###'', ''' + @Macro_Convenzione + ''' ) > 0 and D.DMV_deleted=0 )  '
			end
		--solo il nodo selezionato
		if rtrim(ltrim(@OP_Macro_Convenzione)) = '='

			begin
					set @navigaAlbero = ' and Macro_Convenzione_Filtro =  ''' + @Macro_Convenzione + ' '' '
									
			end
			   
			set @SQLCmd = @SQLCmd + @navigaAlbero + @CrLf
	end


	if @ConvenzioniScadute  <> '' 
	begin
		if @ConvenzioniScadute = 'no'
		begin
			set @SQLCmd = @SQLCmd + ' AND CONVERT(VARCHAR(10), DataInizio, 121) <= CONVERT(VARCHAR(10), GETDATE(), 121) ' 
			set @SQLCmd = @SQLCmd + ' AND CONVERT(VARCHAR(10), GETDATE(), 121) <= CONVERT(VARCHAR(10), DataFine, 121) '
		end

		if @ConvenzioniScadute = 'si'
		begin
			set @SQLCmd = @SQLCmd + ' AND CONVERT(VARCHAR(10), GETDATE(), 121) >  CONVERT(VARCHAR(10), DataFine, 121) '
		end


	end 

	--se richiesto il filtro per i prodotti attivi escludo i cancellati
	if @ProdottiAttivi = 'si'
		set @SQLCmd = @SQLCmd + ' and statoriga <> ''cancellato'' '

	if @Filter <> '' 
		set @SQLCmd = @SQLCmd + ' and ( ' + @Filter + ' ) ' + @CrLf

		
	
	
	if @Sort <> '' and @Azione <> 'MODELLI'
		set @SQLCmd = @SQLCmd + ' ORDER BY ' + @Sort  + @CrLf

	exec (@SQLCmd)
	--print @SQLCmd




GO
