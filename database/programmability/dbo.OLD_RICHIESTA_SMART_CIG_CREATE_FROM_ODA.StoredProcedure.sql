USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_RICHIESTA_SMART_CIG_CREATE_FROM_ODA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE PROCEDURE [dbo].[OLD_RICHIESTA_SMART_CIG_CREATE_FROM_ODA] ( @idDoc int , @IdUser int, @bModifica int = 0)
AS
BEGIN

	SET NOCOUNT ON

	declare @Id as INT
	declare @Idazi as INT
	declare @Errore as nvarchar(2000)
	declare @newid as int
	declare @idr as int
	declare @Bando as int
	declare @Rup varchar(50)
	declare @Body nvarchar( max )

	declare @CF_AMMINISTRAZIONE varchar(20)
	declare @CF_UTENTE varchar(20)
	declare @Tipo_Rup as varchar(100)

	set @Errore=''	
	
	
	-- SE STO PROVENENDO DA UNA RICHIESTA SMART CIG ( E NON DA UNA MODIFICA CIG )
	if @bModifica = 0
	BEGIN

		---CERCO UNA RICHIESTA IN CORSO CREATA DA QUEL DOCUMENTO
		select @newId = max(id) from CTL_DOC  with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in (  'RICHIESTA_SMART_CIG'  ) and StatoFunzionale <> 'Annullato'

		-- in caso di riapertura con documento in lavorazione dovremmo aggiungere un passo riallineare i dati fra il bando e la richiesta CIG
		
	END

	if @newId is null
	begin

		set @Bando = @idDoc

		-- prima di creare il documento verifico i requisiti necessari:
			--1) Non deve esserci una richiesta cig in corso
			--2) Sia stato inserito l'oggetto
			--3) Sia presente il RUP
			
		IF EXISTS ( select id from CTL_DOC  with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in (  'RICHIESTA_CIG'  ) and StatoFunzionale <> 'Annullato' )
		BEGIN
			set @Errore = 'Impossibile effettuare una richiesta SMART CIG con una RICHIESTA CIG in corso'
		END
			
		-- verifica Oggetto
		if @Errore = ''
		begin

			select @Body = note from CTL_DOC with(nolock) where id = @Bando

			if isnull( @Body , '' ) = '' 
				set @Errore = 'Per effettuare la richiesta dei CIG Occorre aver inserito la descrizione dell''acquisto'

		end

		-- verifica rup non selezionato
		if @Errore = ''
		begin
			
			--select @Tipo_Rup=dbo.PARAMETRI ('SIMOG','TIPO_RUP','DefaultValue','UserRUP',-1) 
			
			--if @Tipo_Rup='UserRUP'
			--	select @Rup = Value from ctl_doc_value  with(nolock) where idheader = @Bando and dse_id = 'CRITERI_ECO' and dzt_name = @Tipo_Rup 
			--else
			--	select @Rup = RupProponente from document_bando  with(nolock) where idheader = @Bando 

			--if isnull( @Rup , '' ) = '' 
			--begin
			--	if @Tipo_Rup='UserRUP'	
			--		set @Errore = 'Per effettuare la richiesta dei CIG Occorre aver indicato il RUP'
			--	else
			--		set @Errore = 'Per effettuare la richiesta dei CIG Occorre aver indicato il RUP proponente'
			--end

			select @Rup = idpfuRup from document_ODA with(nolock) where idheader = @idDoc
			if isnull( @Rup , '' ) = '' 
			begin
				set @Errore = 'Per effettuare la richiesta dei CIG Occorre aver indicato il RUP'

			end


		end

		-- se non sono presenti errori
		if @Errore = ''
		begin

			declare @jumpcheck varchar(100)
			declare @caption varchar(100)

			set @caption = null
			set @jumpcheck = ''

			if @bModifica = 1
			begin

				set @jumpcheck = 'MODIFICA'
				set @caption =  'Modifica - Richiesta Smart CIG'

			end

			-- CREO IL DOCUMENTO
			INSERT into CTL_DOC (IdPfu,  TipoDoc  , idpfuincharge ,Azienda ,body,LinkedDoc,JumpCheck, caption )
				select  @IdUser,'RICHIESTA_SMART_CIG' , @IdUser ,Azienda,body,@idDoc, @jumpcheck, @caption
					from ctl_doc with(nolock)
					where id=@idDoc		

			set @newId = SCOPE_IDENTITY()

			-- recupero il codice fiscale dell'ente
			select @CF_AMMINISTRAZIONE = vatValore_FT 
				from ctl_doc with(nolock) 
						inner join DM_Attributi with(nolock) on azienda = lnk and idApp = 1 and dztnome = 'codicefiscale'
				where id = @Bando

			-- recupero il CF del RUP
			-- o quello del campo dirigente?
			select @CF_UTENTE = pfucodicefiscale  from ProfiliUtente with(nolock) where idpfu = @Rup 

			if @bModifica = 0
			begin

				-- inserisco i dati base della gara
				insert into Document_SIMOG_SMART_CIG
					(	[idHeader], [CF_AMMINISTRAZIONE], [CF_UTENTE], [IMPORTO_GARA], [idpfuRup], smart_cig )
					select 
							@newId				as [idHeader], 
							@CF_AMMINISTRAZIONE as [CF_AMMINISTRAZIONE], 
							@CF_UTENTE			as [CF_UTENTE], 
							TotaleEroso			as [IMPORTO_GARA], 
							@Rup				as [idpfuRup],
							cig					
						from document_ODA with(nolock) 
						where idHeader = @Bando

			end
			else
			begin

				-- inserisco i dati base della gara
				insert into Document_SIMOG_SMART_CIG (	[idHeader], [IMPORTO_GARA], [idpfuRup], smart_cig,[indexCollaborazione], [ID_STAZIONE_APPALTANTE], [DENOM_STAZIONE_APPALTANTE], [CF_AMMINISTRAZIONE], 
							[DENOM_AMMINISTRAZIONE], [CF_UTENTE], [codiceFattispecieContrattuale], [codiceProceduraSceltaContraente], 
							[codiceClassificazioneGara], [cigAccordoQuadro], [cup], 
							[motivo_rich_cig_comuni], [motivo_rich_cig_catmerc], [CATEGORIE_MERC] )
					select 
							@newId				as [idHeader], 
							b.TotaleEroso	as [IMPORTO_GARA], 
							@Rup				as [idpfuRup],
							b.cig,
							
							[indexCollaborazione], [ID_STAZIONE_APPALTANTE], [DENOM_STAZIONE_APPALTANTE], [CF_AMMINISTRAZIONE], 
							[DENOM_AMMINISTRAZIONE], [CF_UTENTE], [codiceFattispecieContrattuale], [codiceProceduraSceltaContraente], 
							[codiceClassificazioneGara], [cigAccordoQuadro], c.[cup], 
							[motivo_rich_cig_comuni], [motivo_rich_cig_catmerc], c.[CATEGORIE_MERC]
							
						from ctl_doc a with(nolock) 
								inner join document_ODA b with(nolock) on b.idHeader = a.linkeddoc
								inner join Document_SIMOG_SMART_CIG c with(nolock) on c.idHeader = a.Id
						where a.LinkedDoc = @Bando and a.TipoDoc = 'RICHIESTA_SMART_CIG' and a.StatoFunzionale = 'Inviato' and a.Deleted = 0

			end
		
		end

	end


	if  ISNULL(@newId,0) <> 0
	begin
		-- rirorna l'id del doc da aprire
		select @newId as id, 'RICHIESTA_SMART_CIG' as TYPE_TO
	
	end
	else
	begin

		select 'Errore' as id , @Errore as Errore

	end
END










GO
