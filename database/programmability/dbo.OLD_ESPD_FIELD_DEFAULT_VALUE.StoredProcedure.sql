USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_ESPD_FIELD_DEFAULT_VALUE]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE proc [dbo].[OLD_ESPD_FIELD_DEFAULT_VALUE] ( @idDocInUse  int )
AS
--Versione=1&data=2019-02-12&Attivita=159567&Nominativo=Sabato
BEGIN


	--declare @Template nvarchar( max )

	--declare @REQUEST_PART varchar(100),   @Descrizione nvarchar( max),   @TEMPLATE_REQUEST_GROUP varchar(200)
	--declare @REQUEST_PART_CUR varchar(100),   @TEMPLATE_REQUEST_GROUP_CUR varchar(200)
	--declare @Parte_aperta int
	--declare @Gruppo_Aperto int
	declare @KeyRiga varchar(500)
	declare @KeyGruppoAperto varchar(500)
	declare @TipoTemplate varchar(500)
	
	declare @idModulo int
	declare @NRow int
	declare @RG_FLD_TYPE varchar(max)
	declare @Value varchar(max)
	declare @ix int

	--declare @idTemplate int

	declare @idBando int
	declare @idAziendaOE int
	declare @idAziendaEnte int

	declare @idUser int
	declare @UserRUP int
	
	declare @Editabile varchar(5)
	declare @InCaricoA varchar(50)
	declare @Divisione_Lotti varchar(500) , @MA_DZT_Name varchar(500)


	declare @BANDO_CIG				 nvarchar(4000) 
	declare @BANDO_CUP				 nvarchar(4000) 
	declare @BANDO_Oggetto			 nvarchar(max) 
	declare @BANDO_Titolo			 nvarchar(4000)	
	declare @Ente_CF				 nvarchar(4000) 
	declare @Ente_RagSoc			 nvarchar(4000) 
	declare @Ente_Stato				 nvarchar(4000) 
	declare @OE_aziCAPLeg			 nvarchar(4000) 
	declare @OE_aziE_Mail			 nvarchar(4000) 
	declare @OE_aziIndirizzoLeg		 nvarchar(4000) 
	declare @OE_aziLocalitaLeg		 nvarchar(4000) 
	declare @OE_aziProvinciaLeg		 nvarchar(4000) 
	declare @OE_aziStatoLeg			 nvarchar(4000) 
	declare @OE_IscrCCIAA			 nvarchar(4000) 
	declare @OE_PIVA				 nvarchar(4000) 
	declare @OE_RagSoc				 nvarchar(4000) 
	declare @OE_SedeCCIAA			 nvarchar(4000) 

	declare @BANDO_LOTTO_CIG		 nvarchar(4000) 
	declare @BANDO_NumeroGara		 nvarchar(4000) 
	declare @BANDO_RUP				 nvarchar(4000) 
	declare @BANDO_RUP_TEL			 nvarchar(4000) 
	declare @BANDO_RUP_MAIL			 nvarchar(4000) 
	declare @Ente_Indirizzo			 nvarchar(4000) 
	declare @Ente_Localita			 nvarchar(4000) 
	declare @Ente_CAP				 nvarchar(4000) 
	declare @Ente_SitoWeb			 nvarchar(4000) 
	declare @Ente_CUC_CF			 nvarchar(4000) 
	declare @Ente_CUC_RagSoc		 nvarchar(4000) 
	declare @OE_IDENTIFIER_EO		 nvarchar(4000) 


	set @BANDO_CIG				 = '' 
	set @BANDO_CUP				 = '' 
	set @BANDO_Oggetto			 = '' 
	set @BANDO_Titolo			 = ''	
	set @Ente_CF				 = '' 
	set @Ente_RagSoc			 = '' 
	set @Ente_Stato				 = '' 
	set @OE_aziCAPLeg			 = '' 
	set @OE_aziE_Mail			 = '' 
	set @OE_aziIndirizzoLeg		 = '' 
	set @OE_aziLocalitaLeg		 = '' 
	set @OE_aziProvinciaLeg		 = '' 
	set @OE_aziStatoLeg			 = '' 
	set @OE_IscrCCIAA			 = '' 
	set @OE_PIVA				 = '' 
	set @OE_RagSoc				 = '' 
	set @OE_SedeCCIAA			 = '' 


	set @BANDO_LOTTO_CIG		 = '' 
	set @BANDO_NumeroGara		 = '' 
	set @BANDO_RUP				 = '' 
	set @BANDO_RUP_TEL			 = '' 
	set @BANDO_RUP_MAIL			 = '' 
	set @Ente_Indirizzo			 = '' 
	set @Ente_Localita			 = '' 
	set @Ente_CAP				 = '' 
	set @Ente_SitoWeb			 = '' 
	set @Ente_CUC_CF			 = '' 
	set @Ente_CUC_RagSoc		 = '' 
	
	declare @crlf varchar(10)
	set @crlf  = '
