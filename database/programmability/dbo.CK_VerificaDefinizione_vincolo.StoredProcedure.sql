USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_VerificaDefinizione_vincolo]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  PROCEDURE [dbo].[CK_VerificaDefinizione_vincolo] (
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
	declare @DztNameAttrib as varchar(100)
	declare @Type int
	declare @Jumpcheck as varchar(100)

	set @Ret=''
	

	select @Jumpcheck = ISNULL(jumpcheck,'') from ctl_doc where Id= @IdModello

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

	--recupero i vincoli inclusi sul modello
	DECLARE crsVincoli CURSOR STATIC FOR 
	select Espressione,idrow from Document_Vincoli where idheader=@IdModello 

	OPEN crsVincoli

	FETCH NEXT FROM crsVincoli INTO @Espressione,@idrow
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		--rimpiazzo	i valori degli attributi base nell'espressione
		set @Espressione = ' ' + @Espressione + ' ' 

		if @Jumpcheck <> 'AMPIEZZA_DI_GAMMA'
		begin
			set @Espressione = replace(@Espressione,' ' + @DztNameQT + ' ' , ' 1 ' )				
			set @Espressione = replace(@Espressione,' ' + @DztNamePRZ + ' ' , ' 1 ' )				
			set @Espressione = replace(@Espressione,' ' + @DztNameVALACC + ' ' , ' 1 ' )				
		end

		--se nell'espressione è presente la parola isMultiplo ci metto dbo d'avanti
		set @Espressione = REPLACE(@Espressione, 'isMultiplo(', 'dbo.isMultiplo(')
		--se nell'espressione è presente la parola isEmpty ci metto dbo d'avanti
		set @Espressione = REPLACE(@Espressione, ' isEmpty(', ' dbo.isEmpty(')

		--rimpiazzo gli operatori e le parentesi per assicurarci gli spazi davanti gli attributi
		set @Espressione = replace(@Espressione,'(', ' ( ')
		set @Espressione = replace(@Espressione,')', ' ) ')
		set @Espressione = replace(@Espressione,'+', ' + ')
		set @Espressione = replace(@Espressione,'-', ' - ')
		set @Espressione = replace(@Espressione,'*', ' * ')
		set @Espressione = replace(@Espressione,'/', ' / ')

		--recupero tutti gli attributi del modello
		--select value  from ctl_doc_value where idheader=61599 and dzt_name='DZT_Name' 
		DECLARE crsAttrib CURSOR STATIC FOR 
			
			--select value from ctl_doc_value where idheader=@IdModello and dzt_name='DZT_Name' 
			select value , d.DZT_Type
				from ctl_doc_value v with(nolock)
					left join LIB_Dictionary d with(nolock) on d.DZT_Name = v.value
				where idheader=@IdModello and v.DZT_Name='DZT_Name' 

		OPEN crsAttrib

		FETCH NEXT FROM crsAttrib INTO @DztNameAttrib, @Type
		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			--set @Espressione = replace(@Espressione,' ' + @DztNameAttrib + ' ' , ' 1 ' )							
			if @Type = 2
				set @Espressione = replace(@Espressione,' ' + @DztNameAttrib + ' ' , ' 1 ' )							
			else
				set @Espressione = replace(@Espressione,' ' + @DztNameAttrib + ' ' , ' ''1'' ' )	

			FETCH NEXT FROM crsAttrib INTO @DztNameAttrib, @Type
		END
		
		CLOSE crsAttrib 
		DEALLOCATE crsAttrib 

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
		FETCH NEXT FROM crsVincoli INTO @Espressione,@idrow
	END

	CLOSE crsVincoli 
	DEALLOCATE crsVincoli 	
END
GO
