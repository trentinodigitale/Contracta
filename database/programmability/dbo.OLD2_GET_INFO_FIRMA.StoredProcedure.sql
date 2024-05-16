USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_GET_INFO_FIRMA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO















CREATE PROC [dbo].[OLD2_GET_INFO_FIRMA] ( @x509Subject nvarchar(max),
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

	set @CODICE_FISCALE_FIRMATARIO=''
	set @SERIAL_NUMBER=''
	set @idpfu=0
	set @CF=''

	--IF EXISTS ( SELECT * from LIB_Dictionary where DZT_Name = 'SYS_ATTIVA_TRACE' and DZT_ValueDef = 'YES' )
	--BEGIN

	INSERT INTO CTL_TRACE
		( contesto, DATA, sessionIdASP, descrizione)
        VALUES 
		( 'START_GET_INFO_FIRMA', getdate(),@att_hash, @x509extra )

	--END

    
	if isnull(@att_hash,'')<>''
	BEGIN
		

		select 
				--distinct codfiscfirmatario 
			distinct 
				certificateSerialNumber, codfiscfirmatario
					into #temp_GET_INFO_FIRMA 
				from 
					CTL_SIGN_ATTACH_INFO with (nolock)
						left outer join ProfiliUtente P with (nolock) on pfuCodiceFiscale = codfiscfirmatario
				--where isnull(ATT_Hash,'') = @att_hash and P.idpfu is null
				where ATT_Hash = @att_hash and P.idpfu is null

		DECLARE crsSerialNumber CURSOR STATIC FOR 
		
			--recupero il SERAIL NUMBER (dalla colonna CODFISCFIRMATARIO) dalla CTL_SIGN_ATTACH_INFO
			--select codfiscfirmatario from CTL_SIGN_ATTACH_INFO with (nolock) where isnull(ATT_Hash,'') = @att_hash
			select certificateSerialNumber,codfiscfirmatario from #temp_GET_INFO_FIRMA

		OPEN crsSerialNumber

		FETCH NEXT FROM crsSerialNumber INTO @SERIAL_NUMBER,@CODICE_FISCALE_FIRMATARIO
		WHILE @@FETCH_STATUS = 0
		BEGIN
				
				set @idpfu=0

				--AGGIORNO CODFISCFIRMATARIO CON PFUCODICEFISCALE DELLA PROFILIUTENTE SE ESISTE IL SERIAL NUMBER NELLA TABELLA ProfiliUtenteAttrib
				--per gestire casi in cui quello che ci arriva non contiene il codice fiscale (PASCH-......)
				--select @idpfu=idpfu from ProfiliUtenteAttrib with (nolock) where dztNome='SIGN_SERIAL_NUMBER' and attValue = @SERIAL_NUMBER
				
				select @idpfu=idpfu , @CF=CodiceFiscale from ProfiliUtente_Sign_SerialNumber with (nolock) where SerialNumber = @SERIAL_NUMBER

				--if isnull(@idpfu,0) >0 
				if isnull(@CF,'') <> '' 
				BEGIN
			
					--aggiorno codice fiscale sulla riga del certificato
					--update 
					--	CTL_SIGN_ATTACH_INFO
					--	set 
					--		CTL_SIGN_ATTACH_INFO.codfiscfirmatario = profiliutente.pfucodicefiscale
					--	from 
					--		CTL_SIGN_ATTACH_INFO with (nolock)
					--			INNER JOIN  profiliutente with (nolock) ON	 ProfiliUtente.idpfu=@idpfu
					--		where isnull(ATT_Hash,'') = @att_hash --and CTL_SIGN_ATTACH_INFO.codfiscfirmatario=@SERIAL_NUMBER
					--					and CTL_SIGN_ATTACH_INFO.certificateSerialNumber=@SERIAL_NUMBER

					update 
						CTL_SIGN_ATTACH_INFO
							set CTL_SIGN_ATTACH_INFO.codfiscfirmatario = @CF
						where ATT_Hash = @att_hash 
							and CTL_SIGN_ATTACH_INFO.certificateSerialNumber=@SERIAL_NUMBER
					
					INSERT INTO CTL_TRACE
						( contesto, DATA, sessionIdASP, descrizione)
						VALUES 
						( 'GET_INFO_FIRMA-AGGIORNATO CODFISCFIRMATARIO CON PFUCODICEFISCALE DELLA TABELLA ProfiliUtenteAttrib agganciata per certificateSerialNumber della firma', getdate(),@att_hash, @x509extra )

				END
				ELSE
				BEGIN
						
					----AGGIORNO CODFISCFIRMATARIO CON PFUCODICEFISCALE DELLA PROFILIUTENTE SE CODFISCFIRMATARIO LO CONTIENE
					--UPDATE CTL_SIGN_ATTACH_INFO
					--		SET CTL_SIGN_ATTACH_INFO.codfiscfirmatario = profiliutente.pfucodicefiscale
					--	FROM 
					--		CTL_SIGN_ATTACH_INFO with (nolock)
					--			CROSS JOIN  profiliutente with (nolock) --ON	 CTL_SIGN_ATTACH_INFO.idazi = profiliutente.pfuidazi
					--			INNER JOIN aziende azi with(nolock) ON azi.idazi = pfuIdAzi and ( aziStatoLeg2 = 'M-1-11-ITA' or CTL_SIGN_ATTACH_INFO.codfiscfirmatario like 'TINIT-%' )
					--	where charindex(pfucodicefiscale,codfiscfirmatario) > 0 and pfuCodiceFiscale <> codfiscfirmatario
					--			--and  isnull(ATT_Hash,'') = @att_hash
					--			and  ATT_Hash = @att_hash
						
					--normalizzo il codice fiscale togliendo le cose aggiuntive dove non ho l'azienda
					--'TINIT-'
					UPDATE 
						CTL_SIGN_ATTACH_INFO
						set
							CTL_SIGN_ATTACH_INFO.codfiscfirmatario = replace(CTL_SIGN_ATTACH_INFO.codfiscfirmatario,'TINIT-','') 
						where ATT_Hash = @att_hash and left(codfiscfirmatario,6) = 'TINIT-' 
						
					INSERT INTO CTL_TRACE
					( contesto, DATA, sessionIdASP, descrizione)
					VALUES 
					( 'GET_INFO_FIRMA-TOLTO "TINIT-" DA CODFISCFIRMATARIO', getdate(),@att_hash, @x509extra )
					

				END

			
				FETCH NEXT FROM crsSerialNumber INTO @SERIAL_NUMBER,@CODICE_FISCALE_FIRMATARIO

			END

	END	
	
	CLOSE crsSerialNumber 
	DEALLOCATE crsSerialNumber 

	drop table #temp_GET_INFO_FIRMA

	INSERT INTO CTL_TRACE
		( contesto, DATA, sessionIdASP, descrizione)
        VALUES 
		( 'END_GET_INFO_FIRMA', getdate(),@att_hash, @x509extra )


END


    



GO
