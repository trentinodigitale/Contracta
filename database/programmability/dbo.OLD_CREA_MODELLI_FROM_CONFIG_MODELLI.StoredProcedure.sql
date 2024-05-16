USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CREA_MODELLI_FROM_CONFIG_MODELLI]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE PROC [dbo].[OLD_CREA_MODELLI_FROM_CONFIG_MODELLI] (@NomeModello as varchar(500) , @Att as varchar(50) ,  @idDoc as int , @Modulo as varchar(200), @contesto as varchar(200) = 'LOTTO'  , @ColonneDaEscludere as varchar(200) = '' )
AS
BEGIN

	declare @MA_Pos int
	set @MA_Pos = 10
	declare @ModelloBase  as varchar(500)
	declare @NewNomeModello  as varchar(500)
	declare @MODELLO_BASE_RIFERIMENTO_CARATTERISTICHE_GRAFICHE as varchar(500)

	declare @Temp  table ( MA_MOD_ID  varchar(500) , MA_DZT_Name varchar(100) , MA_DescML  char(500), 
							MA_Pos smallint, MA_Len smallint, MA_Order smallint, MA_Module varchar(100), 
							stato nvarchar(max),numero_decimali int , MaxLen int 
							,TipoFile varchar(1000), RichiediFirma varchar(10) 
						 ) 

	-- il parametro opzionale @contesto sostituisce il precedente valore cablato 'LOTTO'. come parametro può essere passato tra i vari anche 'CONVENZIONE'

	if ( CHARINDEX('_MONOLOTTO',@NomeModello) > 0 ) 
	BEGIN
		set @ModelloBase = 'MODELLO_BASE_' + @contesto + '_' + @Att + '_MONOLOTTO' 
	END
	ELSE
	if ( CHARINDEX('_COMPLEX',@NomeModello) > 0 ) 
	BEGIN
		set @ModelloBase = 'MODELLO_BASE_' + @contesto + '_' + @Att + '_COMPLEX' 
	END
	ELSE
	BEGIN
		set @ModelloBase = 'MODELLO_BASE_' + @contesto + '_' + @Att  
	END

	set @NewNomeModello = @NomeModello + '_' + @Att  
	
	if @Att = 'MOD_Bando_LOTTI'
	begin
		set @Att = 'MOD_BandoSempl'
	end

	-- verifica la presenza dfi un modello di caratteristiche per contesto se non esiste prende quello di riferimento
	set @MODELLO_BASE_RIFERIMENTO_CARATTERISTICHE_GRAFICHE = 'MODELLO_BASE_' + @contesto + '_CARATTERISTICHE_GRAFICHE'
	if not exists( select * from LIB_Models where MOD_ID = @MODELLO_BASE_RIFERIMENTO_CARATTERISTICHE_GRAFICHE )
		set @MODELLO_BASE_RIFERIMENTO_CARATTERISTICHE_GRAFICHE = 'MODELLO_BASE_RIFERIMENTO_CARATTERISTICHE_GRAFICHE'
		


	-- creo la base obbligatoria partendo da un modello base
	exec CopiaModello  @NewNomeModello, @ModelloBase , @Modulo 

	--una volta creata la base obbligatoria
	--se il modulo dell'ampiezza di gamma non è attivo, rimuove gli elementi del modello base conducibili all'ampiezza di gamma
	IF not EXISTS (	select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI' and ',' + DZT_ValueDef + ',' like '%,AMPIEZZA_DI_GAMMA,%'	)
	begin 		
		--elimino l'attributo fnz_open con la lentina che apre il documento di ampiezza di gamma
		delete from CTL_ModelAttributes where MA_MOD_ID = @NewNomeModello and MA_DZT_Name = 'FNZ_OPEN' and MA_DescML = 'AMP Gamma'

		--elimino li check sul bando per la presenza dell'ampiezza di gamma
		delete from CTL_ModelAttributes where MA_MOD_ID = @NewNomeModello and MA_DZT_Name = 'AmpiezzaGamma' and MA_DescML = 'AMP Gamma' 
	end

	-- inserisce il modello
	--	insert into LIB_Models ( MOD_ID, MOD_Name, MOD_DescML, MOD_Type, MOD_Sys, MOD_Param, MOD_Module )
	--		values( @NomeModello ,@NomeModello ,@NomeModello , 1 , 0	, ''           , @Modulo )

	--select @MA_Pos = max( MA_Pos ) from LIB_ModelAttributes  where MA_MOD_ID = @NewNomeModello
	select @MA_Pos = max( MA_Pos ) from CTL_ModelAttributes with (nolock)  where MA_MOD_ID = @NewNomeModello

	-- Se il modello di base è vuoto il @ma_pos sarà vuoto. quindi lo riavvaloriamo con il default
	IF isnull(@ma_pos ,'') = ''
	BEGIN
		set @MA_Pos = 10
	END

	
	delete @Temp
	
	---SOLO PER I MODELLI INFO_ADD i campi del dizionario che iniziano per 'CAMPO_TESTO_% LI METTIAMO A 200

	insert into @Temp (MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order, MA_Module, stato,
				Numero_Decimali,MaxLen,TipoFile, RichiediFirma )
		select @NewNomeModello as MA_MOD_ID , a.Value as MA_DZT_Name , dbo.HTML_Encode(v1.Value) as MA_DescML , a.Row + @MA_Pos + 1 as MA_Pos,
			case  
				when  @contesto = 'INFO_ADD'  AND  a.Value like 'CampoTesto_%' then 100
				when DZT_Len  is null and  m.MA_Len is null then 10 
				when DZT_Len > 50 and  m.MA_Len is null  then 50
				else isnull( m.MA_Len  ,DZT_Len )
			end as MA_Len 
			, a.Row + @MA_Pos + 1  as MA_Order
			, @Modulo as MA_Module			
			, v.Value as stato
			,case when v2.Value='' then -1 else v2.Value end  as Numero_Decimali
			,case
				when @contesto = 'INFO_ADD' AND  a.Value like 'CampoTesto_%' and isnull(DZT_Len,0) > 100  then DZT_Len
				when @contesto <> 'INFO_ADD' and isnull(DZT_Len,0) > 50  then DZT_Len
				else -1 
			end as MaxLen 
			,
			case
				when d.DZT_Type <> 18 then '-1' 
				else isnull(v3.value,'-1')
			end as TipoFile		
			,
			case
				when d.DZT_Type <> 18 then '-1' 
				else isnull(v4.value,'-1')
			end as RichiediFirma	
		--into #Temp
		from CTL_DOC_Value a
			inner join CTL_DOC_Value v  with (nolock) on a.IdHeader = v.IdHeader and @Att = v.DZT_Name and v.Value <> '' and a.Row = v.Row  and v.DSE_ID = 'MODELLI'
			inner join CTL_DOC_Value v1 with (nolock) on a.IdHeader = v1.IdHeader and v1.DZT_Name = 'Descrizione' and a.Row = v1.Row and v1.DSE_ID = 'MODELLI'
			left join CTL_DOC_Value v2 with (nolock) on a.IdHeader = v2.IdHeader and v2.DZT_Name = 'Numero_Decimali' and a.Row = v2.Row and v2.DSE_ID = 'MODELLI'
			left join CTL_DOC_Value v3 with (nolock) on a.IdHeader = v3.IdHeader and v3.DZT_Name = 'TipoFile' and a.Row = v3.Row and v3.DSE_ID = 'MODELLI'
			left join CTL_DOC_Value v4 with (nolock) on a.IdHeader = v4.IdHeader and v4.DZT_Name = 'RichiediFirma' and a.Row = v4.Row and v4.DSE_ID = 'MODELLI'
			inner join LIB_Dictionary d with (nolock) on a.Value = d.DZT_Name
			left join  LIB_ModelAttributes m with(nolock) on m.ma_mod_id = @MODELLO_BASE_RIFERIMENTO_CARATTERISTICHE_GRAFICHE and a.Value = m.MA_DZT_Name
		where a.IdHeader = @idDoc and a.DSE_ID = 'MODELLI'
			and a.DZT_Name = 'DZT_Name'
			
			-- l'attributo non deve essere presente nelel colonne da escludere
			and charindex(  ',' + a.Value + ',' , ',' + @ColonneDaEscludere + ','   ) = 0

	IF @@ERROR <> 0 
	BEGIN
		raiserror ('Errore creazione tabella temporanea in CREA_MODELLI_FROM_CONFIG_MODELLI. ', 16, 1)
		return 99
	END 

	-- inserisce le righe
	--insert into LIB_ModelAttributes ( MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order, MA_Module )
    insert into CTL_ModelAttributes ( MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order, MA_Module,DZT_Dec )
	select  MA_MOD_ID, MA_DZT_Name, case when stato in ( 'obblig' , 'chiave' ) then '<div class="Grid_CaptionObblig">' else ''  end  + RTRIM(MA_DescML) + case when numero_decimali > 0 then ' ( ' + cast(numero_decimali as varchar(50)) + ' dec. )' else '' end + case when stato in ( 'obblig' , 'chiave' ) then '</div>' else ''  end, MA_Pos, MA_Len, MA_Order, MA_Module,case when numero_decimali > -1 then numero_decimali else NULL end
		--from  #Temp
		from @Temp

	IF @@ERROR <> 0 
	BEGIN
		--drop table #Temp
		delete @Temp
		raiserror ('Errore popolamento LIB_ModelAttributes in CREA_MODELLI_FROM_CONFIG_MODELLI. ', 16, 1)
		return 99
	END 

	-- definisce le righe editabili da quelle no
	--insert into LIB_ModelAttributeProperties 
	insert into CTL_ModelAttributeProperties 
			( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module )
		select  MA_MOD_ID, MA_DZT_Name,  'Editable' as MAP_Propety, case when stato in ( 'lettura' , 'calc'  )  then '0' else '1' end as  MAP_Value, MA_Module
			--from  #Temp
			from @Temp

	IF @@ERROR <> 0 
	BEGIN
		--drop table #Temp
		delete @Temp
		raiserror ('Errore popolamento LIB_ModelAttributeProperties in CREA_MODELLI_FROM_CONFIG_MODELLI. ', 16, 1)
		return 99
	END 
			
	-- definisce le righe obbligatorie
	--insert into LIB_ModelAttributeProperties 
    insert into CTL_ModelAttributeProperties 
			( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module )
		select  MA_MOD_ID, MA_DZT_Name,  'Obbligatory' as MAP_Propety, '1' as  MAP_Value, MA_Module
			--from  #Temp
			from @Temp
			where stato in ( 'obblig' , 'chiave' )

	IF @@ERROR <> 0 
	BEGIN
		--drop table #Temp
		delete @Temp
		raiserror ('Errore popolamento LIB_ModelAttributeProperties in CREA_MODELLI_FROM_CONFIG_MODELLI. ', 16, 1)
		return 99
	END 

	-- definisce la format con il numero di decimali richiesto
	--insert into LIB_ModelAttributeProperties 
    insert into CTL_ModelAttributeProperties 
			( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module )
		select  MA_MOD_ID, MA_DZT_Name,  'format' as MAP_Propety, '###,##0.' + REPLICATE('0',numero_decimali)  + '~'as  MAP_Value, MA_Module
			--from  #Temp
			from @Temp
				inner join LIB_Dictionary d with (nolock) on MA_DZT_Name = d.DZT_Name and d.DZT_Type in ( '2' , '7' ) -- solo per i numerici
			where numero_decimali > 0 

	insert into CTL_ModelAttributeProperties 
			( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module )
		select  MA_MOD_ID, MA_DZT_Name,  'format' as MAP_Propety, '###,##0~' as  MAP_Value, MA_Module
			--from  #Temp
			from @Temp
				inner join LIB_Dictionary d with (nolock) on MA_DZT_Name = d.DZT_Name and d.DZT_Type in ( '2' , '7' ) -- solo per i numerici
			where numero_decimali = 0
	
	--definisco la format per gli attributi attach
	--controllando se sono definite le estensioni
	--oppure se definito richiedi firma
	
	declare @AllegatoMultiValore as varchar(10)

	select @AllegatoMultiValore = dbo.PARAMETRI('CREA_MODELLI_FROM_CONFIG_MODELLI','AllegatiMultiValore','DefaultValue','NO',-1)

	insert into CTL_ModelAttributeProperties 
		( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module )
		select 
				MA_MOD_ID, MA_DZT_Name,  'format' as MAP_Propety, 
				
				case 
					when  ISNULL(DZT_Format,'') = '' then 'HINT' 
					else  DZT_Format
				end 
				+
				case 
					when  @AllegatoMultiValore = 'YES' and charindex( 'M' , ISNULL(DZT_Format,'')) = 0 then 'M' 
					else  DZT_Format
				end 
				+
				case
					when RichiediFirma='1' and charindex('V',ISNULL(DZT_Format,'')) = 0 then  'V'
					else ''
				end
				
				--ATT.508001 EP
				--commentato per fare in modo che sul download del file
				--se richiedifirma=1 non venga scaricato il file privo di busta
				--+
				--case
				--	when RichiediFirma='1' and charindex('B',ISNULL(DZT_Format,'')) = 0 then  'B'
				--	else ''
				--end
				+ 
				case 
					when TipoFile <>'' then 
						 'EXT:' + SUBSTRING ( REPLACE(TipoFile ,'###',','),2,len( REPLACE(TipoFile ,'###',','))-2) + '-'
					else ''
				end  As MAP_Value
			
				, MA_Module
			
			from @Temp
				inner join LIB_Dictionary with (nolock) on DZT_Name = MA_DZT_Name and DZT_Type=18			
			where 
				TipoFile <> '-1' or RichiediFirma <> '-1'

	IF @@ERROR <> 0 
	BEGIN
		--drop table #Temp
		delete @Temp
		raiserror ('Errore popolamento LIB_ModelAttributeProperties in CREA_MODELLI_FROM_CONFIG_MODELLI. ', 16, 1)
		return 99
	END 
	
	
	
	-- definisco la proproietà maxlen
	insert into CTL_ModelAttributeProperties 
			( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module )
		select  MA_MOD_ID, MA_DZT_Name,  'MaxLen' as MAP_Propety, MaxLen, MA_Module
			from @Temp 
			where maxlen <> -1
    
    -- definisco la proproietà wrap
	insert into CTL_ModelAttributeProperties 
			( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module )
		select  MA_MOD_ID, MA_DZT_Name,  'Wrap' as MAP_Propety, '1', MA_Module
			from @Temp 
			where maxlen <> -1

	IF @@ERROR <> 0 
	BEGIN
		--drop table #Temp
		delete @Temp
		raiserror ('Errore popolamento roproietà maxlen CTL_ModelAttributeProperties in CREA_MODELLI_FROM_CONFIG_MODELLI. ', 16, 1)
		return 99
	END 
			
			
	-- Ricopio le properti di base
 -- insert into LIB_ModelAttributeProperties 
	insert into CTL_ModelAttributeProperties 
			( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module )
		select  MA_MOD_ID, MA_DZT_Name, p.MAP_Propety, p.MAP_Value, MA_Module 
			--from  #Temp t 
			 from @Temp t
				inner join LIB_ModelAttributeProperties p with (nolock) on p.MAP_MA_MOD_ID = @MODELLO_BASE_RIFERIMENTO_CARATTERISTICHE_GRAFICHE
				--inner join CTL_ModelAttributeProperties p with (nolock) on p.MAP_MA_MOD_ID = 'MODELLO_BASE_' + @contesto + '_CARATTERISTICHE_GRAFICHE'
																	and p.MAP_MA_DZT_Name = t.MA_DZT_Name
			
	---- INSERISCO PER TUTTE LE COLONNE UAN WITH MINIMA PER OTTENERE UNA COLONNA PICCOLA SE NON HA CONTENUTO
	--insert into CTL_ModelAttributeProperties 
	--		( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module )
	--	select  MA_MOD_ID, MA_DZT_Name, 'Width' as MAP_Propety, '10' as MAP_Value, MA_Module 
	--		 from @Temp t
	--			LEFT join CTL_ModelAttributeProperties p with (nolock) on p.MAP_MA_MOD_ID = T.MA_MOD_ID
	--																and p.MAP_MA_DZT_Name = t.MA_DZT_Name AND P.MAP_Propety = 'Width'
	--			inner join LIB_Dictionary d with(nolock) on d.DZT_Name = t.MA_DZT_Name  
	--		where p.MAP_ID is null and d.DZT_Type not in ( 2 ) 

		
	IF @@ERROR <> 0 
	BEGIN
		--drop table #Temp
		delete @Temp
		raiserror ('Errore popolamento LIB_ModelAttributeProperties,caratteristiche grafiche.In CREA_MODELLI_FROM_CONFIG_MODELLI. ', 16, 1)
		return 99
	END 			

	--drop table #Temp

END



























GO
