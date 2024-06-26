USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GENERA_MODELLI_CONTESTO]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[GENERA_MODELLI_CONTESTO] 
		 (
			 @idDoc int, @IdUser as int
		 )
AS
BEGIN

	declare @Titolo varchar(1000)
	declare @Att varchar(100)

	--declare @idDoc int
	declare @Modulo varchar(1000)
	declare @Allegato varchar(255)
	declare @Descrizione varchar(2000)
	declare @NomeModello as varchar(1000)
	declare @NomeModelloC as varchar(1000)
	declare @NomeModelloM as varchar(1000)
	declare @contesto varchar(500)
	declare @TipoBandoScelta as nvarchar(500)
    
	declare @generaMultiLotto int
	declare @generaMonoLotto  int
	declare @generaComplex    int

	declare @NomeModelloFinale as varchar(1000)
	declare @TitoloFinale as varchar(1000)
	declare @MakeAllModel as int
	declare @IdGara as int
	declare @pcp_TipoScheda as varchar(100)
	declare @ModelloBaseInterop as varchar(500)

	SET @generaMultiLotto = 1
	SET @generaMonoLotto  = 1
	SET @generaComplex    = 1

	set @TipoBandoScelta=''
	SET @contesto = ''
	set @MakeAllModel = 0

	--set @idDoc = <ID_DOC>

	-- AD ES:  CONVENZIONI
	select @contesto = jumpCheck from ctl_doc with(nolock) where id = @idDoc

	-- Se è un documento CONFIG_MODELLI_LOTTI e non quello generico CONFIG_MODELLI
	if exists ( select id from ctl_doc with(nolock) where tipodoc = 'CONFIG_MODELLI_LOTTI' and id = @idDoc)
	BEGIN
		set @Modulo = 'MODELLI_LOTTI'
	END
	ELSE
	BEGIN
		set @Modulo = 'MODELLO_BASE_' + isnull(@contesto,'')
	END

	-- recupero il nome dei modelli
	select @Titolo = replace( Titolo , ' ' , '' ),  @Allegato = SIGN_ATTACH , @Descrizione = cast( Body as varchar(2000)) from ctl_doc where id = @idDoc
	--print @Titolo

	-- genero i modelli necessari per il funzionamento della gara
	set @NomeModello = @Modulo + '_' + @Titolo

	

	-- Se è un documento CONFIG_MODELLI_LOTTI e non quello generico CONFIG_MODELLI
	if exists ( select id from ctl_doc where tipodoc = 'CONFIG_MODELLI_LOTTI' and id = @idDoc)
	BEGIN

		select @TipoBandoScelta=[value] , @IdGara=gara.id
			from ctl_doc modello with(nolock)
					inner join ctl_doc gara with(nolock) on gara.id = modello.LinkedDoc
					inner join ctl_doc_value with(nolock) on IdHeader = gara.id and dzt_name='TipoBandoScelta'  and DSE_ID='TESTATA_PRODOTTI'
			where modello.id = @IdDoc 

		if CHARINDEX('_MONOLOTTO',@TipoBandoScelta) <= 0
		   SET @generaMonoLotto  = 0

		if CHARINDEX('_COMPLEX',@TipoBandoScelta) <= 0
		   SET @generaComplex    = 0

		set @NomeModelloC = @Modulo + '_' + @Titolo + '_COMPLEX'
		set @NomeModelloM = @Modulo + '_' + @Titolo + '_MONOLOTTO'


		----------------------------------------------------------------------------------------------------------------------------				
		-- genero il modello per l'inserimento dell'offerta dato dall'unione dei due modelli di offerta tecnica ed offerta economica
		----------------------------------------------------------------------------------------------------------------------------				
		delete from ctl_doc_value where IdHeader = @idDoc and  DSE_ID = 'MODELLI' and DZT_Name = 'MOD_OffertaINPUT' 

		insert into ctl_doc_value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
			select s.idHeader , s.DSE_ID, s.Row , 'MOD_OffertaINPUT' , 

				case when isnull( e.Value  , '' ) = 'calc' or isnull( t.Value , '' ) = 'calc' then 'calc' 
					else
						case when isnull( e.Value , '' ) = 'obblig' or isnull ( t.Value , '' ) = 'obblig' then 'obblig' 
							else
								case when isnull ( e.Value , '' ) = 'scrittura' or isnull( t.Value , '' ) = 'scrittura' then 'scrittura' 
									else
										case when isnull( e.Value  , '' ) = 'lettura' or isnull( t.Value , '' ) = 'lettura' then 'lettura' 
											else ''
										end
								end
						end
				end as Value
				from ctl_doc_value s with(nolock)
					left outer join ctl_doc_value t with(nolock) on s.idheader = t.idheader  and t.dzt_name = 'MOD_OffertaTec' and s.row = t.row and t.DSE_ID = 'MODELLI'
					left outer join ctl_doc_value e with(nolock) on s.idheader = e.idheader  and e.dzt_name = 'MOD_Offerta'    and s.row = e.row and e.DSE_ID = 'MODELLI'
				where s.idheader = @idDoc and s.dzt_name = 'DZT_Name' and ( isnull( e.Value , '' ) <>  '' or isnull( t.Value , '' ) <> '' ) 
				order by s.row
		----------------------------------------------------------------------------------------------------------------------------				
		

		--ENRPAN-FRA: SE SI TRATTA DI MODELLO BASE DI CONFIGURAZIONE NON LEGATO AD UNA GARA DEVE CONTINUARE A GENERARE 3 MODELLI DISTINTI PER TUTTE LE TIPOLOGIE
		--ALTRIMENTI SULLA GARA IN SELEZIONE, A SECONDA DELL'AMBITO, NON USCIREBBERO I MODELLI NELLA COMBO "Modello Offerta" (TipoBandoScelta) 
		
		if ltrim(rtrim(@TipoBandoScelta)) = ''
		begin
			Set @MakeAllModel = 1
		end

		---ENRPAN sostituito il codice sottostante con unico blocco con nome modello appropriato---------------------------------------------------------
		---PER I MODELLI DI CONFIGURAZIONE CREA IL MODELLO SEMPLICE , SULLE GARE QUELLO APPROPRIATO
		if @generaComplex = 0 and @generaMonoLotto = 0
		begin
			set @NomeModelloFinale = @NomeModello  
			set @TitoloFinale = @Titolo
		end
			
		IF @generaComplex = 1
		begin
			set @NomeModelloFinale = @NomeModelloC  
			set @TitoloFinale = @Titolo + '_COMPLEX'
		end
			
		IF @generaMonoLotto = 1
		begin
			set @NomeModelloFinale = @NomeModelloM
			set @TitoloFinale = @Titolo + '_MONOLOTTO'
		end
		
		exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloFinale  , 'MOD_Bando'  ,  @idDoc , @Modulo 
		exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloFinale  , 'MOD_Bando_LOTTI'  ,  @idDoc , @Modulo 
		exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloFinale  , 'MOD_BandoSempl'  ,  @idDoc , @Modulo
		--BVEP-6172
		
		--sono sul contesto gare
		if ltrim(rtrim(@TipoBandoScelta)) <> ''
		begin
			--att. 560249 SE ATTIVO INTEROP SULLA GARA
			if  dbo.attivo_INTEROP_Gara (@IdGara)=1 
			begin

				set @ModelloBaseInterop = 'MODELLO_ATTRIBUTI_INTEROPERABILITA'
				
				--recupero tiposcheda
				select @pcp_TipoScheda= isnull(pcp_TipoScheda,'')  from document_pcp_appalto with (nolock) where idheader=@IdGara
				
				--se non presente setto la p1_16
				if @pcp_TipoScheda=''
				begin
					set @pcp_TipoScheda = 'P1_16'
				end

				--a seconda del tipo scheda cambio modello
				set @ModelloBaseInterop = @ModelloBaseInterop + '_' + @pcp_TipoScheda
				--select @NomeModelloFinale
				--se non esiste il modello per la scheda corrente considero sempre quello base
				if not exists (select top 1 id from LIB_Models with (nolock) where mod_id=@ModelloBaseInterop)
				begin
					set @ModelloBaseInterop = 'MODELLO_ATTRIBUTI_INTEROPERABILITA'
				end

				exec CONCATENA_MODELLO_INTEROPERABILITA @NomeModelloFinale  , 'MOD_Bando_LOTTI'  ,  @idDoc , @Modulo , @ModelloBaseInterop
				--select @Modulo
				--ATT. 573893 - PER IL BANDO SEMPLIFICATO 
				exec CONCATENA_MODELLO_INTEROPERABILITA @NomeModelloFinale  , 'MOD_BandoSempl'  ,  @idDoc , @Modulo , @ModelloBaseInterop

			end
		end

		exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloFinale  , 'MOD_ConfDett'  ,  @idDoc , @Modulo 
		exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloFinale  , 'MOD_ConfLista'  ,  @idDoc , @Modulo 
		exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloFinale  , 'MOD_Offerta'  ,  @idDoc , @Modulo 
		exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloFinale  , 'MOD_OffertaDrill'  ,  @idDoc , @Modulo 
		exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloFinale  , 'MOD_PDA'  ,  @idDoc , @Modulo 
		exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloFinale  , 'MOD_PDADrillLista'  ,  @idDoc , @Modulo 
		exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloFinale  , 'MOD_PDADrillTestata'  ,  @idDoc , @Modulo 

		 
		exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloFinale  , 'MOD_OffertaTec'  ,  @idDoc , @Modulo 
		exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloFinale  , 'MOD_OffertaInd'  ,  @idDoc , @Modulo 

		exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloFinale  , 'MOD_SCRITTURA_PRIVATA'  ,  @idDoc , @Modulo 
		exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloFinale  , 'MOD_PERFEZIONAMENTO_CONTRATTO'  ,  @idDoc , @Modulo
	
		exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloFinale  , 'MOD_OffertaINPUT'  ,  @idDoc , @Modulo

		

		-------ENRPAN-FRA-------------------------------------------------------------------------------------------------------
		--SE MODELLO BASE GENERO ANCHE LE TIPOLIGE MONOLOTTO E COMPLEX
		if @MakeAllModel = 1
		BEGIN

			-- TIPOLOGIA COMPLEX
			exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloC , 'MOD_Bando'  ,  @idDoc , @Modulo 
			exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloC , 'MOD_Bando_LOTTI'  ,  @idDoc , @Modulo 

			--BVEP-6172
			exec CONCATENA_MODELLO_INTEROPERABILITA @NomeModelloC  , 'MOD_Bando_LOTTI'  ,  @idDoc , @Modulo , 'MODELLO_ATTRIBUTI_INTEROPERABILITA'

			exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloC , 'MOD_ConfDett'  ,  @idDoc , @Modulo 
			exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloC , 'MOD_ConfLista'  ,  @idDoc , @Modulo 
			exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloC , 'MOD_Offerta'  ,  @idDoc , @Modulo 
			exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloC , 'MOD_OffertaDrill'  ,  @idDoc , @Modulo 
			exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloC , 'MOD_PDA'  ,  @idDoc , @Modulo 
			exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloC , 'MOD_PDADrillLista'  ,  @idDoc , @Modulo 
			exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloC , 'MOD_PDADrillTestata'  ,  @idDoc , @Modulo 

			exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloC  , 'MOD_BandoSempl'  ,  @idDoc , @Modulo 
			exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloC  , 'MOD_OffertaTec'  ,  @idDoc , @Modulo 
			exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloC  , 'MOD_OffertaInd'  ,  @idDoc , @Modulo 

			exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloC  , 'MOD_SCRITTURA_PRIVATA'  ,  @idDoc , @Modulo
			exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloC  , 'MOD_PERFEZIONAMENTO_CONTRATTO'  ,  @idDoc , @Modulo

			exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloC , 'MOD_OffertaINPUT'  ,  @idDoc , @Modulo

			--TIPOLOGIA MONOLOTTO
			exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloM , 'MOD_Bando'  ,  @idDoc , @Modulo 
			exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloM , 'MOD_Bando_LOTTI'  ,  @idDoc , @Modulo 
			
			--BVEP-6172
			exec CONCATENA_MODELLO_INTEROPERABILITA @NomeModelloM  , 'MOD_Bando_LOTTI'  ,  @idDoc , @Modulo , 'MODELLO_ATTRIBUTI_INTEROPERABILITA'

			exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloM , 'MOD_ConfDett'  ,  @idDoc , @Modulo 
			exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloM , 'MOD_ConfLista'  ,  @idDoc , @Modulo 
			exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloM , 'MOD_Offerta'  ,  @idDoc , @Modulo 
			exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloM , 'MOD_OffertaDrill'  ,  @idDoc , @Modulo 
			exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloM , 'MOD_PDA'  ,  @idDoc , @Modulo 
			exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloM , 'MOD_PDADrillLista'  ,  @idDoc , @Modulo 
			exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloM , 'MOD_PDADrillTestata'  ,  @idDoc , @Modulo 

			exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloM  , 'MOD_BandoSempl'  ,  @idDoc , @Modulo 
			exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloM  , 'MOD_OffertaTec'  ,  @idDoc , @Modulo 
			exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloM  , 'MOD_OffertaInd'  ,  @idDoc , @Modulo

			exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloM  , 'MOD_SCRITTURA_PRIVATA'  ,  @idDoc , @Modulo 
			exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloM  , 'MOD_PERFEZIONAMENTO_CONTRATTO'  ,  @idDoc , @Modulo 

			exec MAKE_FROM_DOC_MODEL_LOTTI  @NomeModelloM , 'MOD_OffertaINPUT'  ,  @idDoc , @Modulo


		END

		
		-- estraggo le colonne per la cauzione
		declare @MOD_Cauzione varchar(1000)
		set @MOD_Cauzione = 'NumeroLotto,CIG,'

		select @MOD_Cauzione = @MOD_Cauzione + a.Value + ','
			from CTL_DOC_Value a with(nolock)
				inner join CTL_DOC_Value v with(nolock) on a.IdHeader = v.IdHeader and 'MOD_Cauzione' = v.DZT_Name and v.Value <> '' and a.Row = v.Row and a.DZT_Name = 'DZT_Name' and a.DSE_ID='MODELLI'
			where a.IdHeader = @idDoc 
		

		
		-------------------------------------------------------------------------------------
		--ENRPAN fatto unico blocco con nomi appropriati inserisco il record nella tabella che traccia i modelli 
		-------------------------------------------------------------------------------------
		declare @idMod int
		set @idMod = null

		select @idMod = id from Document_Modelli_MicroLotti with(nolock) where @TitoloFinale = Codice and deleted = 0

		if @idMod is null
		begin

			insert into Document_Modelli_MicroLotti ( Codice , StatoDoc, Deleted, DataCreazione, Descrizione, ModelloBando, ModelloOfferta, ColonneCauzione, Allegato, ModelloPDA, ModelloPDA_DrillTestata, ModelloPDA_DrillLista, ModelloOfferta_Drill, ModelloConformitaTestata, ModelloConformitaDettagli,linkedDoc)
				 select  @TitoloFinale , 'Saved' as StatoDoc, 0 as Deleted, getdate() as DataCreazione, '' as Descrizione, '' as ModelloBando, '' as ModelloOfferta, '' as ColonneCauzione, '' as Allegato, '' as ModelloPDA, '' as ModelloPDA_DrillTestata, '' as ModelloPDA_DrillLista, '' as ModelloOfferta_Drill, '' as ModelloConformitaTestata, '' as ModelloConformitaDettagli,@idDoc

			set @idMod = SCOPE_IDENTITY()

		end


		update Document_Modelli_MicroLotti
			set 
				Descrizione = @Descrizione
				,ColonneCauzione = @MOD_Cauzione
				,Allegato = @Allegato
				,ModelloBando				= @NomeModelloFinale  + '_MOD_Bando'
				,ModelloOfferta				= @NomeModelloFinale  + '_MOD_Offerta' 
				,ModelloPDA					= @NomeModelloFinale  + '_MOD_PDA' 
				,ModelloPDA_DrillTestata	= @NomeModelloFinale  + '_MOD_PDADrillTestata'
				,ModelloPDA_DrillLista		= @NomeModelloFinale  + '_MOD_PDADrillLista'
				,ModelloOfferta_Drill		= @NomeModelloFinale  + '_MOD_OffertaDrill' 
				,ModelloConformitaTestata	= @NomeModelloFinale  + '_MOD_ConfLista'
				,ModelloConformitaDettagli	= @NomeModelloFinale  + '_MOD_ConfDett'
			where id = @idMod

		
		--SE MODELLO BASE GENERO ANCHE LE TIPOLIGE MONOLOTTO E COMPLEX
		if @MakeAllModel=1
		begin


			------------------------------------------------------------------------------------
			-- Inserisco il record nella tabella che traccia i modelli per i modelli complex  --
			------------------------------------------------------------------------------------
			set @idMod = null
			select @idMod = id from Document_Modelli_MicroLotti with(nolock) where @Titolo+'_COMPLEX' = Codice and deleted = 0

			if @idMod is null
			begin

				insert into Document_Modelli_MicroLotti ( Codice , StatoDoc, Deleted, DataCreazione, Descrizione, ModelloBando, ModelloOfferta, ColonneCauzione, Allegato, ModelloPDA, ModelloPDA_DrillTestata, ModelloPDA_DrillLista, ModelloOfferta_Drill, ModelloConformitaTestata, ModelloConformitaDettagli,complex ,linkedDoc)
					 select  @Titolo+'_COMPLEX' , 'Saved' as StatoDoc, 0 as Deleted, getdate() as DataCreazione, '' as Descrizione, '' as ModelloBando, '' as ModelloOfferta, '' as ColonneCauzione, '' as Allegato, '' as ModelloPDA, '' as ModelloPDA_DrillTestata, '' as ModelloPDA_DrillLista, '' as ModelloOfferta_Drill, '' as ModelloConformitaTestata, '' as ModelloConformitaDettagli,1,@idDoc

				set @idMod = SCOPE_IDENTITY()

			end


			update Document_Modelli_MicroLotti
				set 
					Descrizione = @Descrizione
					,ColonneCauzione = @MOD_Cauzione
					,Allegato = @Allegato
					,ModelloBando				= @NomeModelloC  + '_MOD_Bando'
					,ModelloOfferta				= @NomeModelloC  + '_MOD_Offerta' 
					,ModelloPDA					= @NomeModelloC  + '_MOD_PDA' 
					,ModelloPDA_DrillTestata	= @NomeModelloC  + '_MOD_PDADrillTestata'
					,ModelloPDA_DrillLista		= @NomeModelloC  + '_MOD_PDADrillLista'
					,ModelloOfferta_Drill		= @NomeModelloC  + '_MOD_OffertaDrill' 
					,ModelloConformitaTestata	= @NomeModelloC  + '_MOD_ConfLista'
					,ModelloConformitaDettagli	= @NomeModelloC  + '_MOD_ConfDett'
				where id = @idMod


			-------------------------------------------------------------------------------------
			--inserisco il record nella tabella che traccia i modelli per i modelli MONOLOTTO
			-------------------------------------------------------------------------------------
			set @idMod = null
			select @idMod = id from Document_Modelli_MicroLotti with(nolock) where @Titolo+'_MONOLOTTO' = Codice and deleted = 0

			if @idMod is null
			begin

				insert into Document_Modelli_MicroLotti ( Codice , StatoDoc, Deleted, DataCreazione, Descrizione, ModelloBando, ModelloOfferta, ColonneCauzione, Allegato, ModelloPDA, ModelloPDA_DrillTestata, ModelloPDA_DrillLista, ModelloOfferta_Drill, ModelloConformitaTestata, ModelloConformitaDettagli,complex,linkedDoc )
					 select  @Titolo+'_MONOLOTTO' , 'Saved' as StatoDoc, 0 as Deleted, getdate() as DataCreazione, '' as Descrizione, '' as ModelloBando, '' as ModelloOfferta, '' as ColonneCauzione, '' as Allegato, '' as ModelloPDA, '' as ModelloPDA_DrillTestata, '' as ModelloPDA_DrillLista, '' as ModelloOfferta_Drill, '' as ModelloConformitaTestata, '' as ModelloConformitaDettagli,0,@idDoc

				set @idMod = SCOPE_IDENTITY()

			end


			update Document_Modelli_MicroLotti
				set 
					Descrizione = @Descrizione
					,ColonneCauzione = @MOD_Cauzione
					,Allegato = @Allegato
					,ModelloBando				= @NomeModelloM  + '_MOD_Bando'
					,ModelloOfferta				= @NomeModelloM  + '_MOD_Offerta' 
					,ModelloPDA					= @NomeModelloM  + '_MOD_PDA' 
					,ModelloPDA_DrillTestata	= @NomeModelloM  + '_MOD_PDADrillTestata'
					,ModelloPDA_DrillLista		= @NomeModelloM  + '_MOD_PDADrillLista'
					,ModelloOfferta_Drill		= @NomeModelloM  + '_MOD_OffertaDrill' 
					,ModelloConformitaTestata	= @NomeModelloM  + '_MOD_ConfLista'
					,ModelloConformitaDettagli	= @NomeModelloM  + '_MOD_ConfDett'
					, complex = 0 
				where id = @idMod

		end

		
	END
	ELSE
	BEGIN

		if @contesto = 'AMPIEZZA_DI_GAMMA'
		begin
			----------------------------------------------------------------------------------------------------------------------------				
			-- genero il modello per l'inserimento dell'offerta dato dall'unione dei due modelli di offerta tecnica ed offerta economica
			----------------------------------------------------------------------------------------------------------------------------				
			delete from ctl_doc_value where IdHeader = @idDoc and  DSE_ID = 'MODELLI' and DZT_Name = 'MOD_OffertaINPUT' 

			insert into ctl_doc_value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				select s.idHeader , s.DSE_ID, s.Row , 'MOD_OffertaINPUT' , 

					case when isnull( e.Value  , '' ) = 'calc' or isnull( t.Value , '' ) = 'calc' then 'calc' 
						else
							case when isnull( e.Value , '' ) = 'obblig' or isnull ( t.Value , '' ) = 'obblig' then 'obblig' 
								else
									case when isnull ( e.Value , '' ) = 'scrittura' or isnull( t.Value , '' ) = 'scrittura' then 'scrittura' 
										else
											case when isnull( e.Value  , '' ) = 'lettura' or isnull( t.Value , '' ) = 'lettura' then 'lettura' 
												else ''
											end
									end
							end
					end as Value
					from ctl_doc_value s with(nolock)
						left outer join ctl_doc_value t with(nolock) on s.idheader = t.idheader  and t.dzt_name = 'MOD_OffertaTec' and s.row = t.row and t.DSE_ID = 'MODELLI'
						left outer join ctl_doc_value e with(nolock) on s.idheader = e.idheader  and e.dzt_name = 'MOD_Offerta'    and s.row = e.row and e.DSE_ID = 'MODELLI'
					where s.idheader = @idDoc and s.dzt_name = 'DZT_Name' and ( isnull( e.Value , '' ) <>  '' or isnull( t.Value , '' ) <> '' ) 
					order by s.row
			----------------------------------------------------------------------------------------------------------------------------				
		END
		
		
		declare @nome_modello_dinamico varchar(1000)
		declare @dztName varchar(500)


		set @nome_modello_dinamico = ''
		set @dztName = ''

		-- Generazione dei modelli dinamica in funzione del contesto e degli attributi usati (essendo anche il modello di scelta dinamico a sua volta)
		select top 1 @nome_modello_dinamico = MOD_Name from CTL_DOC_SECTION_MODEL with(nolock) where idheader = @idDoc and DSE_ID = 'MODELLI'

		DECLARE cur1 CURSOR STATIC FOR
				select ma_dzt_name from LIB_ModelAttributes with(nolock) where ma_mod_id = @nome_modello_dinamico and ma_dzt_name like 'MOD[_]%'
				
		OPEN cur1 
		FETCH NEXT FROM cur1 INTO @dztName

		WHILE @@FETCH_STATUS = 0
		BEGIN

			-- Iterando su tutti gli attributi del modelli dinamico che iniziano per 'MOD_' vado a crearmi gli N modelli
			-- uno per ogni attributi con MOD_

			exec CREA_MODELLI_FROM_CONFIG_MODELLI  @NomeModello , @dztName ,  @idDoc , @Modulo, @contesto 

			IF @@ERROR <> 0 
			BEGIN

				CLOSE cur1   
				DEALLOCATE cur1
				raiserror ('Errore generazione modello per %s. ', 16, 1, @dztName)
				return 
			END

			--se si tratta delle convenzioni e dell'attributo  MOD_PerfListinoOrdini
			--cancello la proprietà editable = 0 per rendere tutte le colonne del modello editabili
			if @contesto='CONVENZIONI' and @dztName='MOD_PerfListinoOrdini'
			begin
				
				--mi prendo gli attributi del modello in input e li metto in una temp
				select value 
					into #attrib_modello 
					from ctl_doc_value with(nolock)
						where idheader=@idDoc and dse_id='MODELLI' and dzt_name='DZT_Name'

				
				if exists (select top 1 * from #attrib_modello)
				begin
					--print '1 -- ' +convert( varchar(20) , getdate(), 121 )
					delete CTL_ModelAttributeProperties 
						where MAP_MA_MOD_ID= @NomeModello + '_' + @dztName and MAP_Propety='Editable' and map_value='0'
							and (
									MAP_MA_DZT_Name  in (select * from #attrib_modello)
									or
									--togliamo editabilità altrimenti
									--lato OE non possono essere imputate 
									--su rughe di iniziativa
									MAP_MA_DZT_Name  in ('NumeroLotto', 'Voce', 'CIG')

								)
							-- deve restare non editabile
							and MAP_MA_DZT_Name not in ('CODICE_REGIONALE') 
					--print '2 -- ' +convert( varchar(20) , getdate(), 121 )
				end

				-- dobbiamo rendere obbligatori gli attributi che sono obbligatori per l'ente in modo che le righe di iniziativa 
				-- ereditino questa caratteristica
				-- per precauzione li cancello prima di inserirli anche se il caso non dovrebbe presentarsi
			--	print '3 -- ' +convert( varchar(20) , getdate(), 121 )


			
						delete D
							from CTL_ModelAttributeProperties S WITH(NOLOCK) 
								INNER jOIN CTL_ModelAttributeProperties  d WITH(NOLOCK) on
										D.MAP_MA_MOD_ID= @NomeModello + '_MOD_PerfListinoOrdini' and d.MAP_MA_DZT_Name = S.MAP_MA_DZT_Name
										and D.MAP_Propety = 'Obbligatory' 
							where S.MAP_MA_MOD_ID= @NomeModello + '_MOD_ListinoOrdini' 
									and s.MAP_Propety = 'Obbligatory' and s.MAP_Value = '1'	
			
				--delete from CTL_ModelAttributeProperties
				--	where MAP_ID in ( 
				--		select D.MAP_ID 
				--			from CTL_ModelAttributeProperties S WITH(NOLOCK) 
				--				INNER jOIN CTL_ModelAttributeProperties  d WITH(NOLOCK) on
				--						D.MAP_MA_MOD_ID= @NomeModello + '_MOD_PerfListinoOrdini' and d.MAP_MA_DZT_Name = S.MAP_MA_DZT_Name
				--						and D.MAP_Propety = 'Obbligatory' 
				--			where S.MAP_MA_MOD_ID= @NomeModello + '_MOD_ListinoOrdini' 
				--					and s.MAP_Propety = 'Obbligatory' and s.MAP_Value = '1'				
				--			)
				--print '4 -- ' +convert( varchar(20) , getdate(), 121 )
				insert into [CTL_ModelAttributeProperties]
					( [MAP_MA_MOD_ID], [MAP_MA_DZT_Name], [MAP_Propety], [MAP_Value], [MAP_Module] ) 
					select @NomeModello + '_MOD_PerfListinoOrdini' as  [MAP_MA_MOD_ID], [MAP_MA_DZT_Name], [MAP_Propety], [MAP_Value], [MAP_Module]
						from CTL_ModelAttributeProperties 
						where  MAP_MA_MOD_ID= @NomeModello + '_MOD_ListinoOrdini' 
						and MAP_Propety = 'Obbligatory' and MAP_Value = '1'				

				--print '5 -- ' +convert( varchar(20) , getdate(), 121 )
			end


			FETCH NEXT FROM cur1 INTO @dztName

			if @contesto = 'AMPIEZZA_DI_GAMMA'
			begin
				-- genera il modello per la compilazione dell'ampiezza di gamma sull'offerta
				exec CREA_MODELLI_FROM_CONFIG_MODELLI  @NomeModello  , 'MOD_OffertaINPUT'  ,  @idDoc , @Modulo , @contesto
			END
		END

		CLOSE cur1
		DEALLOCATE cur1

		--genero modello per le convenzioni senza TipoAcquisto
		--if @contesto = 'CONVENZIONI'
		--begin
		--	set @dztName='MOD_Convenzione_SACQ'
		--	exec CREA_MODELLI_FROM_CONFIG_MODELLI  @NomeModello , @dztName ,  @idDoc , @Modulo, @contesto 
		--end

	END

END

GO
