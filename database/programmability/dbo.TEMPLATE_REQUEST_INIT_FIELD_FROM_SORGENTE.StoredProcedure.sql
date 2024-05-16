USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[TEMPLATE_REQUEST_INIT_FIELD_FROM_SORGENTE]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




















CREATE PROCEDURE [dbo].[TEMPLATE_REQUEST_INIT_FIELD_FROM_SORGENTE] ( @idDoc int   , @Modello_Modulo as varchar(500) , @idDocInUse int, @Svuota_Valori int = 0   )
AS
--Versione=1&data=2016-10-21&Attivita=126293&Nominativo=Sabato
BEGIN
	SET NOCOUNT ON;


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

	declare @idTemplate int

	declare @idBando int
	declare @idAziendaOE int
	declare @idAziendaEnte int

	declare @idUser int

	declare @Editabile varchar(5)
	declare @InCaricoA varchar(50)
	declare @SorgenteCampo varchar(500) , @MA_DZT_Name varchar(500)


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

	declare @Valore					 nvarchar(max)


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
	
	
	-- recupera l'id del template nel caso in cui è stato passato il template specifico e non base
	select 
			@idTemplate = case when TipoDoc = 'TEMPLATE_REQUEST' then id else idDoc end , 
			@TipoTemplate = TipoDoc 
		from ctl_doc 
		where id = @idDoc
	


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

	if @InCaricoA = 'Ente'
		set @idAziendaOE = 0

	-- recupero l'ente
	select 
			@idAziendaEnte = isnull(  p.pfuidazi , 0 ) 
		from ctl_doc d with(nolock)
			inner join profiliutente p with(nolock) on p.idpfu = d.IdPfu
		where id = @idDoc

	-- recupero l'identificativo del bando partendo dal modulo che si sta compilando
	declare @tipoDoc nvarchar(500)
	declare @exit_while nvarchar(500)
	declare @LinkedDoc int
	set @LinkedDoc = @idDocInUse
	set  @tipoDoc = ''
	set  @exit_while = 'NO'

	while @tipoDoc not Like 'BANDO%' and @LinkedDoc <> 0 and @exit_while <> 'SI'
	begin
		set @exit_while='SI'
		select @exit_while='NO',@idBando = id , @LinkedDoc = isnull( linkeddoc , 0 ) , @tipoDoc = TipoDoc from Ctl_Doc where id = @LinkedDoc
	end

	--select @idBando = isnull( i.linkeddoc , 0 ) 
	--	from ctl_doc m with(nolock) 
	--		inner join CTL_DOC i with(nolock) on i.id = m.LinkedDoc
	--	where m.id = @idDocInUse

	--------------------------------------------------------------
	-- recupero tutte le sorgenti per inizializzare il documento
	--------------------------------------------------------------
	--entro se non devo svuotare (ad es. nella copia bando)
	if isnull( @idBando , 0 ) <> 0 and @Svuota_Valori <> 1
	begin

		select @BANDO_CIG = CIG, @BANDO_CUP = CUP, @BANDO_Oggetto = cast( d.Body as nvarchar(max)) , @BANDO_Titolo = d.Titolo
			FROM ctl_doc d with(nolock)
				inner join Document_Bando b with(nolock) on d.id = b.idHeader
			 where d.id = @idBando

	end
	
	--entro se non devo svuotare (ad es. nella copia bando)
	if isnull( @idAziendaEnte , 0 ) <> 0 and @Svuota_Valori <> 1
	begin

		select @Ente_CF = d.vatValore_FT , @Ente_RagSoc = a.aziRagioneSociale , @Ente_Stato =  a.aziStatoLeg2 
			from aziende a
				left outer join DM_Attributi d with(nolock) on a.IdAzi = d.lnk and d.dztNome = 'CodiceFiscale' and d.idApp = 1
			where a.IdAzi = @idAziendaEnte

		if isnull( @Ente_Stato , '' ) = ''
			 set @Ente_Stato  = 'M-1-11-ITA' 

		select @Ente_Stato = DMV_Cod from LIB_DomainValues  with( nolock ) where dmv_dm_id = 'ISO3166_1_ALPHA2' and DMV_CodExt = right( @Ente_Stato , 3 ) 

	end
	
	--entro se non devo svuotare (ad es. nella copia bando)
	if isnull( @idAziendaOE , 0 ) <> 0 and @Svuota_Valori <> 1
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




	-------------------------------------------
	-- recupero tutti gli elementi del template che hanno una sorgente che hanno un acorrispondenza con gli attributi del modello
	-------------------------------------------
	declare CurTemplateRequest Cursor local static for 

		--Select t.value as REQUEST_PART , d.Value as Descrizione , a.Value as  TEMPLATE_REQUEST_GROUP , replace( k.Value , ' ' , '') as KeyRiga , M.Value as idModulo , isNull( S.Value , '1' ) as Editabile
		select G.SorgenteCampo , MA_DZT_Name , isnull( [MAP_Value] , '1' )  as Editabile
			from CTL_DOC_Value t with(nolock) 
				--inner join CTL_DOC_Value d  with(nolock) on t.idheader = d.idheader and t.Row = d.Row and d.DSE_ID = 'VALORI' and d.DZT_Name = 'DescrizioneEstesa'
				--inner join CTL_DOC_Value a  with(nolock) on t.idheader = a.idheader and t.Row = a.Row and a.DSE_ID = 'VALORI' and a.DZT_Name = 'TEMPLATE_REQUEST_GROUP'
				inner join CTL_DOC_Value k  with(nolock) on t.idheader = k.idheader and t.Row = k.Row and k.DSE_ID = 'VALORI' and k.DZT_Name = 'KeyRiga'
				inner join CTL_DOC_Value M  with(nolock) on t.idheader = M.idheader and t.Row = M.Row and M.DSE_ID = 'VALORI' and M.DZT_Name = 'IdModulo'

				inner join DOCUMENT_REQUEST_GROUP G  with(nolock) on G.idheader = M.value

				inner join CTL_ModelAttributes with(nolock) on MA_MOD_ID = @Modello_Modulo 
						and ( 
								MA_DZT_Name = 'MOD_' + replace( k.Value , '.' , '_')  + '_FLD_' +  dbo.GetID_ElementModulo ( ItemPath , ItemLevel  , TypeRequest )
								or
								MA_DZT_Name like 'MOD_' + replace( k.Value , '.' , '_')  + '_FLD_N%' +  dbo.GetID_ElementModulo ( ItemPath , ItemLevel  , TypeRequest ) 
							) 
				left outer join CTL_ModelAttributeProperties with(nolock)  on map_ma_mod_id =  MA_MOD_ID and [MAP_MA_DZT_Name] = MA_DZT_Name and [MAP_Propety] = 'Editable' 

		where t.idHeader=@idTemplate and t.DSE_ID = 'VALORI' and t.DZT_Name = 'REQUEST_PART' 
			and isnull( G.SorgenteCampo , '' ) <> ''
		order by t.Row

	
	open CurTemplateRequest

	FETCH NEXT FROM CurTemplateRequest 	INTO @SorgenteCampo , @MA_DZT_Name , @Editabile
	WHILE @@FETCH_STATUS = 0
	BEGIN

		-- se il valore esiste <> da vuoto lo lascia
		-- se è vuoto lo inizializza
		-- se non esiste lo crea inizializzato	
		set @Value = null
		set @ix = null

		select @Value = Value , @ix = idrow from CTL_DOC_Value where IdHeader = @idDocInUse and DSE_ID = 'MODULO' and DZT_Name = @MA_DZT_Name

		-- devo inizializzare il campo
		-- se devo svuotare forzo ad entrare perchè li ho lasciati vuoti
		if isnull( @Value , '' ) = '' or  @Editabile = '0' or @Svuota_Valori = 1
		begin
			
			--preventivamente lo cancello
			--delete from CTL_DOC_Value where IdHeader = @idDocInUse and DSE_ID = 'MODULO' and DZT_Name = @MA_DZT_Name

			-- recupero il valore richiesto
			if @SorgenteCampo = 'BANDO_CIG'
				set @Valore = @BANDO_CIG

			if @SorgenteCampo = 'BANDO_CUP'
				set @Valore = @BANDO_CUP

			if @SorgenteCampo = 'BANDO_Oggetto'
				set @Valore = @BANDO_Oggetto

			if @SorgenteCampo = 'BANDO_Titolo'
				set @Valore = @BANDO_Titolo

			if @SorgenteCampo = 'Ente_CF'
				set @Valore = @Ente_CF

			if @SorgenteCampo = 'Ente_RagSoc'
				set @Valore = @Ente_RagSoc

			if @SorgenteCampo = 'Ente_Stato'
				set @Valore = @Ente_Stato

			if @SorgenteCampo = 'OE_aziCAPLeg'
				set @Valore = @OE_aziCAPLeg

			if @SorgenteCampo = 'OE_aziE_Mail'
				set @Valore = @OE_aziE_Mail

			if @SorgenteCampo = 'OE_aziIndirizzoLeg'
				set @Valore = @OE_aziIndirizzoLeg

			if @SorgenteCampo = 'OE_aziLocalitaLeg'
				set @Valore = @OE_aziLocalitaLeg

			if @SorgenteCampo = 'OE_aziProvinciaLeg'
				set @Valore = @OE_aziProvinciaLeg

			if @SorgenteCampo = 'OE_aziStatoLeg'
				set @Valore = @OE_aziStatoLeg

			if @SorgenteCampo = 'OE_IscrCCIAA'
				set @Valore = @OE_IscrCCIAA

			if @SorgenteCampo = 'OE_PIVA'
				set @Valore = @OE_PIVA

			if @SorgenteCampo = 'OE_RagSoc'
				set @Valore = @OE_RagSoc

			if @SorgenteCampo = 'OE_SedeCCIAA'
				set @Valore = @OE_SedeCCIAA

			-- lo inserisco
			if @ix is null
				insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					select @idDocInUse as IdHeader, 'MODULO' as  DSE_ID, 0 as [Row], @MA_DZT_Name as DZT_Name, @Valore 
			else
				update CTL_DOC_Value set Value = @Valore where IdRow = @ix

		end

	             

		FETCH NEXT FROM CurTemplateRequest 	INTO @SorgenteCampo , @MA_DZT_Name , @Editabile
	END 
	CLOSE CurTemplateRequest
	DEALLOCATE CurTemplateRequest






end




























GO
