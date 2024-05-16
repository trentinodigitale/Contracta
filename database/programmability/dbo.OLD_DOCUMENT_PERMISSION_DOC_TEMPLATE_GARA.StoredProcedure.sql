USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DOCUMENT_PERMISSION_DOC_TEMPLATE_GARA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

------------------------------------------------------------------
-- ***** stored generica che controlla l'accessibilita ai documenti nuovi ****
-- *****          Applica le seguente regole  *******
-- Ti permetto l'apertura del documento : 
--	1)   Se il tuo idpfu coincide con l'owner del documento ( ctl_doc.idpfu ) 
--  2)   se utente appartiene all'azienda del compilatore 
--  3)   se il template è stato creato da un utente dell'azienda master

CREATE proc [dbo].[OLD_DOCUMENT_PERMISSION_DOC_TEMPLATE_GARA]
( 
	@idPfu   as int  , 
	@idDoc as varchar(50) ,
	@param as varchar(250)  = NULL  
)
as
begin

	SET NOCOUNT ON

	declare @User_Has_Profilo_Investigativo as int

	set @User_Has_Profilo_Investigativo = 0
	
	if exists (select idpfu from ProfiliUtenteAttrib where  dztnome = 'Profilo' and attvalue ='Profilo_Investigativo' and idPfu = @idPfu)
		set @User_Has_Profilo_Investigativo = 1

	if ( upper( substring( @idDoc, 1, 3 ) ) = 'NEW' or @idDoc = '' )  and dbo.GetPos( ISNULL( @param , '' ) , '@@@' , 1 ) = ''  -- @param is null 
		or
		exists( select idpfu from ProfiliUtenteAttrib where  dztnome = 'Profilo' and attvalue in ('Direttore', 'Amministratore' ) and idPfu = @idPfu )
	begin
		select 1 as bP_Read , 1 as bP_Write
	end
	else
	begin
	
		begin
			
			-- SE IDDOC è stringa vuota e param è valorizzato siamo in un makedocfrom
			IF (@idDoc = '' or upper( substring( @idDoc, 1, 3 ) ) = 'NEW') and not @param is null 
			BEGIN
				--set @idDoc = cast ( substring ( @param, charindex(',', @param) + 1, len( @param ) ) as int )
				set @idDoc = dbo.GetPos( @param , ',' , 2 ) 

				if dbo.GetPos( @param , ',' , 1 ) = 'LOTTO' -- in questo caso stiamo creando un esito per un lotto in una PDA
				begin 
					-- recuperiamo l'id del documento risalendo dalla microlotti dettagli alla PDA
					select @idDoc = o.idheader from document_microlotti_dettagli d
						inner join document_pda_offerte o on d.idheader = o.idrow
						where d.id = @idDoc

				end 
				else
				begin
					--E.P. per gli altri makedocfrom faccio passare per adesso
					--perchè andrebbero gestiti i vari documenti che voglio craere dalle diverse sorgenti
					select 1 as bP_Read , 1 as bP_Write
					return
				end
			END

			-- per la PDA_MICROLOTTI controllo accesso sul tipo utente
			declare @TipoDoc as varchar(200)
			declare @LinkedDoc as int
			declare @Esito as varchar(100)
			declare @Errore as nvarchar(2000)
			declare @StatoDoc as varchar(100)

			IF ISNUMERIC(@idDoc) = 1
			BEGIN
				select @StatoDoc=StatoDoc,@TipoDoc=TipoDoc,@LinkedDoc=LinkedDoc from ctl_doc where id = @idDoc
			END
				
				declare @proceduragara as varchar(50)
				declare @EvidenzaPubblica as varchar(1)

				set @proceduragara=''
				set @EvidenzaPubblica='0'

				--se sono su un bando procedura aperta posso aprire
				--if @TipoDoc in ('BANDO_GARA','BANDO_SDA','BANDO_SEMPLIFICATO','BANDO_CONSULTAZIONE') 
				--begin
					select top 1 @proceduragara=proceduragara,@EvidenzaPubblica=EvidenzaPubblica from document_bando where idheader=@idDoc
				--end
        
					--recupero azienda utente collegato
					declare @idAzi int
					select @idAzi = pfuIdAzi  from profiliutente with(nolock) where idPfu = @idPfu

					-- Se fai parte dell'azienda dell'ente, cioè dell'azienda master
					-- e non vieni dalla parte pubblica
					if exists(SELECT * FROM MarketPlace where mpidazimaster = @idAzi) and @idPfu>0
					begin
						select 1 as bP_Read , 1 as bP_Write
					end
					else
					begin
						
						declare @owner int
						declare @pfuInCharge int
						declare @idAziOwner int
						declare @Azienda_doc int
						declare @Destinatario_User int
						declare @Destinatario_Azi int
						declare @passed int -- variabile di controllo
						declare @StatoFunzionale as varchar(100)

						set @idAziOwner = -1
						set @pfuInCharge = -1
						set @owner = -1
						set @passed = 0 -- non passato
						set @Azienda_doc = -1
						set @Destinatario_User = -1
						set @Destinatario_Azi = -1

						-- Recupero i valori della variabili utilizzate per i test di sicurezza
						select 
							@owner = isnull(idpfu,-20) , @pfuInCharge = isnull(idpfuincharge,-100),
							@Azienda_doc = isnull(Azienda,-1),@Destinatario_User = isnull(Destinatario_User,-1),
							@Destinatario_Azi = isnull(Destinatario_Azi,-1),
							@StatoFunzionale=StatoFunzionale
						from 
							ctl_doc with(nolock) 
						where id = @idDoc
						
						-- recupero azienda del destinatario
						
						select @idAziOwner = pfuIdAzi from profiliutente with(nolock) where idPfu = @owner
						
						--Se il tuo idpfu coincide con l'owner del documento ( ctl_doc.idpfu ) 
						if @idPfu = @owner 
						begin
							set @passed = 1 --passato
						end 
						
						
						--Se il compilatore del template è un utente dell'azimaster
						--oppure l'utente è della stessa azienda del compilatore
						if exists ( select * from MarketPlace where mpIdAziMaster = @idAziOwner and @StatoFunzionale = 'pubblicato')
								or
								 @idAzi = @idAziOwner
						begin
							set @passed = 1 --passato
						end 


						-- Verifico se l'utente stà aprendo la scheda della sua azienda
						if @passed = 1
							select 1 as bP_Read , 1 as bP_Write
						else
							select 0 as bP_Read , 0 as bP_Write from profiliutente where idpfu = -100
						
					end
				
		end
	
	end

end

GO
