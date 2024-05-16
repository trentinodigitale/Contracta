USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CK_VerificaDefinizione_vincolo_lotti]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[OLD_CK_VerificaDefinizione_vincolo_lotti] (
  @IdModello int , @Ret as varchar(100) OUTPUT )
AS
BEGIN 

	SET NOCOUNT ON

	declare @QT as float
	declare @Prezzo as float
	declare @ValoreAccessorio as float
	declare @Espressione as nvarchar(2000)
	declare @CodiceModelloConvenzione as varchar(200)
	declare @DztNameQT as varchar(200)
	declare @DztNamePRZ as varchar(200)
	declare @DztNameVALACC as varchar(200)
	declare @statement as nvarchar(4000)	
	declare @idrow as int
	declare @result int
	declare @Type int
	declare @DztNameAttrib as varchar(500)

	set @Ret=''
	

	--recupero i vincoli inclusi sul modello
	DECLARE crsVincoli CURSOR STATIC FOR 
	select Espressione,idrow from Document_Vincoli where idheader=@IdModello 

	OPEN crsVincoli

	FETCH NEXT FROM crsVincoli INTO @Espressione,@idrow
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		
		--recupero tutti gli attributi del modello
		--select value  from ctl_doc_value where idheader=61599 and dzt_name='DZT_Name' 
		DECLARE crsAttrib CURSOR STATIC FOR 
			select value , d.DZT_Type
				from ctl_doc_value v with(nolock)
					left join LIB_Dictionary d with(nolock) on d.DZT_Name = v.value
				where idheader=@IdModello and v.DZT_Name='Descrizione' 

		OPEN crsAttrib

		FETCH NEXT FROM crsAttrib INTO @DztNameAttrib , @Type
		WHILE @@FETCH_STATUS = 0
		BEGIN
			if @Type = 2
				set @Espressione = replace(@Espressione,'[' + @DztNameAttrib + ']' , ' 1 ' )							
			else
				set @Espressione = replace(@Espressione,'[' + @DztNameAttrib + ']' , ' ''1'' ' )							


			FETCH NEXT FROM crsAttrib INTO @DztNameAttrib , @Type
		END
		
		CLOSE crsAttrib 
		DEALLOCATE crsAttrib 

		if ((CHARINDEX('drop', @Espressione) > 0) or (CHARINDEX('insert', @Espressione) > 0) or (CHARINDEX('update', @Espressione) > 0))
			begin 
				update Document_Vincoli set EsitoRiga = dbo.CNV('Espressione non corretta.' , 'I') where idrow=@idrow
				set @Ret = 'Espressione non corretta.'
			end
		else
			begin 
				set @statement = 'declare @a varchar(10); select top 1 @a=''ok'' where ' + @Espressione
				--print @statement + char(13) + char(10)
				--set @result = 0
				--exec @result = sp_executesql @statement
				update Document_Vincoli set EsitoRiga = dbo.CNV('Espressione corretta.' , 'I') where idrow=@idrow

				BEGIN TRY
					exec (@statement)
				END TRY
				BEGIN CATCH
					--print @idrow
					update Document_Vincoli set EsitoRiga = dbo.CNV('Espressione non corretta.' , 'I') where idrow=@idrow
					set @Ret = 'Espressione non corretta.'
				END CATCH;

				--if @result <> 0 
				--begin
				--	update Document_Vincoli set EsitoRiga = dbo.CNV('Espressione non corretta.' , 'I') where idrow=@idrow
				--	set @Ret = 'Espressione non corretta.'
				--end
				--print @Espressione
			end
		FETCH NEXT FROM crsVincoli INTO @Espressione,@idrow
	END

	CLOSE crsVincoli 
	DEALLOCATE crsVincoli 	
END
GO
