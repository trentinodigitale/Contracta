USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[MAKE_MODULO_TEMPLATE_REQUEST]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE PROCEDURE [dbo].[MAKE_MODULO_TEMPLATE_REQUEST] 	( @idDoc int   , @Modello_Modulo as varchar(500) , @idDocInUse int  )
AS
--Versione=1&data=2016-10-21&Attivita=126293&Nominativo=Sabato
BEGIN
	SET NOCOUNT ON;


	declare @Template nvarchar( max )

	declare @REQUEST_PART varchar(100),   @Descrizione nvarchar( max),   @TEMPLATE_REQUEST_GROUP varchar(200)
	declare @REQUEST_PART_CUR varchar(100),   @TEMPLATE_REQUEST_GROUP_CUR varchar(200)
	declare @Parte_aperta int
	declare @Gruppo_Aperto int
	declare @KeyRiga varchar(500)
	declare @KeyGruppoAperto varchar(500)
	declare @TipoTemplate varchar(500)
	
	declare @idModulo int
	declare @NRow int
	declare @RG_FLD_TYPE varchar(max)
	declare @ItemPath varchar(max)
	declare @ix int

	declare @idTemplate int
	declare @Editabile varchar(5)
	declare @InCaricoA varchar(50)

	set @Parte_aperta = 0
	set @Gruppo_Aperto = 0 

	set @Template  = ''
	set @REQUEST_PART_CUR = '' 
	set @TEMPLATE_REQUEST_GROUP_CUR = ''

	declare @crlf varchar(10)
	set @crlf  = '
