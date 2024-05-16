USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[MODULO_REQUEST_GET_FIELD]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[MODULO_REQUEST_GET_FIELD]( @idDocModuloDGUE int  )
AS
BEGIN



	declare @idTemplate int -- 
	declare @TipoDoc varchar(500)
	DECLARE @idTemplatContest int
	declare @idDoc int
	declare @JumpCheck  varchar(500)


	select @idTemplatContest = LinkedDoc , @JumpCheck = JumpCheck from CTL_DOC where id = @idDocModuloDGUE

	---- dal modulo ricavo il template utilizzato per generarlo navigando la struttura all'indietro 
	set @tipoDoc = ''
	
	while @TipoDoc not in ( 'TEMPLATE_REQUEST' , 'TEMPLATE_CONTEST' , 'BANDO' , 'BANDO_SDA' , 'BANDO_SEMPLIFICATO' , 'BANDO_GARA' )
	begin
		select @idTemplatContest = LinkedDoc , @tipoDoc = Tipodoc from CTL_DOC where id = @idTemplatContest
		select @tipoDoc = Tipodoc from CTL_DOC where id = @idTemplatContest
	end

	-- arrivato sul bando cerco il template relativo al tipo di DGUE che ho come riferimento
	if @TipoDoc in ( 'BANDO' , 'BANDO_SDA' , 'BANDO_SEMPLIFICATO' , 'BANDO_GARA'  ) 
		if exists( select id  
						from CTL_DOC 
						where LinkedDoc = @idTemplatContest  
							and TipoDoc = 'TEMPLATE_CONTEST'
							and JumpCheck = @JumpCheck 
				 )
	begin
		select @idTemplatContest = id , @tipoDoc = Tipodoc 
			from CTL_DOC 
			where LinkedDoc = @idTemplatContest  and TipoDoc = 'TEMPLATE_CONTEST'
				
				and JumpCheck = @JumpCheck -- template specifico
	end
	else -- se non trovo il template relativo prendo quello che trovo ma c'è da approfondire la mancanza
	begin
		select @idTemplatContest = id , @tipoDoc = Tipodoc 
			from CTL_DOC 
			where LinkedDoc = @idTemplatContest  and TipoDoc = 'TEMPLATE_CONTEST'
	end


	---- recupera l'id del template nel caso in cui è stato passato il template specifico e non base
	select @idTemplate = case when TipoDoc = 'TEMPLATE_REQUEST' then id else idDoc end  from ctl_doc where id = @idTemplatContest



	-- recupero se il documento in uso è di un ente o di un oe
	declare @InCaricoA varchar(50)
	select  @InCaricoA = case when aziAcquirente <> 0 then 'Ente' else 'OE' end 
		from ctl_doc d with(nolock)
		inner join profiliutente p with(nolock) on p.idpfu = d.IdPfu
		inner join aziende a on p.pfuidazi = a.idazi
			where id = @idDocModuloDGUE
	
	set @InCaricoA = isnull( @InCaricoA , 'Ente')
	


	-- creo la tabella temporanea
	select top 0 
				
		cast( '' as varchar(500)) as MA_DZT_Name ,
		cast( '' as varchar(500)) as UUID ,
		cast( 0 as int ) as  idRow

		into #Attrib


	---- colleziono i guid dei campi usati sul DGUE del documento
	insert into #Attrib ( MA_DZT_Name , UUID , idRow )
		select 
				
			upper( 'MOD_' + replace( k.value , '.' , '_' )  + '_FLD_' +   dbo.GetID_ElementModulo ( ItemPath , ItemLevel  , TypeRequest ) ) 
				as MA_DZT_Name
			,G.UUID
			,G.idRow

			from CTL_DOC_Value t with(nolock) -- template base
				--inner join CTL_DOC_Value a  with(nolock) on t.idheader = a.idheader and t.Row = a.Row and a.DSE_ID = 'VALORI' and a.DZT_Name = 'TEMPLATE_REQUEST_GROUP'
				inner join CTL_DOC_Value k  with(nolock) on t.idheader = k.idheader and t.Row = k.Row and k.DSE_ID = 'VALORI' and k.DZT_Name = 'KeyRiga'
				inner join CTL_DOC_Value M on t.idheader = M.idheader and t.Row = M.Row and M.DSE_ID = 'VALORI' and M.DZT_Name = 'IdModulo'
				inner join DOCUMENT_REQUEST_GROUP G  with(nolock) on G.idheader = M.value


				-- recupera le spunte di SelRow per portare solo gli elementi scelti
				inner join CTL_DOC_Value k2 on k2.idheader = @idTemplatContest and k2.DSE_ID = 'VALORI' and k2.DZT_Name = 'KeyRiga' and k.Value = k2.Value
				inner join CTL_DOC_Value S on S.idheader = @idTemplatContest and k2.Row = S.Row and S.DSE_ID = 'VALORI' and S.DZT_Name = 'SelRow'

				-- verifica se la sezione è removibile
				inner join CTL_DOC_Value R on t.idheader = R.idheader and t.Row = R.Row and R.DSE_ID = 'VALORI' and R.DZT_Name = 'Removibile'

			where 
				t.idHeader=@idTemplate and t.DSE_ID = 'VALORI' and t.DZT_Name = 'REQUEST_PART' and t.value = 'Modulo' AND ISNULL( G.RG_FLD_TYPE , '' ) <> '' 

				and 

					-- solo gli editabili se la condizione esprime la non editabilità negandola dovrei prendere gli editabili
				( 
					(
						isnull( s.value , '1' )  = '1' -- un elemento non selezionato indica che non è stato scelto quindi non editabile
						--or 
						--R.value <> '1'
					)
					and
					( @InCaricoA = G.InCaricoA  or isnull( G.InCaricoA , '' ) = '' ) -- non è editabile se la tipologia dell'utente non coincide
					and 
					( isnull( G.Edit , 0 ) <> 1 ) -- la spunta indica che è un attributo con sorgente ed è richiesto non editabile

				)


	-- aggiungo i currency
	insert into #Attrib  ( MA_DZT_Name , UUID , idRow )
		select 
			replace ( MA_DZT_Name , '_FLD_' , '_FLD_CUR_' ) as MA_DZT_Name 
			, 'CUR_' + a.UUID as UUID
			,a.idRow
			from #Attrib a
					inner join DOCUMENT_REQUEST_GROUP G  with(nolock) on G.idRow = a.idRow
			where G.RG_FLD_TYPE = 'Currency'



	declare @UUID nvarchar(100)
	declare @IdRow int
	declare @NRow int
	declare @ix int
	declare @KeyRiga varchar(500)
	declare @Modello_Modulo varchar(1000)
	declare @RG_FLD_TYPE varchar(max)
	declare @ItemPath varchar(max)

	select @Modello_Modulo = MOD_Name from CTL_DOC_SECTION_MODEL where idheader = @idDocModuloDGUE and [DSE_ID] = 'MODULO'

	-------------------------------------------
	-- per ogni gruppo  iterabile 
	-------------------------------------------
	declare CurModuloRequest Cursor LOCAL static for 
		select upper(  replace( k.value , '.' , '_' ) ) as KeyRiga ,   dbo.GetID_ElementModulo ( ItemPath , ItemLevel  , TypeRequest ) as DZT_Name ,ItemPath , g.UUID , g.idRow

			from CTL_DOC_Value t with(nolock)
				inner join CTL_DOC_Value a  with(nolock) on t.idheader = a.idheader and t.Row = a.Row and a.DSE_ID = 'VALORI' and a.DZT_Name = 'TEMPLATE_REQUEST_GROUP'
				inner join CTL_DOC_Value k  with(nolock) on t.idheader = k.idheader and t.Row = k.Row and k.DSE_ID = 'VALORI' and k.DZT_Name = 'KeyRiga'
				--inner join CTL_DOC M  with(nolock) on M.TipoDoc = 'TEMPLATE_REQUEST_GROUP' and replace( cast( m.numerodocumento as varchar(500)) , '-' , '_' ) = a.Value --TEMPLATE_REQUEST_GROUP
				--inner join DOCUMENT_REQUEST_GROUP G  with(nolock) on G.idheader = M.id and Iterabile = 1

				inner join CTL_DOC_Value M on t.idheader = M.idheader and t.Row = M.Row and M.DSE_ID = 'VALORI' and M.DZT_Name = 'IdModulo'
				inner join DOCUMENT_REQUEST_GROUP G  with(nolock) on G.idheader = M.value and Iterabile = 1

			where t.idHeader=@idTemplate and t.DSE_ID = 'VALORI' and t.DZT_Name = 'REQUEST_PART' and t.value = 'Modulo' 


	open CurModuloRequest


	---------------------------------------------
	---- ciclo per il numero di occorrenze, recuperato dal documento per generare gli attributi
	---------------------------------------------

	FETCH NEXT FROM CurModuloRequest 	INTO @KeyRiga   , @RG_FLD_TYPE , @ItemPath , @UUID , @IdRow
	WHILE @@FETCH_STATUS = 0
	BEGIN

		set @NRow = 0
		select @NRow = value from CTL_DOC_Value where idheader = @idDocModuloDGUE and DZT_Name = @KeyRiga + '@@@' + @ItemPath and DSE_ID = 'ITERAZIONI'		
		if isnull( @NRow , 0 ) = 0 
			set @NRow = 1

		insert into #Attrib  ( MA_DZT_Name , UUID , idRow )
			values ( @KeyRiga + '@@@' + @ItemPath  , 'ITERAZIONI-' + @UUID , 0 )


		set @ix = 0 
		while @ix < @NRow
		begin
			
			-- genera le istanze per gli attributi 
			insert into #Attrib  ( MA_DZT_Name , UUID , idRow )
				select 'MOD_' + @KeyRiga  + '_FLD_N' + cast( @ix as varchar(5)) +  dbo.GetPos( MA_DZT_Name , '_FLD_' , 2) as MA_DZT_Name, 
						'N_'  + cast( @ix as varchar(5)) + '_' + UUID , 
						@IdRow
					--from CTL_ModelAttributes  
					from #Attrib 
					where --MA_MOD_ID = @Modello_Modulo  and 
							MA_DZT_Name like  'MOD_' + @KeyRiga  + '_FLD_' +  @RG_FLD_TYPE + '%'
							and MA_DZT_Name not like  'MOD_' + @KeyRiga  + '_FLD_CUR_' +  @RG_FLD_TYPE + '%'


			-- genera le istanze per i domini currency
			insert into #Attrib  ( MA_DZT_Name , UUID , idRow )
				select 'MOD_' + @KeyRiga  + '_FLD_CUR_N' + cast( @ix as varchar(5)) +  dbo.GetPos( MA_DZT_Name , '_FLD_CUR_' , 2) as MA_DZT_Name, 
						'CUR_N_'  + cast( @ix as varchar(5)) + '_' + UUID , 
						@IdRow
					--from CTL_ModelAttributes
					from #Attrib 
					where  --MA_MOD_ID = @Modello_Modulo and 
						MA_DZT_Name like  'MOD_' + @KeyRiga  + '_FLD_CUR_' +  @RG_FLD_TYPE + '%'



			set @ix = @ix +1
		end



		FETCH NEXT FROM CurModuloRequest 	INTO @KeyRiga   , @RG_FLD_TYPE , @ItemPath , @UUID , @IdRow
	END 
	CLOSE CurModuloRequest
	DEALLOCATE CurModuloRequest


	-- ritorno l'elenco degli attributi associati all'identificativo UUID che esprime a livello universale il significato dell'attributo
	select MA_DZT_Name ,  UUID  from  #Attrib

end



GO