'

	--set @Parte_aperta = 0
	--set @Gruppo_Aperto = 0 

	--set @Template  = ''
	--set @REQUEST_PART_CUR = '' 
	--set @TEMPLATE_REQUEST_GROUP_CUR = ''

	set @idBando = 0 
	set @idAziendaOE = 0 
	set @idAziendaEnte = 0
	
	
	---- recupera l'id del template nel caso in cui è stato passato il template specifico e non base
	--select 
	--		@idTemplate = case when TipoDoc = 'TEMPLATE_REQUEST' then id else idDoc end , 
	--		@TipoTemplate = TipoDoc 
	--	from ctl_doc 
	--	where id = @idDoc
	


	-- recupero se il documento in uso è di un ente o di un oe
	select  
			@InCaricoA = case when aziAcquirente <> 0 then 'Ente' else 'OE' end 
			, @idUser  = d.IdPfu
			, @idAziendaOE = isnull( a.idazi , 0 ) 
		from ctl_doc d with(nolock)
			inner join profiliutente p with(nolock) on p.idpfu = d.IdPfu
			inner join aziende a with(nolock) on p.pfuidazi = a.idazi
		where id = @idDocInUse
	
	set @InCaricoA = isnull( @InCaricoA , 'Ente')

	-- se il campo è di un documento di un ente
	if @InCaricoA = 'Ente'
	begin
		set @idAziendaEnte = @idAziendaOE 
		set @idAziendaOE = 0
	end



	-- recupero l'identificativo del bando partendo dal modulo che si sta compilando
	declare @tipoDoc nvarchar(500)
	declare @LinkedDoc int
	set @LinkedDoc = @idDocInUse
	set  @tipoDoc = ''

	while @tipoDoc not Like 'BANDO%' and @LinkedDoc <> 0 
	begin
		select @idBando = id , @LinkedDoc = isnull( linkeddoc , 0 ) , @tipoDoc = TipoDoc from Ctl_Doc where id = @LinkedDoc
	end




	--------------------------------------------------------------
	-- recupero tutte le sorgenti per inizializzare il documento
	--------------------------------------------------------------
	if isnull( @idBando , 0 ) <> 0 
	begin

		select @BANDO_CIG = CIG , @BANDO_NumeroGara = CIG , @BANDO_CUP = CUP, @BANDO_Oggetto = cast( d.Body as nvarchar(max)) , @BANDO_Titolo = d.Titolo , @Divisione_Lotti = Divisione_Lotti
		--select CIG as BANDO_CIG  , CUP as BANDO_CUP , cast( d.Body as nvarchar(max)) as BANDO_Oggetto  , d.Titolo as BANDO_Titolo 
			FROM ctl_doc d with(nolock)
				inner join Document_Bando b with(nolock) on d.id = b.idHeader
			 where d.id = @idBando

		if @Divisione_Lotti <> '0'

			SELECT @BANDO_LOTTO_CIG =  @BANDO_LOTTO_CIG + '###' + cast(@idBando as varchar (50)) + '_LOTTO' + Numerolotto + '_' + CIG  
				FROM Document_MicroLotti_Dettagli with(nolock)
				where tipodoc = @tipoDoc
					and idheader = @idBando
					and voce = 0 
		else
			set @BANDO_LOTTO_CIG = '###'+ cast(@idBando as varchar (50)) +'_LOTTO1_' + @BANDO_CIG
		
		set @BANDO_LOTTO_CIG = @BANDO_LOTTO_CIG + '###'
	
		select @UserRUP = VALUE from ctl_doc_value with(nolock) where idheader = @idBando and dzt_name = 'UserRUP' and DSE_ID = 'InfoTec_comune' 
		

		SELECT @BANDO_RUP = pfuNome , @BANDO_RUP_TEL = pfuTel , @BANDO_RUP_MAIL = pfuE_Mail FROM PROFILIUTENTE WITH(NOLOCK) WHERE IDPFU = @UserRUP

	end


	if isnull( @idAziendaEnte , 0 ) <> 0 
	begin

		select @Ente_CF = d.vatValore_FT , @Ente_RagSoc = a.aziRagioneSociale , @Ente_Stato =  a.aziStatoLeg2 
				,@Ente_Indirizzo = [aziIndirizzoLeg]
				,@Ente_Localita = [aziLocalitaLeg]
				,@Ente_CAP = [aziCAPLeg]
				,@Ente_SitoWeb = [aziSitoWeb]

			from aziende a
				left outer join DM_Attributi d with(nolock) on a.IdAzi = d.lnk and d.dztNome = 'CodiceFiscale' and d.idApp = 1
			where a.IdAzi = @idAziendaEnte

		if isnull( @Ente_Stato , '' ) = ''
			 set @Ente_Stato  = 'M-1-11-ITA' 

		select @Ente_Stato = DMV_Cod from LIB_DomainValues  with( nolock ) where dmv_dm_id = 'ISO3166_1_ALPHA2' and DMV_CodExt = right( @Ente_Stato , 3 ) 
		select @Ente_Localita = DMV_DescML from LIB_DomainValues  with( nolock ) where dmv_dm_id = 'GEO' and DMV_CodExt = @Ente_Localita 

		select @Ente_CUC_RagSoc = aziRagioneSociale , @Ente_CUC_CF = d.vatValore_FT  
			from [MarketPlace] m with( nolock) 
				inner join aziende a with(nolock) on a.idazi = m.mpIdAziMaster
				left outer join DM_Attributi d with(nolock) on a.IdAzi = d.lnk and d.dztNome = 'CodiceFiscale' and d.idApp = 1
	end

	
	if isnull( @idAziendaOE , 0 ) <> 0 
	begin

		select 
			@OE_aziCAPLeg = a.aziCAPLeg
			,@OE_aziE_Mail = [aziE_Mail]
			,@OE_aziIndirizzoLeg = [aziIndirizzoLeg]
			,@OE_aziLocalitaLeg = [aziLocalitaLeg]
			,@OE_aziProvinciaLeg = [aziProvinciaLeg]
			,@OE_aziStatoLeg = [aziStatoLeg2]
			,@OE_IscrCCIAA =  I.vatValore_FT
			,@OE_PIVA = [aziPartitaIVA]
			,@OE_RagSoc = [aziRagioneSociale]
			,@OE_SedeCCIAA = S.vatValore_FT
			from aziende a
				left outer join DM_Attributi d with(nolock) on a.IdAzi = d.lnk and d.dztNome = 'CodiceFiscale' and d.idApp = 1
				left outer join DM_Attributi I with(nolock) on a.IdAzi = I.lnk and I.dztNome = 'IscrCCIAA' and I.idApp = 1
				left outer join DM_Attributi S with(nolock) on a.IdAzi = S.lnk and S.dztNome = 'SedeCCIAA' and S.idApp = 1
			where a.IdAzi = @idAziendaOE

		-- converte il codice del domino geo nella versione per il modulo a 2 caratteri
		select @OE_aziStatoLeg = DMV_Cod from LIB_DomainValues  with( nolock ) where dmv_dm_id = 'ISO3166_1_ALPHA2' and DMV_CodExt = right( @OE_aziStatoLeg , 3 ) 
	end




	