'



	---------------------------------------------
	---------------------------------------------

	-- se il template non è stato indicato si recupera dal documento DGUE
	if @idDoc = 0
	begin

		--declare @TipoDoc varchar(500)
		--DECLARE @idTemplatContest int
		--declare @JumpCheck  varchar(500)


		--select @idTemplatContest = LinkedDoc , @JumpCheck = @JumpCheck from CTL_DOC where id = @idDocInUse

		------ dal modulo ricavo il template utilizzato per generarlo navigando la struttura all'indietro 
		--set @tipoDoc = ''
	
		--while @TipoDoc not in ( 'TEMPLATE_REQUEST' , 'TEMPLATE_CONTEST' , 'BANDO' , 'BANDO_SDA' , 'BANDO_SEMPLIFICATO' , 'BANDO_GARA' )
		--begin
		--	select @idTemplatContest = LinkedDoc , @tipoDoc = Tipodoc from CTL_DOC where id = @idTemplatContest
		--	select @tipoDoc = Tipodoc from CTL_DOC where id = @idTemplatContest
		--end

		---- arrivato sul bando cerco il template relativo al tipo di DGUE che ho come riferimento
		--if @TipoDoc in ( 'BANDO' , 'BANDO_SDA' , 'BANDO_SEMPLIFICATO' , 'BANDO_GARA'  ) 
		--	if exists( select id  
		--					from CTL_DOC 
		--					where LinkedDoc = @idTemplatContest  
		--						and TipoDoc = 'TEMPLATE_CONTEST'
		--						and JumpCheck = @JumpCheck 
		--			 )
		--begin
		--	select @idTemplatContest = id , @tipoDoc = Tipodoc 
		--		from CTL_DOC 
		--		where LinkedDoc = @idTemplatContest  and TipoDoc = 'TEMPLATE_CONTEST'
				
		--			and JumpCheck = @JumpCheck -- template specifico
		--end
		--else -- se non trovo il template relativo prendo quello che trovo ma c'è da approfondire la mancanza
		--begin
		--	select @idTemplatContest = id , @tipoDoc = Tipodoc 
		--		from CTL_DOC 
		--		where LinkedDoc = @idTemplatContest  and TipoDoc = 'TEMPLATE_CONTEST'
		--end

		--set  @idDoc =  @idTemplatContest

		set  @idDoc =  dbo.GetIdTemplateComtest(  @idDocInUse )

	end

	-- se il nome del modello non è passato lo prendiamo direttamente dal documento
	if @Modello_Modulo = ''
	begin
		
		select @Modello_Modulo = MOD_Name from CTL_DOC_SECTION_MODEL with(nolock) where IdHeader = @idDocInUse and DSE_ID = 'MODULO'
		
	end



	---------------------------------------------
	---------------------------------------------


	-- cancella una eventuale presenza prima di crearlo
	delete from CTL_Models where [MOD_ID] = @Modello_Modulo
	delete from CTL_ModelAttributes where [MA_MOD_ID] = @Modello_Modulo
	delete from CTL_ModelAttributeProperties where [MAP_MA_MOD_ID] = @Modello_Modulo		
	
	delete from CTL_Models where [MOD_ID] = @Modello_Modulo + '_SAVE'
	delete from CTL_ModelAttributes where [MA_MOD_ID] = @Modello_Modulo + '_SAVE'
	delete from CTL_ModelAttributeProperties where [MAP_MA_MOD_ID] = @Modello_Modulo + '_SAVE'
	
	
	-- recupera l'id del template nel caso in cui è stato passato il template specifico e non base
	select @idTemplate = case when TipoDoc = 'TEMPLATE_REQUEST' then id else idDoc end , @TipoTemplate = TipoDoc 
	from ctl_doc with(nolock) where id = @idDoc
	


	-- recupero se il documento in uso è di un ente o di un oe
	select  @InCaricoA = case when aziAcquirente <> 0 then 'Ente' else 'OE' end 
		from ctl_doc d with(nolock)
		inner join profiliutente p with(nolock) on p.idpfu = d.IdPfu
		inner join aziende a with(nolock) on p.pfuidazi = a.idazi
			where id = @idDocInUse
	set @InCaricoA = isnull( @InCaricoA , 'Ente')


	-----------------------
	-- creo il template
	-----------------------
	--set @Template  = @Template   + '<link rel="stylesheet" href="../themes/bootstrap.css"  media="screen" >'
	--set @Template  = @Template   + '<link rel="stylesheet" href="../themes/bootstrap_print.css" media="print" >'
	--set @Template  = @Template   + '<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">'
	--set @Template   = @Template  + '<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>'


	set @Template  = @Template   + '<div class="ModuloBootstrap" >' --<div id="pageFooter">Page </div>' 

	-------------------------------------------
	-- recupero tutti gli elementi del template
	-------------------------------------------
	declare CurTemplateRequest Cursor local static for 

		Select t.value as REQUEST_PART ,   d.Value  as Descrizione , a.Value as  TEMPLATE_REQUEST_GROUP , replace( k.Value , ' ' , '') as KeyRiga , M.Value as idModulo , isNull( S.Value , '1' ) as Editabile
			from CTL_DOC_Value t with(nolock)
				inner join CTL_DOC_Value d with(nolock) on t.idheader = d.idheader and t.Row = d.Row and d.DSE_ID = 'VALORI' and d.DZT_Name = 'DescrizioneEstesa'
				inner join CTL_DOC_Value a with(nolock) on t.idheader = a.idheader and t.Row = a.Row and a.DSE_ID = 'VALORI' and a.DZT_Name = 'TEMPLATE_REQUEST_GROUP'
				inner join CTL_DOC_Value k with(nolock) on t.idheader = k.idheader and t.Row = k.Row and k.DSE_ID = 'VALORI' and k.DZT_Name = 'KeyRiga'
				inner join CTL_DOC_Value M with(nolock) on t.idheader = M.idheader and t.Row = M.Row and M.DSE_ID = 'VALORI' and M.DZT_Name = 'IdModulo'

				-- recupera le spunte di SelRow per portare solo gli elementi scelti
				left outer join CTL_DOC_Value k2 with(nolock) on k2.idheader = @idDoc and k2.DSE_ID = 'VALORI' and k2.DZT_Name = 'KeyRiga' and k.Value = k2.Value
				left outer join CTL_DOC_Value S with(nolock) on S.idheader = @idDoc and k2.Row = S.Row and S.DSE_ID = 'VALORI' and S.DZT_Name = 'SelRow'

				-- verifica se la sezione è removibile
				inner join CTL_DOC_Value R with(nolock) on t.idheader = R.idheader and t.Row = R.Row and R.DSE_ID = 'VALORI' and R.DZT_Name = 'Removibile'

		where t.idHeader=@idTemplate and t.DSE_ID = 'VALORI' and t.DZT_Name = 'REQUEST_PART' and  ( isNull( S.Value , '1' ) = '1' or R.value <> '1')
		order by t.Row



	
	open CurTemplateRequest

	FETCH NEXT FROM CurTemplateRequest 	INTO @REQUEST_PART ,   @Descrizione ,   @TEMPLATE_REQUEST_GROUP , @KeyRiga , @idModulo , @Editabile
	WHILE @@FETCH_STATUS = 0
	BEGIN

		if @REQUEST_PART = 'Parti'
		begin


			-- se era apert un gruppo devo chiuderlo
			if @Gruppo_Aperto = 1
			begin
				set @Template = @Template + '</div></div></div>' + @crlf + '<!-- Chiusura Sezione ' + @KeyGruppoAperto + ' -->' + @crlf 
				set @Gruppo_Aperto = 0
			end

			-- se era aperta una parte devo chiuderla
			if @Parte_aperta = 1
			begin
				set @Template = @Template + '</div>' + @crlf + '<!-- Chiusura PARTE -->'+ @crlf 	
			end

			-- Apro una nuova parte del modulo
			set @Template = @Template + '<div class="panel-default"> <div> <h2><span >' + @Descrizione + '</span></h2></div>'
			set @Parte_aperta = 1

		end


		if @REQUEST_PART = 'Gruppo'
		begin

			-- se era apert un gruppo devo chiuderlo
			if @Gruppo_Aperto = 1 
				set @Template = @Template + '</div></div></div>' + @crlf + '<!-- Chiusura Sezione ' + @KeyGruppoAperto + ' -->' + @crlf 


			set @Template = @Template + 
				@crlf + '<!-- Apertura Sezione ' + @KeyRiga + ' -->' + @crlf 
				+ '<div class="panel panel-espd">
					<div class="panel-heading" data-toggle="collapse" data-target="#' + @KeyRiga + '">
					<h4 class="panel-title">
					<span data-i18n="crit_top_title_grounds_criminal_conv">' + @Descrizione + '</span>
					</h4>
					</div>
			
					<div id="' + @KeyRiga + '" class="collapse in">
						<div class="espd-panel-body panel-body">

