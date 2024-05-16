USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_MERC_ADDITIONAL_INFO_CREATE_FROM_CLSSE_ISCRIZ]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  PROCEDURE [dbo].[OLD_MERC_ADDITIONAL_INFO_CREATE_FROM_CLSSE_ISCRIZ] ( @idvat int , @IdUser int  )
AS
BEGIN

	SET NOCOUNT ON;
	declare @Id as INT
	declare @Idazi as INT
	declare @classe as nvarchar(MAX) 
	declare @out as int
	declare @ELENCO_PATH_CLASSI_MODELLO nvarchar(MAX) 
	set @ELENCO_PATH_CLASSI_MODELLO=''
	declare @ELENCO_CLASSI_MODELLO nvarchar(MAX) 
	set @ELENCO_CLASSI_MODELLO = ''


	declare @Errore as nvarchar(2000)
	set @Errore=''
	set @Id =0
	
	select @Idazi=lnk,@classe='###' + vatvalore_ft + '###' from DM_Attributi where idVat=@idvat
	
	--INVOCO QUESTA STORED CHE MI DA IL PATH DELLE CLASSI CHE HANNO ASSOCIATO UN MODELLO
		
	declare @t table (name nvarchar(MAX))
	insert @t (name)
	exec SP_CAN_INSERT_INFO_ADD_ISTANZA -1 , @classe , @out output

	--NELLA VARIABILE HO ELENCO DEI PATH DELLE CLASSI CHE RICHIEDONO INFO AGGIUNTIVE SUL QUALE VIENE FATTO UN SORT E UNA DISTINCT
	select @ELENCO_PATH_CLASSI_MODELLO=name from  @t
	
	set @ELENCO_CLASSI_MODELLO ='###'
	
	select   @ELENCO_CLASSI_MODELLO = @ELENCO_CLASSI_MODELLO + C.DMV_Cod  + '###' 
		from dbo.split(@ELENCO_PATH_CLASSI_MODELLO,'###')
			inner join ClasseIscriz C on C.DMV_Father=items
			order by items

	IF ISNULL(@ELENCO_CLASSI_MODELLO,'')='' or @ELENCO_CLASSI_MODELLO = '###'
	BEGIN
		set @Errore='Per la Merceologia selezionata non esistono informazioni aggiuntive'
	END
	ELSE
	BEGIN

		select @Id = id
			from ctl_doc		
				inner join CTL_DOC_Value on Id=IdHeader and DSE_ID='CLASSE'	 and DZT_Name='ClasseIscriz' and Value like '%' + @ELENCO_CLASSI_MODELLO + '%'
			where TipoDoc='MERC_ADDITIONAL_INFO' and Azienda=@Idazi and StatoFunzionale = 'InLavorazione' --non devo prendere quelli 'Annullati'

		--RICHIESTE LE INFORMAZIONI AGGIUNTIVE MA NON PRESENTE IL DOCUMENTO
		IF @id = 0
			set @Errore='Per la Merceologia selezionata non esistono informazioni aggiuntive'

	END
	if @Errore = '' --and @Id > 0
	begin
		-- rirorna l'id del doc appena creato
		select @Id as id
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
	
END






GO
