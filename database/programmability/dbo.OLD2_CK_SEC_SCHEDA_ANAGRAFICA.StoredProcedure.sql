USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_CK_SEC_SCHEDA_ANAGRAFICA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[OLD2_CK_SEC_SCHEDA_ANAGRAFICA] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
as
begin

	SET NOCOUNT ON

	-- verifico se la sezione puo essere aperta.

	declare @aziProfili varchar(50)
	declare @aziProfiliUser varchar(50)
	declare @aziAcquirente int 

	select @aziProfili  = aziProfili  , @aziAcquirente = aziAcquirente 
		from aziende with(nolock)  where idazi = @IdDoc
	
	set @aziProfiliUser=''

	select @aziProfiliUser=aziProfili
		from aziende with(nolock)
				inner join profiliutente with(nolock) on pfuidazi=idazi
		where idpfu=@IdUser
	

	declare @Blocco nvarchar(1000)
	set @Blocco = ''


	if @SectionName in(  'TESTATA' , 'TESTATA_OE' , 'ABILITAZIONI' )
	begin

	
		set @Blocco = 'NON_VISIBILE'

		-- se l'azienda è profili P ( procurement ) quindi un ENTE allora posso visualizzare la scheda per l'ente
		if @SectionName = 'TESTATA' and charindex( 'P' , @aziProfili ) > 0 
			set @Blocco = ''
		
			
		-- se l'azienda è profili S ( seller ) quindi un OE allora posso visualizzare la scheda per il fornitore
		if @SectionName = 'TESTATA_OE' and charindex( 'S' , @aziProfili ) > 0 
			set @Blocco = ''
		
		if @SectionName = 'ABILITAZIONI' and charindex( 'S' , @aziProfili ) > 0 
			set @Blocco = ''
		
		
		  
	end
	
	if @SectionName in(  'DATI_AGGIUNTIVI' , 'DATI_AGGIUNTIVI_OE' )
	begin

	
		set @Blocco = 'NON_VISIBILE'

		-- se l'azienda è profili P ( procurement ) quindi un ENTE allora posso visualizzare la scheda per l'ente
		if @SectionName = 'DATI_AGGIUNTIVI' and charindex( 'P' , @aziProfili ) > 0 
			set @Blocco = ''
			
		-- se l'azienda è profili S ( seller ) quindi un OE allora posso visualizzare la scheda per il fornitore
		if @SectionName = 'DATI_AGGIUNTIVI_OE' and charindex( 'S' , @aziProfili ) > 0 
			set @Blocco = ''
			
	
	end


	if @SectionName in(  'SOA')
	begin

		if not exists( select * from AZI_VIEW_SCHEDA_ANAGRAFICA_SOA where idazi = @IdDoc )
			set @Blocco = 'NON_VISIBILE'

	end 

	if @SectionName in(  'ATTIVITA_PROF')
	begin

		if not exists( select * from AZI_VIEW_SCHEDA_ANAGRAFICA_ATTIVITA_PROF where idazi = @IdDoc )
			set @Blocco = 'NON_VISIBILE'

	end 

	if @SectionName in(  'CLASSEISCRIZ')
	begin

		if not exists( select * from AZI_VIEW_SCHEDA_ANAGRAFICA_CLASSEISCRIZ where idazi = @IdDoc )
			set @Blocco = 'NON_VISIBILE'

	end 



	if @SectionName in(  'STORICO')
	begin

		--storico e documenti da visualizzare a: utenti con permesso di 336  e utenti dell'azienda 
		if not  exists( select * from profiliutente with(nolock) where idpfu = @IdUser and ( substring( pfufunzionalita , 336 , 1 ) = '1' or pfuidazi = @IdDoc) )
			set @Blocco = 'NON_VISIBILE'

	end 

	if @SectionName in(  'DOCUMENTAZIONE')
	begin

		--storico e documenti da visualizzare a: utenti con permesso di 336  e utenti dell'azienda 
		if not  exists( select * from profiliutente with(nolock) where idpfu = @IdUser and ( substring( pfufunzionalita , 336 , 1 ) = '1' or pfuidazi = @IdDoc) )
			or ( @aziAcquirente <> 0 )

			set @Blocco = 'NON_VISIBILE'

	end 

	if @SectionName in(  'ABILITAZIONI')
	begin

		if not exists( select * from AZI_VIEW_SCHEDA_ANAGRAFICA_ABILITAZIONI where idazi = @IdDoc )
			set @Blocco = 'NON_VISIBILE'

	end 


	--se utente collegato è fornitore non visualizzo ABILITAZIONI
	if @SectionName =  'ABILITAZIONI' and charindex( 'S' , @aziProfiliUser ) > 0 
	begin

	   set @Blocco = 'NON_VISIBILE'

	end 

	--se utente collegato non è fornitore non visualizzo ABILTAIZIONI2
	if @SectionName =  'ABILITAZIONI2' and charindex( 'S' , @aziProfiliUser ) = 0 
	begin

	   set @Blocco = 'NON_VISIBILE'

	end 


	if @SectionName in(  'ELENCO_DGUE')
	begin

		if not exists( select * from SCHEDA_ANAGRAFICA_View_Elenco_DGUE_Compilati where idazi = @IdDoc and [owner] = @IdUser )
			set @Blocco = 'NON_VISIBILE'

	end 

	if @SectionName in(  'PARAMETRI_ME')
	begin

		if not exists( select * from AZI_VIEW_SCHEDA_ANAGRAFICA_PARAMETRI_ME where Idheader = @IdDoc )
			set @Blocco = 'NON_VISIBILE'

	end 

	if @SectionName in(  'OCP') 
	begin

		-- se non è attiva l'integrazione con l'osservatorio contratti pubblici OPPURE se O.E.
		IF NOT EXISTS ( select id from LIB_Dictionary with(nolock) where DZT_Name like 'SYS_MODULI_RESULT' and SUBSTRING(dzt_valuedef, 424,1) = '1' )
		BEGIN
			set @Blocco = 'NON_VISIBILE'
		END

		IF charindex( 'P' , @aziProfili ) = 0 
			set @Blocco = 'NON_VISIBILE'

	end 

	select @Blocco as Blocco

end













GO