'
--							<strong>
--								<span data-i18n="crit_eu_main_title_grounds_criminal_conv_eo">Ulteriore descrizione da capire dove mettere</span>
--							</strong>

			set @Gruppo_Aperto = 1
			set @KeyGruppoAperto = @KeyRiga
		end

		


		if @REQUEST_PART in ( 'Commenti' )
		begin

			-- per ogni attributo presente nel modulo si itera il processo
			set @Template = @Template
			set @Template = @Template + '<div class="PanelCommenti" >' + replace( @Descrizione , @crlf , '<br />' ) + ' </div> ' + @crlf

		end

		if @REQUEST_PART in (  'Titolo' )
		begin

			-- per ogni attributo presente nel modulo si itera il processo
			set @Template = @Template
			set @Template = @Template + '<div class="PanelTitolo" >' + replace( @Descrizione , @crlf , '<br />' ) + ' </div> ' + @crlf

		end


		if @REQUEST_PART = 'Modulo'
		begin

			-- per ogni attributo presente nel modulo si itera il processo
			set @Template = @Template  + @crlf + '<!--  Modulo : [' + isnull( @TEMPLATE_REQUEST_GROUP ,'') + '] -->'  + @crlf
			set @Template = @Template  + @crlf + '<div class="Modulo" >' + dbo.GetHtmlModuloRequest( @idModulo  , @KeyRiga , @idDocInUse ,'' , @InCaricoA ) + '</div>'  + @crlf

		end

	             

		FETCH NEXT FROM CurTemplateRequest 	INTO @REQUEST_PART ,   @Descrizione ,   @TEMPLATE_REQUEST_GROUP , @KeyRiga , @idModulo , @Editabile
	END 
	CLOSE CurTemplateRequest
	DEALLOCATE CurTemplateRequest

	-----------------------------------------------
	-- effettuo le chiusure delle div fuori ciclo
	if @Gruppo_Aperto = 1 
		set @Template = @Template + '</div></div></div>' + @crlf + '<!-- Chiusura Sezione ' + @KeyGruppoAperto + ' -->' + @crlf 
		
	if @Parte_aperta = 1
		set @Template = @Template + '</div>'  + @crlf + '<!-- Chiusura PARTE -->'+ @crlf 	
	

	set @Template  = @Template   +  @crlf  + '<style>
.ui-tooltip {

	padding: 4px;
	position: absolute;
	z-index: 9999; 
	-webkit-box-shadow: 0 0 5px #aaa;
	box-shadow: 0 0 5px #aaa;
	width:inherit;
	max-width:inherit;
	background:#FFFFF2;

	font-size: 0.8em;
	line-height: 1;
	font-family: "Lucida Sans Unicode", "Lucida Grande", sans-serif;
	text-align: left;
  
}

</style>'

	declare @TemplateX nvarchar(max)

	set @TemplateX  = @Template   +  @crlf  + '<script type="text/javascript">

$(''.GRP_Related'').each( function(){
	try{ OpenCloseGroup( this  ); }catch(e){};
});	


