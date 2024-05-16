USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GET_INFO_FIRMA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[GET_INFO_FIRMA] ( @x509Subject nvarchar(max),
								    @x509Issuer nvarchar(max),
									@x509SignatureAlgorithm nvarchar(max), 
									@x509extra nvarchar(max), 
									@att_hash nvarchar(max),
									@attIdMsg int = 0,
									@attOrderFile int = 0,
									@attIdObj int = 0) 
AS
BEGIN

	-- QUESTA STORED VIENE INVOCATA SUBITO DOPO LA SCRITTURA NELLA TABELLA CTL_SIGN_ATTACH_INFO
	---E' STATA PENSATA PER EFFETTUARE EVENTUALI CONTROLLI O MODIFICHE AGGIUNTIVE DELEGANDOLE ALLA STORED
    --- COSI DA NON DOVER PER FORZA RICOMPILARE LA DLL HTML2PDF NEL CASO SI RIESCA
	--- A GESTIRE L'ECCEZIONE ALL'INTERNO DELLA STORED ( COME AD ESEMPIO IL CODICE FISCALE DEL FIRMATARIO MEMORIZZATO IN UN AREA DIFFERENTE )

	declare @idpfu as int
	declare @SERIAL_NUMBER as varchar(500)
	declare @CODICE_FISCALE_FIRMATARIO as varchar(500)
	declare @CF as varchar(500)
	declare @attivaTRACE varchar(1000)

	set @CODICE_FISCALE_FIRMATARIO=''
	set @SERIAL_NUMBER=''
	set @idpfu=0
	set @CF=''

	SELECT @attivaTRACE = DZT_Name from LIB_Dictionary with(nolock) where DZT_Name = 'SYS_ATTIVA_TRACE'

	IF @attivaTRACE = 'YES'
	BEGIN

		INSERT INTO CTL_TRACE
			( contesto, DATA, sessionIdASP, descrizione)
			VALUES ( 'START_GET_INFO_FIRMA', getdate(),@att_hash, @x509extra )

	END
    
	if isnull(@att_hash,'')<>''
	BEGIN
		

		select distinct certificateSerialNumber, codfiscfirmatario INTO #temp_GET_INFO_FIRMA 
				from CTL_SIGN_ATTACH_INFO with (nolock)
						left outer join ProfiliUtente P with (nolock) on pfuCodiceFiscale = codfiscfirmatario
				where ATT_Hash = @att_hash and ( P.idpfu is null or pfuCodiceFiscale ='')

		DECLARE crsSerialNumber2 CURSOR FAST_FORWARD FOR 
			--recupero il SERAIL NUMBER (dalla colonna CODFISCFIRMATARIO) dalla CTL_SIGN_ATTACH_INFO
			--select codfiscfirmatario from CTL_SIGN_ATTACH_INFO with (nolock) where isnull(ATT_Hash,'') = @att_hash
			select certificateSerialNumber,codfiscfirmatario from #temp_GET_INFO_FIRMA

		OPEN crsSerialNumber2

		FETCH NEXT FROM crsSerialNumber2 INTO @SERIAL_NUMBER,@CODICE_FISCALE_FIRMATARIO
		WHILE @@FETCH_STATUS = 0
		BEGIN
				
				set @idpfu=0

				--AGGIORNO CODFISCFIRMATARIO CON PFUCODICEFISCALE DELLA PROFILIUTENTE SE ESISTE IL SERIAL NUMBER NELLA TABELLA ProfiliUtenteAttrib
				--per gestire casi in cui quello che ci arriva non contiene il codice fiscale (PASCH-......)
				--select @idpfu=idpfu from ProfiliUtenteAttrib with (nolock) where dztNome='SIGN_SERIAL_NUMBER' and attValue = @SERIAL_NUMBER
				
				select @idpfu=idpfu , @CF=CodiceFiscale from ProfiliUtente_Sign_SerialNumber with (nolock) where SerialNumber = @SERIAL_NUMBER and isnull( deleted , 0 )  = 0

				if isnull(@CF,'') <> '' 
				BEGIN

					update 
						CTL_SIGN_ATTACH_INFO
							set CTL_SIGN_ATTACH_INFO.codfiscfirmatario = @CF
						where ATT_Hash = @att_hash 
							and CTL_SIGN_ATTACH_INFO.certificateSerialNumber=@SERIAL_NUMBER
					
					IF @attivaTRACE = 'YES'
					BEGIN

						INSERT INTO CTL_TRACE ( contesto, DATA, sessionIdASP, descrizione)
							VALUES ( 'GET_INFO_FIRMA-AGGIORNATO CODFISCFIRMATARIO CON PFUCODICEFISCALE DELLA TABELLA ProfiliUtenteAttrib agganciata per certificateSerialNumber della firma', getdate(),@att_hash, @x509extra )

					END

				END
				ELSE
				BEGIN
						
				
					UPDATE 
						CTL_SIGN_ATTACH_INFO
						set
							CTL_SIGN_ATTACH_INFO.codfiscfirmatario = replace(CTL_SIGN_ATTACH_INFO.codfiscfirmatario,'TINIT-','') 
						where ATT_Hash = @att_hash and left(codfiscfirmatario,6) = 'TINIT-' 
						
					IF @attivaTRACE = 'YES'
					BEGIN

						INSERT INTO CTL_TRACE ( contesto, DATA, sessionIdASP, descrizione)
							VALUES ( 'GET_INFO_FIRMA-TOLTO "TINIT-" DA CODFISCFIRMATARIO', getdate(),@att_hash, @x509extra )

					END
					

				END

			
				FETCH NEXT FROM crsSerialNumber2 INTO @SERIAL_NUMBER,@CODICE_FISCALE_FIRMATARIO

			END

			CLOSE crsSerialNumber2 
			DEALLOCATE crsSerialNumber2 

			drop table #temp_GET_INFO_FIRMA

	END	
	
	

	IF @attivaTRACE = 'YES'
	BEGIN
		INSERT INTO CTL_TRACE
			( contesto, DATA, sessionIdASP, descrizione)
			VALUES ( 'END_GET_INFO_FIRMA', getdate(),@att_hash, @x509extra )
	END


END


    



GO
