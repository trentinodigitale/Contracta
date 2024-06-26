USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_SP_GET_MODELLI]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE     proc [dbo].[OLD2_SP_GET_MODELLI] --(@classi nvarchar(MAX) ,  @out as INT = NULL output , @asp INT = 0)
 ( @idUser int , @classi  varchar(max)='')AS
BEGIN
	set nocount on
	declare   @out as INT
	set @out=0
	insert into ctl_trace ( contesto , descrizione ) values ( '[SP_GET_MODELLI]' , @classi )

	declare @ELENCO_PATH_CLASSI_MODELLO nvarchar(MAX) 
	declare @ELENCO_CLASSI_MODELLO as nvarchar(MAX)
	declare @ELENCO_MODELLI as nvarchar(MAX)
	
	declare @Errore as nvarchar(2000)
	set @Errore=''

	--INVOCO QUESTA STORED CHE MI DA IL PATH DELLE CLASSI CHE HANNO ASSOCIATO UN MODELLO
	declare @t table (name nvarchar(MAX))
	insert @t (name)
	exec SP_CAN_INSERT_INFO_ADD_ISTANZA -1 , @classi , @out output
	
	--NELLA VARIABILE HO ELENCO DEI PATH DELLE CLASSI CHE RICHIEDONO INFO AGGIUNTIVE SUL QUALE VIENE FATTO UN SORT E UNA DISTINCT
	select @ELENCO_PATH_CLASSI_MODELLO=name from  @t
	
	set @ELENCO_CLASSI_MODELLO ='###'
	select @ELENCO_CLASSI_MODELLO = @ELENCO_CLASSI_MODELLO + C.DMV_Cod + '###' 
		from dbo.split(@ELENCO_PATH_CLASSI_MODELLO,'###')
			inner join ClasseIscriz C on C.DMV_Father = items
			order by items
  IF ISNULL(@ELENCO_CLASSI_MODELLO,'') = '' or @ELENCO_CLASSI_MODELLO = '###'
  	BEGIN
 	  	set @Errore='Per la Merceologia selezionata non esistono informazioni aggiuntive'
	  END
	ELSE
  	BEGIN

			set @ELENCO_MODELLI ='###'			 
			select @ELENCO_MODELLI = @ELENCO_MODELLI + C.TITOLO + '###'
					from ctl_doc c
						inner join CTL_DOC_Value CV on CV.idHeader = id and CV.DSE_ID = 'CLASSE' and CV.DZT_Name = 'ClasseIscriz'
					where TipoDoc = 'CONFIG_MODELLI_MERC_ADDITIONAL_INFO' 
					and Deleted = 0 and StatoFunzionale in ('Pubblicato')	
					and [dbo].[Intersezione_Insiemi]( CV.value , @ELENCO_CLASSI_MODELLO , '###' ) > ''
			
			 IF ISNULL(@ELENCO_CLASSI_MODELLO,'') = '' or @ELENCO_CLASSI_MODELLO = '###' 
			 	BEGIN
			 		set @Errore='Nessun Modello trovato'
			 	END
		END	
	
	IF @Errore = ''
	begin
		-- rirorna elenco modelli
		select @ELENCO_MODELLI as elenco_modelli
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
		--select '###Ciao###' as elenco_modelli
	end				
	
END
GO