------------------------
-- aggiungere :
------------------------

--Ente_Indirizzo
--Ente_Localita
--Ente_CAP
--Ente_SitoWeb
--Ente_CUC_CF
--Ente_CUC_RagSoc

--BANDO_LOTTO_CIG
--BANDO_NumeroGara
--BANDO_RUP
--BANDO_RUP_TEL
--BANDO_RUP_MAIL

	--select  * from CTL_Parametri where contesto='DGUE'

	--leggo dai parametri il valore da restituire per OE_IDENTIFIER_EO
	select @OE_IDENTIFIER_EO = dbo.PARAMETRI('DGUE','OE_IDENTIFIER_EO','DefaultValue','',-1)

	select 
		@BANDO_CIG			as BANDO_CIG
		,@BANDO_CUP			as BANDO_CUP
		,@BANDO_Oggetto		as BANDO_Oggetto
		,@BANDO_Titolo		as BANDO_Titolo

		,@BANDO_LOTTO_CIG	as BANDO_LOTTO_CIG
		,@BANDO_NumeroGara	as BANDO_NumeroGara
		,@BANDO_RUP			as BANDO_RUP
		,@BANDO_RUP_TEL		as BANDO_RUP_TEL
		,@BANDO_RUP_MAIL	as BANDO_RUP_MAIL
		,@Ente_Indirizzo	as Ente_Indirizzo
		,@Ente_Localita		as Ente_Localita
		,@Ente_CAP			as Ente_CAP
		,@Ente_SitoWeb		as Ente_SitoWeb
		,@Ente_CUC_CF		as Ente_CUC_CF
		,@Ente_CUC_RagSoc	as Ente_CUC_RagSoc

		,@Ente_CF			as Ente_CF
		,@Ente_RagSoc		as Ente_RagSoc
		,@Ente_Stato		as Ente_Stato

		,@OE_aziCAPLeg		as OE_aziCAPLeg
		,@OE_aziE_Mail		as OE_aziE_Mail
		,@OE_aziIndirizzoLeg as OE_aziIndirizzoLeg
		,@OE_aziLocalitaLeg as OE_aziLocalitaLeg
		,@OE_aziProvinciaLeg as OE_aziProvinciaLeg
		,@OE_aziStatoLeg	as OE_aziStatoLeg
		,@OE_IscrCCIAA		as OE_IscrCCIAA
		,@OE_PIVA			as OE_PIVA
		,@OE_RagSoc			as OE_RagSoc
		,@OE_SedeCCIAA		as OE_SedeCCIAA
		,@OE_IDENTIFIER_EO  as OE_IDENTIFIER_EO

	




end




























GO