function OpenCloseGroup( obj )
{
		var id = obj.id;
		var l = id.length;
		var idRadio = id;
		if ( idRadio.endsWith( ''_ON_TRUE'' ) )
			idRadio = id.substring(4 , l - 8);
		
		if ( idRadio.endsWith( ''_ON_FALSE'' ) )
			idRadio = id.substring(4 , l - 9);
		
		var idValore = ''H_'' + id;
		
		obj.style.display = ''none'';
		
		if 	(
				( getObjValue( idValore ) == ''GROUP_FULFILLED.ON_TRUE'' && getObjValue( idRadio ) ==  ''si'' ) 
				|| 
				( getObjValue( idValore ) == ''GROUP_FULFILLED.ON_FALSE'' && getObjValue( idRadio ) ==  ''no'' ) 
			)
		{
			obj.style.display = '''';
		}
	
}
	</script>'+ @crlf 

	set @Template  = @Template   + '</div>' 

	-----------------------
	-- creo il modello
	-----------------------




	-- crea il modello di salvataggio e rappresentazione
	insert into CTL_Models (  MOD_ID, MOD_Name, MOD_DescML, MOD_Type, MOD_Sys, MOD_help, MOD_Param, MOD_Module, MOD_Template )
		select @Modello_Modulo as MOD_ID, @Modello_Modulo as MOD_Name, @Modello_Modulo as MOD_DescML, 1 as MOD_Type, 1 as MOD_Sys, '' as MOD_help, 'Type=posizionale&DrawMode=1&NumberColumn=2&Path=../../&PathImage=../../CTL_Library/images/Domain/' as MOD_Param, 'DOCUMENT_TEMPLATE' as MOD_Module , @Template as  MOD_Template  




	insert into CTL_ModelAttributes ( MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order , DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_Len, DZT_Dec, DZT_Format, DZT_Help, DZT_Multivalue, MA_Module ) 
		select @Modello_Modulo as MA_MOD_ID, upper( 'MOD_' + replace( k.value , '.' , '_' )  + '_FLD_' +   dbo.GetID_ElementModulo ( ItemPath , ItemLevel  , TypeRequest ) ) as MA_DZT_Name, '' as MA_DescML, 1 as MA_Pos, /*dz.DZT_Len*/ 0  as   MA_Len, 1 as MA_Order, 
				 dz.DZT_Type, 
				 dz.DZT_DM_ID, 
				 dz.DZT_DM_ID_Um, 0 as /*dz.*/ DZT_Len,  dz.DZT_Dec,
				 dz.DZT_Format,
				 dz.DZT_Help, dz.DZT_Multivalue, 'DOCUMENT_TEMPLATE' as MA_Module

			from CTL_DOC_Value t with(nolock)
				inner join CTL_DOC_Value d with(nolock) on t.idheader = d.idheader and t.Row = d.Row and d.DSE_ID = 'VALORI' and d.DZT_Name = 'DescrizioneEstesa'
				inner join CTL_DOC_Value a  with(nolock) on t.idheader = a.idheader and t.Row = a.Row and a.DSE_ID = 'VALORI' and a.DZT_Name = 'TEMPLATE_REQUEST_GROUP'
				inner join CTL_DOC_Value k  with(nolock) on t.idheader = k.idheader and t.Row = k.Row and k.DSE_ID = 'VALORI' and k.DZT_Name = 'KeyRiga'



				-- recupera le spunte di SelRow per portare solo gli elementi scelti
				left outer join CTL_DOC_Value k2 with(nolock) on k2.idheader = @idDoc and k2.DSE_ID = 'VALORI' and k2.DZT_Name = 'KeyRiga' and k.Value = k2.Value
				left outer join CTL_DOC_Value S with(nolock) on S.idheader = @idDoc and k2.Row = S.Row and S.DSE_ID = 'VALORI' and S.DZT_Name = 'SelRow'

				-- verifica se la sezione è removibile
				inner join CTL_DOC_Value R with(nolock) on t.idheader = R.idheader and t.Row = R.Row and R.DSE_ID = 'VALORI' and R.DZT_Name = 'Removibile'


				inner join CTL_DOC_Value M with(nolock) on t.idheader = M.idheader and t.Row = M.Row and M.DSE_ID = 'VALORI' and M.DZT_Name = 'IdModulo'
				inner join DOCUMENT_REQUEST_GROUP G with(nolock) on G.idheader = M.value

				inner join LIB_Dictionary dz with(nolock) on dz.DZT_Name = G.RG_FLD_TYPE

			where t.idHeader=@idTemplate and t.DSE_ID = 'VALORI' and t.DZT_Name = 'REQUEST_PART' and t.value = 'Modulo' AND ISNULL( G.RG_FLD_TYPE , '' ) <> '' 
				 and  ( isNull( S.Value , '1' ) = '1' or R.value <> '1')


	-- inserisco il dominio delle valute se ho richiesto un campo di tipo currency
	insert into CTL_ModelAttributes ( MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order , DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_Len, DZT_Dec, DZT_Format, DZT_Help, DZT_Multivalue, MA_Module ) 
		select @Modello_Modulo as MA_MOD_ID,upper( 'MOD_' + replace( k.value , '.' , '_' )  + '_FLD_CUR_' +  dbo.GetID_ElementModulo ( ItemPath , ItemLevel  , TypeRequest )) as MA_DZT_Name, '' as MA_DescML, 1 as MA_Pos, dz.DZT_Len as   MA_Len, 1 as MA_Order, 
				 dz.DZT_Type, 
				 dz.DZT_DM_ID, 
				 dz.DZT_DM_ID_Um, dz.DZT_Len,  dz.DZT_Dec,
				 dz.DZT_Format,
				 dz.DZT_Help, dz.DZT_Multivalue, 'DOCUMENT_TEMPLATE' as MA_Module

			from CTL_DOC_Value t with(nolock)
				inner join CTL_DOC_Value d with(nolock) on t.idheader = d.idheader and t.Row = d.Row and d.DSE_ID = 'VALORI' and d.DZT_Name = 'DescrizioneEstesa'
				inner join CTL_DOC_Value a  with(nolock) on t.idheader = a.idheader and t.Row = a.Row and a.DSE_ID = 'VALORI' and a.DZT_Name = 'TEMPLATE_REQUEST_GROUP'
				inner join CTL_DOC_Value k  with(nolock) on t.idheader = k.idheader and t.Row = k.Row and k.DSE_ID = 'VALORI' and k.DZT_Name = 'KeyRiga'

				-- recupera le spunte di SelRow per portare solo gli elementi scelti
				left outer join CTL_DOC_Value k2 with(nolock) on k2.idheader = @idDoc and k2.DSE_ID = 'VALORI' and k2.DZT_Name = 'KeyRiga' and k.Value = k2.Value
				left outer join CTL_DOC_Value S with(nolock) on S.idheader = @idDoc and k2.Row = S.Row and S.DSE_ID = 'VALORI' and S.DZT_Name = 'SelRow'

				-- verifica se la sezione è removibile
				inner join CTL_DOC_Value R with(nolock) on t.idheader = R.idheader and t.Row = R.Row and R.DSE_ID = 'VALORI' and R.DZT_Name = 'Removibile'


				inner join CTL_DOC_Value M with(nolock) on t.idheader = M.idheader and t.Row = M.Row and M.DSE_ID = 'VALORI' and M.DZT_Name = 'IdModulo'
				inner join DOCUMENT_REQUEST_GROUP G with(nolock) on G.idheader = M.value

				inner join LIB_Dictionary dz with(nolock) on dz.DZT_Name = 'CurrencyDom'

			where t.idHeader=@idTemplate and t.DSE_ID = 'VALORI' and t.DZT_Name = 'REQUEST_PART' and t.value = 'Modulo' and G.RG_FLD_TYPE = 'Currency'
				 and  ( isNull( S.Value , '1' ) = '1' or R.value <> '1')




	
	if @TipoTemplate <> 'TEMPLATE_REQUEST' 
	begin


		--------- Inserisco la non editabilità per i modelli generati nei contesti d'uso
		insert into CTL_ModelAttributeProperties ( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module ) 
			select @Modello_Modulo as MA_MOD_ID, upper( 'MOD_' + replace( k.value , '.' , '_' )  + '_FLD_' +   dbo.GetID_ElementModulo ( ItemPath , ItemLevel  , TypeRequest ) ) as MA_DZT_Name,
					'Editable' as MAP_Propety , '0' as MAP_Value ,'DOCUMENT_TEMPLATE' as MA_Module

				from CTL_DOC_Value t with(nolock)
					--inner join CTL_DOC_Value a  with(nolock) on t.idheader = a.idheader and t.Row = a.Row and a.DSE_ID = 'VALORI' and a.DZT_Name = 'TEMPLATE_REQUEST_GROUP'
					inner join CTL_DOC_Value k  with(nolock) on t.idheader = k.idheader and t.Row = k.Row and k.DSE_ID = 'VALORI' and k.DZT_Name = 'KeyRiga'
					inner join CTL_DOC_Value M with(nolock) on t.idheader = M.idheader and t.Row = M.Row and M.DSE_ID = 'VALORI' and M.DZT_Name = 'IdModulo'
					inner join DOCUMENT_REQUEST_GROUP G with(nolock) on G.idheader = M.value

					--inner join LIB_Dictionary dz  with(nolock) on dz.DZT_Name = G.RG_FLD_TYPE


					-- recupera le spunte di SelRow per portare solo gli elementi scelti
					left outer join CTL_DOC_Value k2 with(nolock) on k2.idheader = @idDoc and k2.DSE_ID = 'VALORI' and k2.DZT_Name = 'KeyRiga' and k.Value = k2.Value
					left outer join CTL_DOC_Value S with(nolock) on S.idheader = @idDoc and k2.Row = S.Row and S.DSE_ID = 'VALORI' and S.DZT_Name = 'SelRow'

					-- verifica se la sezione è removibile
					inner join CTL_DOC_Value R with(nolock) on t.idheader = R.idheader and t.Row = R.Row and R.DSE_ID = 'VALORI' and R.DZT_Name = 'Removibile'

				where t.idHeader=@idTemplate and t.DSE_ID = 'VALORI' and t.DZT_Name = 'REQUEST_PART' and t.value = 'Modulo' AND ISNULL( G.RG_FLD_TYPE , '' ) <> '' 

					and 
					( 
						(
							isnull( s.value , '1' )  = '0' -- un elemento non selezionato indica che non è stato scelto quindi non editabile
							and 
							R.value <> '1'
						)
						or
						( @InCaricoA <> G.InCaricoA  and isnull( G.InCaricoA , '' ) <> '' ) -- non è editabile se la tipologia dell'utente non coincide
						OR 
						( isnull( G.Edit , 0 ) = 1 ) -- la spunta indica che è un attributo con sorgente ed è richiesto non editabile

					)

		-------------- Inserisco l'obbligatorietà dove richiesto
		insert into CTL_ModelAttributeProperties ( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module ) 
			
			select @Modello_Modulo as MA_MOD_ID, upper( 'MOD_' + replace( k.value , '.' , '_' )  + '_FLD_' +   dbo.GetID_ElementModulo ( ItemPath , ItemLevel  , TypeRequest ) ) as MA_DZT_Name,
					'Obbligatory' as MAP_Propety , '1' as MAP_Value ,'DOCUMENT_TEMPLATE' as MA_Module

				from CTL_DOC_Value t with(nolock)
					--inner join CTL_DOC_Value a  with(nolock) on t.idheader = a.idheader and t.Row = a.Row and a.DSE_ID = 'VALORI' and a.DZT_Name = 'TEMPLATE_REQUEST_GROUP'
					inner join CTL_DOC_Value k  with(nolock) on t.idheader = k.idheader and t.Row = k.Row and k.DSE_ID = 'VALORI' and k.DZT_Name = 'KeyRiga'
					inner join CTL_DOC_Value M with(nolock) on t.idheader = M.idheader and t.Row = M.Row and M.DSE_ID = 'VALORI' and M.DZT_Name = 'IdModulo'
					inner join DOCUMENT_REQUEST_GROUP G with(nolock) on G.idheader = M.value

					--inner join LIB_Dictionary dz  with(nolock) on dz.DZT_Name = G.RG_FLD_TYPE


					-- recupera le spunte di SelRow per portare solo gli elementi scelti
					left outer join CTL_DOC_Value k2 with(nolock) on k2.idheader = @idDoc and k2.DSE_ID = 'VALORI' and k2.DZT_Name = 'KeyRiga' and k.Value = k2.Value
					left outer join CTL_DOC_Value S with(nolock) on S.idheader = @idDoc and k2.Row = S.Row and S.DSE_ID = 'VALORI' and S.DZT_Name = 'SelRow'

					-- verifica se la sezione è removibile
					inner join CTL_DOC_Value R with(nolock) on t.idheader = R.idheader and t.Row = R.Row and R.DSE_ID = 'VALORI' and R.DZT_Name = 'Removibile'

				where t.idHeader=@idTemplate and t.DSE_ID = 'VALORI' and t.DZT_Name = 'REQUEST_PART' and t.value = 'Modulo' AND ISNULL( G.RG_FLD_TYPE , '' ) <> '' 

					and 
					( 
					    -- l'obbligatorietà è solo per gli attributi editabili
						
						not (
							isnull( s.value , '1' )  = '0' -- un elemento non selezionato indica che non è stato scelto quindi non editabile
							and 
							R.value <> '1'
						)
						and 
						not ( @InCaricoA <> G.InCaricoA  and isnull( G.InCaricoA , '' ) <> '' ) -- non è editabile se la tipologia dell'utente non coincide
						
						and 
						not ( isnull( G.Edit , 0 ) = 1 ) -- la spunta indica che è un attributo con sorgente ed è richiesto non editabile
						
						-- ed è richiesto obbligatorio
						and ( isnull( G.Obbligatorio , 0 ) = 1 ) 
					)



	end




	-------------------------------------------
	-- INSERISCO GLI ATTRIBUTI ITERABILI 
	-------------------------------------------

	-------------------------------------------
	-- per ogni gruppo  iterabile 
	-------------------------------------------
	declare CurModuloRequest Cursor LOCAL static for 
		select upper(  replace( k.value , '.' , '_' ) ) as KeyRiga ,   dbo.GetID_ElementModulo ( ItemPath , ItemLevel  , TypeRequest ) as DZT_Name ,ItemPath

			from CTL_DOC_Value t with(nolock)
				inner join CTL_DOC_Value a  with(nolock) on t.idheader = a.idheader and t.Row = a.Row and a.DSE_ID = 'VALORI' and a.DZT_Name = 'TEMPLATE_REQUEST_GROUP'
				inner join CTL_DOC_Value k  with(nolock) on t.idheader = k.idheader and t.Row = k.Row and k.DSE_ID = 'VALORI' and k.DZT_Name = 'KeyRiga'
				--inner join CTL_DOC M  with(nolock) on M.TipoDoc = 'TEMPLATE_REQUEST_GROUP' and replace( cast( m.numerodocumento as varchar(500)) , '-' , '_' ) = a.Value --TEMPLATE_REQUEST_GROUP
				--inner join DOCUMENT_REQUEST_GROUP G  with(nolock) on G.idheader = M.id and Iterabile = 1

				inner join CTL_DOC_Value M with(nolock) on t.idheader = M.idheader and t.Row = M.Row and M.DSE_ID = 'VALORI' and M.DZT_Name = 'IdModulo'
				inner join DOCUMENT_REQUEST_GROUP G with(nolock) on G.idheader = M.value and Iterabile = 1

			where t.idHeader=@idTemplate and t.DSE_ID = 'VALORI' and t.DZT_Name = 'REQUEST_PART' and t.value = 'Modulo' 

	open CurModuloRequest

	
	-- preparo la tabella temporanea per collezionare gli attributi da rimuovere
	select top 0 cast( '' as nvarchar(1000)) as MA_DZT_Name  into #ToDelete
	
	-------------------------------------------
	-- ciclo per il numero di occorrenze, recuperato dal documento per generare gli attributi
	-------------------------------------------

	FETCH NEXT FROM CurModuloRequest 	INTO @KeyRiga   , @RG_FLD_TYPE , @ItemPath
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		set @NRow = 0
		select @NRow = value from CTL_DOC_Value with(nolock) where idheader = @idDocInUse and DZT_Name = @KeyRiga + '@@@' + @ItemPath and DSE_ID = 'ITERAZIONI'		
		if isnull( @NRow , 0 ) = 0 
			set @NRow = 1


		-- conservo in una tabella temporanea gli attributi base da cui vengono generati quelli iterativi per poterli cancellare 
		insert into #ToDelete ( MA_DZT_Name )
			select 'MOD_' + @KeyRiga  + '_FLD_'  +  dbo.GetPos( MA_DZT_Name , '_FLD_' , 2) as MA_DZT_Name
				from CTL_ModelAttributes with(nolock)
				where MA_MOD_ID = @Modello_Modulo 
					and MA_DZT_Name like  'MOD_' + @KeyRiga  + '_FLD_' +  @RG_FLD_TYPE + '%'
					and MA_DZT_Name not like  'MOD_' + @KeyRiga  + '_FLD_CUR_' +  @RG_FLD_TYPE + '%'

		insert into #ToDelete ( MA_DZT_Name )
			select 'MOD_' + @KeyRiga  + '_FLD_CUR_' + cast( @ix as varchar(5)) +  dbo.GetPos( MA_DZT_Name , '_FLD_CUR_' , 2) as MA_DZT_Name
				from CTL_ModelAttributes with(nolock)
				where MA_MOD_ID = @Modello_Modulo 
					and MA_DZT_Name like  'MOD_' + @KeyRiga  + '_FLD_CUR_' +  @RG_FLD_TYPE + '%'


		set @ix = 0 
		while @ix < @NRow
		begin
			



			-- genera le istanze per gli attributi 
			insert into CTL_ModelAttributes ( MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order , DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_Len, DZT_Dec, DZT_Format, DZT_Help, DZT_Multivalue, MA_Module ) 
				select MA_MOD_ID, 
						
						'MOD_' + @KeyRiga  + '_FLD_N' + cast( @ix as varchar(5)) +  dbo.GetPos( MA_DZT_Name , '_FLD_' , 2) as MA_DZT_Name, 
						
						MA_DescML, MA_Pos, MA_Len, MA_Order , DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_Len, DZT_Dec, DZT_Format, DZT_Help, DZT_Multivalue, MA_Module 
					from CTL_ModelAttributes with(nolock) 
					where MA_MOD_ID = @Modello_Modulo 
						and MA_DZT_Name like  'MOD_' + @KeyRiga  + '_FLD_' +  @RG_FLD_TYPE + '%'
						and MA_DZT_Name not like  'MOD_' + @KeyRiga  + '_FLD_CUR_' +  @RG_FLD_TYPE + '%'


			-- genera le istanze per i domini currency
			insert into CTL_ModelAttributes ( MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order , DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_Len, DZT_Dec, DZT_Format, DZT_Help, DZT_Multivalue, MA_Module ) 
				select MA_MOD_ID, 
						
						'MOD_' + @KeyRiga  + '_FLD_CUR_N' + cast( @ix as varchar(5)) +  dbo.GetPos( MA_DZT_Name , '_FLD_CUR_' , 2) as MA_DZT_Name, 
						
						MA_DescML, MA_Pos, MA_Len, MA_Order , DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_Len, DZT_Dec, DZT_Format, DZT_Help, DZT_Multivalue, MA_Module 
					from CTL_ModelAttributes with(nolock) 
					where MA_MOD_ID = @Modello_Modulo 
						and MA_DZT_Name like  'MOD_' + @KeyRiga  + '_FLD_CUR_' +  @RG_FLD_TYPE + '%'


			-- riporto eventuali properti presenti
			insert into CTL_ModelAttributeProperties (  MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module )
				select MAP_MA_MOD_ID, 
						'MOD_' + @KeyRiga  + '_FLD_N' + cast( @ix as varchar(5)) +  dbo.GetPos( MAP_MA_DZT_Name , '_FLD_' , 2) as MAP_MA_DZT_Name, 
						MAP_Propety, MAP_Value, MAP_Module 
					from CTL_ModelAttributeProperties with(nolock) 
					where MAP_MA_MOD_ID = @Modello_Modulo 
						and MAP_MA_DZT_Name like  'MOD_' + @KeyRiga  + '_FLD_' +  @RG_FLD_TYPE + '%'
						and MAP_MA_DZT_Name not like  'MOD_' + @KeyRiga  + '_FLD_CUR_' +  @RG_FLD_TYPE + '%'


			-- riporto eventuali properti presenti
			insert into CTL_ModelAttributeProperties (  MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module )
				select MAP_MA_MOD_ID, 
						'MOD_' + @KeyRiga  + '_FLD_CUR_N' + cast( @ix as varchar(5)) +  dbo.GetPos( MAP_MA_DZT_Name , '_FLD_CUR_' , 2) as MAP_MA_DZT_Name, 
						MAP_Propety, MAP_Value, MAP_Module 
					from CTL_ModelAttributeProperties with(nolock) 
					where MAP_MA_MOD_ID = @Modello_Modulo 
						and MAP_MA_DZT_Name like  'MOD_' + @KeyRiga  + '_FLD_CUR_' +  @RG_FLD_TYPE + '%'




			set @ix = @ix +1
		end



		FETCH NEXT FROM CurModuloRequest 	INTO @KeyRiga   , @RG_FLD_TYPE , @ItemPath
	END 
	CLOSE CurModuloRequest
	DEALLOCATE CurModuloRequest


	-- aggiungo la MAXLEN per i campi testo a 1000 caratteri
	insert into CTL_ModelAttributeProperties ( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module )
		select MA_MOD_ID as MAP_MA_MOD_ID, MA_DZT_Name as MAP_MA_DZT_Name, 'MaxLen' as MAP_Propety, '1000' as MAP_Value, '' as MAP_Module
			from CTL_ModelAttributes  with(nolock) 
			where ma_mod_id = @Modello_Modulo and DZT_Type = 1
	
	-- aggiungo la Width per i campi testo a 1000 caratteri
	insert into CTL_ModelAttributeProperties ( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module )
		select MA_MOD_ID as MAP_MA_MOD_ID, MA_DZT_Name as MAP_MA_DZT_Name, 'Width' as MAP_Propety, '95%' as MAP_Value, '' as MAP_Module
			from CTL_ModelAttributes with(nolock) 
			where ma_mod_id = @Modello_Modulo and DZT_Type in ( 1 , 3 ) 

	-- aggiungo gli on change per aprire e chiudere i gruppi
	insert into CTL_ModelAttributeProperties ( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module )
		select MA_MOD_ID as MAP_MA_MOD_ID, MA_DZT_Name as MAP_MA_DZT_Name, 'OnChange' as MAP_Propety, 'OnChangeScelta( this );' as MAP_Value, '' as MAP_Module
			from CTL_ModelAttributes  with(nolock) 
			where ma_mod_id = @Modello_Modulo and DZT_Type = 4 and DZT_DM_ID in ( 'SiNo_Modulo' , 'SiNoAltro' )


	-- aggiungo una classe specifica per gli attributi che hanno il domio Year associato
	insert into CTL_ModelAttributeProperties ( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module )
		select MA_MOD_ID as MAP_MA_MOD_ID, MA_DZT_Name as MAP_MA_DZT_Name, 'Style' as MAP_Propety,  'YearDomain' as MAP_Value, '' as MAP_Module
			from CTL_ModelAttributes with(nolock) 
			where ma_mod_id = @Modello_Modulo and DZT_Type = 4 and DZT_DM_ID in ( 'Year' )


	---------------------------------------------------------------------------------------------
	-- tolgo dal modello tutti gli attrbuti utilizzati come segnaposto per generare i gruppi iterativi
	---------------------------------------------------------------------------------------------
	--delete from CTL_ModelAttributes where MA_MOD_ID = @Modello_Modulo and MA_DZT_Name in ( select  MA_DZT_Name  from #ToDelete )
	--delete from CTL_ModelAttributeProperties where MAP_MA_MOD_ID = @Modello_Modulo and MAP_MA_DZT_Name in ( select  MA_DZT_Name  from #ToDelete )

	
	---------------------------------------------------------------------------------------------
	-- MODELLO PER IL SALVATAGGIO
	-- genero il modello per copia dalla visualizzazione togliendo tutti gli attributi non editabili
	---------------------------------------------------------------------------------------------

	insert into CTL_Models (  MOD_ID, MOD_Name, MOD_DescML, MOD_Type, MOD_Sys, MOD_help, MOD_Param, MOD_Module, MOD_Template )
		select @Modello_Modulo + '_SAVE' as MOD_ID, @Modello_Modulo + '_SAVE' as MOD_Name, @Modello_Modulo + '_SAVE' as MOD_DescML, 1 as MOD_Type, 1 as MOD_Sys, '' as MOD_help, '' as MOD_Param, 'DOCUMENT_TEMPLATE' as MOD_Module , @Template as  MOD_Template  


	IF @InCaricoA = 'Ente'
	begin

		select  
			upper( 'MOD_' + replace( k.value , '.' , '_' )  + '_FLD_' +   dbo.GetID_ElementModulo ( ItemPath , ItemLevel  , TypeRequest ) ) as A
			, upper( 'MOD_' + replace( k.value , '.' , '_' )  + '_FLD_CUR_' +   dbo.GetID_ElementModulo ( ItemPath , ItemLevel  , TypeRequest ) ) as B
			
			into #T1
    					   
				from CTL_DOC_Value t with(nolock)
					
				inner join CTL_DOC_Value k  with(nolock) on t.idheader = k.idheader and t.Row = k.Row and k.DSE_ID = 'VALORI' and k.DZT_Name = 'KeyRiga'
				inner join CTL_DOC_Value M with(nolock) on t.idheader = M.idheader and t.Row = M.Row and M.DSE_ID = 'VALORI' and M.DZT_Name = 'IdModulo'
				inner join DOCUMENT_REQUEST_GROUP G with(nolock) on G.idheader = M.value

					
			where t.idHeader=@idTemplate and t.DSE_ID = 'VALORI' and t.DZT_Name = 'REQUEST_PART' and t.value = 'Modulo' AND ISNULL( G.RG_FLD_TYPE , '' ) <> '' 

			and 
				isnull( G.InCaricoA , '' ) = 'Ente'  
						

		insert into CTL_ModelAttributes ( MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order , DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_Len, DZT_Dec, DZT_Format, DZT_Help, DZT_Multivalue, MA_Module ) 
			select MA_MOD_ID + '_SAVE' , MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order , DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_Len, DZT_Dec, DZT_Format, DZT_Help, DZT_Multivalue, MA_Module
				from CTL_ModelAttributes with(nolock) 
					inner join #T1 on MA_DZT_Name = A or MA_DZT_Name = B
				where  MA_MOD_ID = @Modello_Modulo 
				
					----and MA_DZT_Name not in ( 
					----				    select MAP_MA_DZT_Name 
					----							from CTL_ModelAttributeProperties 
					----							where  
					----								MAP_MA_MOD_ID = @Modello_Modulo and MAP_Propety = 'Editable' and MAP_Value = '0'
					----							)


					----considero nel modello di salvataggio tutti gli attributi di pertinenza dell'ente
					--and MA_DZT_Name in ( 
				    
					--   select  
					--	upper( 'MOD_' + replace( k.value , '.' , '_' )  + '_FLD_' +   dbo.GetID_ElementModulo ( ItemPath , ItemLevel  , TypeRequest ) ) as A
					--	, upper( 'MOD_' + replace( k.value , '.' , '_' )  + '_FLD_CUR_' +   dbo.GetID_ElementModulo ( ItemPath , ItemLevel  , TypeRequest ) ) as B
    					   
					--	   from CTL_DOC_Value t with(nolock)
					
					--		inner join CTL_DOC_Value k  with(nolock) on t.idheader = k.idheader and t.Row = k.Row and k.DSE_ID = 'VALORI' and k.DZT_Name = 'KeyRiga'
					--		inner join CTL_DOC_Value M with(nolock) on t.idheader = M.idheader and t.Row = M.Row and M.DSE_ID = 'VALORI' and M.DZT_Name = 'IdModulo'
					--		inner join DOCUMENT_REQUEST_GROUP G with(nolock) on G.idheader = M.value

					
					--	where t.idHeader=@idTemplate and t.DSE_ID = 'VALORI' and t.DZT_Name = 'REQUEST_PART' and t.value = 'Modulo' AND ISNULL( G.RG_FLD_TYPE , '' ) <> '' 

					--	and 
					--		isnull( G.InCaricoA , '' ) = 'Ente'  
						
					--)
				
				
	end


	---------------------------------------------------------------------------------------------
	-- compongo la sequenza di campi obligatori
	---------------------------------------------------------------------------------------------
	declare @Obblig varchar(max)
	set @Obblig = '["'
	select @Obblig  = @Obblig  + MAP_MA_DZT_Name + '","' 
		from CTL_ModelAttributeProperties with(nolock) 
			inner join ctl_modelattributes with(nolock) on ma_mod_id=map_ma_mod_id and ma_dzt_name=map_ma_dzt_name
		where  MAP_MA_MOD_ID = @Modello_Modulo and MAP_Propety = 'Obbligatory' and MAP_Value = '1'
			and MAP_MA_DZT_Name not in ( select  MA_DZT_Name  from #ToDelete )
	set @Obblig = @Obblig + '"]'
	
	update ctl_doc set Body = @Obblig where id = @idDocInUse and tipodoc = 'MODULO_TEMPLATE_REQUEST'


	---------------------------------------------------------------------------------------------
	-- MODELLO PER L'ENTE 
	-- viene rimossa la non editabilità per lasciargli piena visione - il salvataggio porterà su disco solo i dati corretti
	---------------------------------------------------------------------------------------------
	if @InCaricoA = 'Ente' and @idTemplate = @idDoc
	begin
	 
		delete from CTL_ModelAttributeProperties where  MAP_MA_MOD_ID = @Modello_Modulo and MAP_Propety = 'Editable' and MAP_Value = '0'

	end


end


























GO
