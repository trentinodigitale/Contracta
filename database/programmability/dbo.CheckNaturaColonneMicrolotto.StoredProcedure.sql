USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CheckNaturaColonneMicrolotto]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[CheckNaturaColonneMicrolotto]
	@iddoc as int, 
	@idpfu as int
AS
BEGIN

	SET NOCOUNT ON;
	
	--declare @iddoc as int
	--declare @idpfu as int

	--set @iddoc	= 100820
	--set @idpfu  = 42690

	declare @modello as varchar(250)
	declare @modellobando as varchar(250)
	declare @ColonneImportate as varchar(500)
	
	--recupero modello selezionato
	select @modello=listamodellimicrolotti from tab_messaggi_fields where idmsg=@iddoc

	--recupero modello bando associato
	select @modellobando=modellobando from Document_Modelli_MicroLotti where codice=@modello

	
	--costruisco condizione per gli attributi obbligatori del modello
	declare @ConditionObblig as varchar(8000)
	set @ConditionObblig=''
	select 
			--@ConditionObblig = @ConditionObblig + ' or isnull(' + MAP_MA_DZT_Name + ','''')='''''
			@ConditionObblig = @ConditionObblig + ' + case isnull(' + MAP_MA_DZT_Name + ','''') when '''' then ''<br>Attributo '' + dbo.CNV_ESTESA (' + MA_DescML + ',''I'') + '' obbligatorio.'' else '''' end'
	from 
			LIB_ModelAttributeProperties,LIB_ModelAttributes
	where
		
		MAP_MA_MOD_ID=@modellobando
		--MAP_MA_MOD_ID='Microlotto_ModelloBase_Bando' 
		and MAP_MA_MOD_ID=MA_MOD_ID
		and MAP_MA_DZT_Name=MA_DZT_Name
		and MAP_Propety='Obbligatory'
		and isnull(MAP_value,'0')='1'
	
	set @ConditionObblig = SUBSTRING ( @ConditionObblig , 4 , len(@ConditionObblig) ) 
	
	--print @ConditionObblig
	
	--aggiorno esito riga se ci sono attributi obbligatori non valrizzati
	if @ConditionObblig<>''
	begin

		declare @UpdateEsitoForObblig as varchar(8000)
		set @UpdateEsitoForObblig =' 
			update 
					Document_MicroLotti_Dettagli 
			set 
				EsitoRiga = isnull(EsitoRiga,'') + ' + @ConditionObblig
				
	end	
	
	--print @UpdateEsitoForObblig
	exec(@UpdateEsitoForObblig)	
	

--	--costruisco condizione per gli attributi numerici del modello
--	declare @ConditionNumeric as varchar(8000)
--	set @ConditionNumeric=''
--	select 
--			@ConditionNumeric = @ConditionNumeric + ' or isnumeric(isnull(' + Ma_DZT_Name + ',0))=0'
--	from 
--			LIB_ModelAttributes ,LIB_Dictionary
--	where
--		--MA_MOD_ID=@modellobando and Ma_DZT_Name<>'EsitoRiga' 
--		MA_MOD_ID='Microlotto_ModelloBase_Bando' and Ma_DZT_Name<>'EsitoRiga' 
--		and Ma_DZT_Name=DZT_Name
--		and DZT_Type in (2,7)
--
--	
--	set @ConditionNumeric = '( ' + SUBSTRING ( @ConditionNumeric , 4 , len(@ConditionNumeric) ) + ' )'
--	
--	print 	@ConditionNumeric
--
--
--	if @ConditionNumeric<>''
--	begin
--
--		declare @UpdateEsitoForNumeric as varchar(8000)
--		set @UpdateEsitoForNumeric =' 
--			update 
--					Document_MicroLotti_Dettagli 
--			set 
--				EsitoRiga = EsitoRiga + ''<br>Gli attributi obbligatori non sono tutti valorizzati;'' 
--			where Id in
--				(select 
--					id 
--				 from 
--					Document_MicroLotti_Dettagli 
--				 where ' + @ConditionNumeric + '  and IdHeader=' + cast(100820 as varchar) + ')'
--			
--	end		
--	print @UpdateEsitoForNumeric
--	--exec(@UpdateEsitoForNumeric)	



END
GO
