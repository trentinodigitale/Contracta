USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_RICHIESTA_SMART_CIG_CREATE_FROM_ODC]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[OLD_RICHIESTA_SMART_CIG_CREATE_FROM_ODC] ( @odc int , @IdUser int, @bModifica int = 0)
AS
BEGIN

	SET NOCOUNT ON

	
	declare @debugMode INT
	set @debugMode = 0

	declare @Id as INT
	declare @Idazi as INT
	declare @Errore as nvarchar(2000)
	declare @newid as int
	declare @idr as int
	declare @idGara as int
	declare @Rup varchar(50)
	declare @Body nvarchar( max )

	declare @CF_AMMINISTRAZIONE varchar(20)
	declare @CF_UTENTE varchar(20)

	declare @cigMaster varchar(100)
	declare @COD_LUOGO_ISTAT varchar(50)
	declare @importoTotale float --Importo dell’OdF al netto dell’IVA

	set @Errore=''	
	
	
	-- SE STO PROVENENDO DA UNA RICHIESTA SMART CIG ( E NON DA UNA MODIFICA CIG )
	if @bModifica = 0
	BEGIN

		---CERCO UNA RICHIESTA IN CORSO CREATA DA QUEL DOCUMENTO
		select @newId = max(id) from CTL_DOC  with(nolock) where LinkedDoc = @odc and deleted = 0 and TipoDoc in (  'RICHIESTA_SMART_CIG'  ) and StatoFunzionale <> 'Annullato'

	END

	if @newId is null
	begin

		select  @cigMaster = CIG_MADRE, 
				@COD_LUOGO_ISTAT = FatturazioneLocalita2,
				@Rup = idpfuRup,
				@importoTotale = isnull(RDA_Total,0)
			from document_odc with(nolock)
			where rda_id = @ODC

	
		IF  @debugMode = 0
		BEGIN
			
			IF EXISTS ( select id from CTL_DOC  with(nolock) where LinkedDoc = @odc and deleted = 0 and TipoDoc in (  'RICHIESTA_CIG'  ) and StatoFunzionale <> 'Annullato' )
			BEGIN
				set @Errore = 'Impossibile effettuare una richiesta SMART CIG con una RICHIESTA CIG in corso'
			END
	
			-- verifica Oggetto
			if @Errore = ''
			begin

				select @Body = note from CTL_DOC with(nolock) where id = @ODC

				if isnull( @Body , '' ) = '' 
					set @Errore = 'Per effettuare la richiesta dei CIG Occorre aver inserito il campo ''Descrizione Ordinativo'''

			end

			if @Errore = ''
			begin

				if isnull( @cigMaster , '' ) = '' 
					set @Errore = 'Per effettuare la richiesta del CIG occorre aver indicato il CIG MASTER'
			end

			-- verifica rup non selezionato
			if @Errore = ''
			begin

				if isnull( @Rup , '' ) = '' 
					set @Errore = 'Per effettuare la richiesta dei CIG Occorre aver indicato il RUP'

			end

			if @Errore = ''
			begin

				if @importoTotale = 0
					set @Errore = 'Per effettuare la richiesta del CIG il Totale Ordinativo deve essere valorizzato e maggiore di 0'
			end

		END


		if @errore = ''
		begin


			--RISALGO SULLA GARA DI ORIGINE DEL CIG MASTER. In sua assenza blocco
			select top 1 @idGara = g.id
				from ctl_doc g with(nolock)
						inner join document_bando b with(nolock) on b.idHeader = g.id
						inner join Document_MicroLotti_Dettagli m with(nolock) on m.IdHeader = g.id and m.TipoDoc = g.TipoDoc and m.voce = 0
				where g.tipodoc IN ( 'BANDO_GARA', 'BANDO_SEMPLIFICATO') and g.Deleted = 0 and g.StatoFunzionale not in ( 'InLavorazione', 'Annullato' , 'Revocato', 'Rifiutato' )
						and ( b.cig = @cigMaster or m.CIG = @cigMaster )
				order by g.id desc


			IF @debugMode = 0
			BEGIN

				if @idGara is null
				begin
					set @Errore = 'Richiesta CIG non possibile. Il cig master non risulta associato a nessuna procedura in piattaforma'
				end

			END


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
			INSERT into CTL_DOC (IdPfu,  TipoDoc  , idpfuincharge ,Azienda ,body,LinkedDoc,JumpCheck, caption,iddoc )
				select  @IdUser,'RICHIESTA_SMART_CIG' , @IdUser ,Azienda,body,@odc, @jumpcheck, @caption, @idGara
					from ctl_doc with(nolock)
					where id=@odc		

			set @newId = SCOPE_IDENTITY()

			-- recupero il codice fiscale dell'ente
			select @CF_AMMINISTRAZIONE = vatValore_FT 
				from ctl_doc with(nolock) 
						inner join DM_Attributi with(nolock) on azienda = lnk and idApp = 1 and dztnome = 'codicefiscale'
				where id = @idGara

			-- recupero il CF del RUP
			select @CF_UTENTE = pfucodicefiscale  from ProfiliUtente with(nolock) where idpfu = @Rup 

			if @bModifica = 0
			begin

				-- inserisco i dati base della gara
				insert into Document_SIMOG_SMART_CIG
					(	[idHeader], [CF_AMMINISTRAZIONE], [CF_UTENTE], [IMPORTO_GARA], [idpfuRup], smart_cig, codiceProceduraSceltaContraente, motivo_rich_cig_catmerc, cigAccordoQuadro )
					select 
							@newId				as [idHeader], 
							@CF_AMMINISTRAZIONE as [CF_AMMINISTRAZIONE], 
							@CF_UTENTE			as [CF_UTENTE], 
							RDA_Total	as [IMPORTO_GARA], 
							@Rup				as [idpfuRup],
							''					,
							'26',
							'EAM-2',
							CIG_MADRE
						from document_odc with(nolock) 
						where rda_id = @odc

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
							b.RDA_Total	as [IMPORTO_GARA], 
							@Rup				as [idpfuRup],
							b.cig,
							
							[indexCollaborazione], [ID_STAZIONE_APPALTANTE], [DENOM_STAZIONE_APPALTANTE], @CF_AMMINISTRAZIONE, 
							[DENOM_AMMINISTRAZIONE], @CF_UTENTE, [codiceFattispecieContrattuale], [codiceProceduraSceltaContraente], 
							[codiceClassificazioneGara], b.CIG_MADRE , '', 
							[motivo_rich_cig_comuni], [motivo_rich_cig_catmerc], [CATEGORIE_MERC]
						from ctl_doc a with(nolock) 
								inner join document_odc b with(nolock) on b.rda_id = a.linkeddoc
								inner join Document_SIMOG_SMART_CIG c with(nolock) on c.idHeader = a.Id
						where a.LinkedDoc = @odc and a.TipoDoc = 'RICHIESTA_SMART_CIG' and a.StatoFunzionale = 'Inviato' and a.Deleted = 0

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
