USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_CK_VerificaVincoli]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[OLD2_CK_VerificaVincoli] (
 @IdPfu int, @IdProduct int , @IdConvenzione int , @Ret as nvarchar(4000) OUTPUT )
AS
BEGIN 

	SET NOCOUNT ON
	declare @QT as float
	declare @Prezzo as float
	declare @ValoreAccessorio as float
	declare @Espressione as nvarchar(2000)
	declare @CodiceModelloConvenzione as varchar(200)
	declare @IdModello as int
	declare @DztNameQT as varchar(200)
	declare @DztNamePRZ as varchar(200)
	declare @DztNameVALACC as varchar(200)
	declare @statement as nvarchar(4000)	
	declare @Descrizione as nvarchar(1000)
	declare @Descrizione_Risolta as nvarchar(1000)

	set @Ret=''
	
	--recupero attributi base dal carrello
	select 	@QT=QTDisp,@Prezzo=prezzoUnitario,@ValoreAccessorio=ValoreAccessorioTecnico from carrello where idpfu=@IdPfu and id_product=@IdProduct and Id_Convenzione=@IdConvenzione

	--recupero gli attributi che contengono i valori base 
	set @CodiceModelloConvenzione=''	
	select @CodiceModelloConvenzione=value 
		from ctl_doc_value 
		where 
			idheader=@IdConvenzione and dse_id='TESTATA_PRODOTTI' and dzt_name='Tipo_Modello_Convenzione'

	--recupero doc di tipo MODELLO con titolo questocodice
	set @IdModello=-1
	select @IdModello=id from ctl_doc where 
	 tipodoc='CONFIG_MODELLI' and deleted=0 --and statofunzionale='Pubblicato'
	 and titolo=@CodiceModelloConvenzione

	
	--recupero nome attributo quantità
	set @DztNameQT=''
	select @DztNameQT=value from ctl_doc_value 
	where dse_id='EXTRA' and idheader=@IdModello and dzt_name='DZT_NAME_QTY'
	--return @DztNameQT
	--recupero nome attributo quantità
	set @DztNamePRZ=''
	select @DztNamePRZ=value from ctl_doc_value 
	where dse_id='EXTRA' and idheader=@IdModello and dzt_name='DZT_NAME_PRZ'

	--recupero nome attributo quantità
	set @DztNameVALACC=''
	select @DztNameVALACC=value from ctl_doc_value 
	where dse_id='EXTRA' and idheader=@IdModello and dzt_name='DZT_NAME_VALACC'	
	
	--print @DztNameQT

	declare @TempTable table(Id int)
		

	--recupero i vincoli inclusi sulla convenzione
	DECLARE crsVincoli CURSOR STATIC FOR 
	select Espressione,Descrizione from Document_Vincoli where idheader=@IdConvenzione and seleziona='includi'

	OPEN crsVincoli

	FETCH NEXT FROM crsVincoli INTO @Espressione,@Descrizione
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--se nell'espressione è presente la parola isMultiplo ci metto dbo d'avanti
		set @Espressione = REPLACE(@Espressione, 'isMultiplo(', 'dbo.isMultiplo(')

		--rimpiazzo	i valori degli attributi base nell'espressione
		set @Espressione = ' ' + @Espressione + ' ' 
		set @Espressione = replace(@Espressione,' ' + @DztNameQT + ' ' , cast(@QT as varchar(50)) )				
		set @Espressione = replace(@Espressione,' ' + @DztNamePRZ + ' ' , cast(@Prezzo as varchar(50)) )				
		set @Espressione = replace(@Espressione,' ' + @DztNameVALACC + ' ' , cast(@ValoreAccessorio as varchar(50)) )				

		--rimpiazzare nella espressione tutte le colonne della tabella document_microlotti_dettagli
		--di quella riga
		
		set @statement = 'select id from document_microlotti_dettagli where id=' + cast(@IdProduct as varchar(50)) + ' and ' +	@Espressione
		--print @statement

		delete from @TempTable
		insert into @TempTable (Id) 
		exec (@statement)

		if not exists(select * from @TempTable)		
		begin
			
			--sostituisco nella descrizione pattern del tipo #DOCUMENT.QT/# i valori della riga in corso
			set @Descrizione_Risolta=''
			exec Set_Descrizione_Vincolo @IdProduct, @Descrizione, @Descrizione_Risolta output

			--set @Ret = @Ret + char(13) + char(10) + dbo.CNV('Vincolo non superato' , 'I')  +  ' "' +  @Descrizione_Risolta + ';'
			set @Ret = @Ret + char(13) + char(10)  +  @Descrizione_Risolta + ';'
			--CLOSE crsVincoli 
			--DEALLOCATE crsVincoli 		
			--return
		end
		
		FETCH NEXT FROM crsVincoli INTO @Espressione,@Descrizione
	END

	CLOSE crsVincoli 
	DEALLOCATE crsVincoli 	

	
	
END

GO
