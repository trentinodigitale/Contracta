USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_ESITO_AMMESSA_CON_RISERVA_CREATE_FROM_RIGA_PDA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE  PROCEDURE [dbo].[OLD_ESITO_AMMESSA_CON_RISERVA_CREATE_FROM_RIGA_PDA] 
	( @idRow int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @IdMittente as int
	declare @IdAziMittente as int
	declare @ProtocolloOfferta as varchar(50)
	declare @Oggetto as nvarchar(4000)
	declare @ProtocolloBando as varchar(50)
	declare @Fascicolo as  varchar(50)
	declare @IdDestinatario as int
	declare @TipoDoc as  varchar(50)
	declare @IdPDA as int
	declare @Errore as nvarchar(2000)
	declare @IdLast as int
	declare @IdOff as int
	declare @EsclusioneLotti as varchar(20)
	declare @IdAziPartecipante as int
	--select * from document_pda_offerte where idheader=58951	

	set @Errore=''
	set @TipoDoc='OFFERTA'

	--recupero id della pda
	select 
		 @IdPDA=Idheader,@IdOff=idMsg,@EsclusioneLotti=isnull(EsclusioneLotti,'')
	from 
		document_pda_offerte 
			--inner join ctl_doc PDA on PO.Idheader=PDA.id and PDA.TipoDoc='PDA_MICROLOTTI' and PDA.deleted=0
			--	left outer join ctl_doc O on PO.idmsg=O.id and PO.TipoDoc=O.TipoDoc and O.deleted=0
	where 
		idrow=@idRow
	
	--per offerte FT e per PDA <> VERIFICA_AMMINISTRATIVA a creare il documento deve essere il  presidente della commissione A
	SET @Errore = 'Operazione consentita solo al presidente della commissione A'
	IF NOT EXISTS ( 
					SELECT us.UtenteCommissione 
						from ctl_doc pda with(nolock)
								inner join ctl_doc gara with(nolock) ON gara.id = pda.LinkedDoc and gara.Deleted = 0
								inner join ctl_doc co with(nolock) ON co.LinkedDoc = gara.ID and co.tipodoc = 'COMMISSIONE_PDA' and co.Deleted = 0
								inner join Document_CommissionePda_Utenti us with(nolock) ON us.idheader = co.id and us.TipoCommissione = 'A' and us.ruolocommissione='15548' and us.UtenteCommissione <> @idUser
								inner join CTL_DOC_Value CV with(NOLOCK) on CV.IdHeader=@IdOff and DSE_ID='OFFERTA' and DZT_Name='FUORI_TERMINI' and Value='1' and Row=0 
						where pda.id = @idPDA and pda.tipodoc = 'PDA_MICROLOTTI' and pda.StatoFunzionale <> 'VERIFICA_AMMINISTRATIVA' 
				)
	BEGIN
		--prima di crearlo controllo se esiste doc escludi_lotti inlavorazione
		set @Errore='Operazione non consentita:presente documento escludi lotti inlavorazione'
		if not exists (select * from ctl_doc where tipodoc='ESCLUDI_LOTTI' and statofunzionale='InLavorazione' and IdDoc=@IdPDA and linkeddoc=@IdOff and deleted=0)
		begin
		
			set  @Errore=''

			--controllo che non ho escluso tutti i lotti
			set @Errore='Operazione non consentita:sono stati esclusi tutti i lotti'
			if @EsclusioneLotti <>'ko'
			begin
		
				set @Errore=''

				--recupero ultimo doc ESITO_AMMESSA inlavorazione/Confermato legato all'offerta e se esiste lo riapro
				set @Id=-1
				select @Id=id from ctl_doc where tipodoc='ESITO_AMMESSA_CON_RISERVA' and IdDoc=@IdOff and linkeddoc=@idRow and StatoFunzionale in ('InLavorazione','Confermato') and deleted=1 
	
				if @Id = '-1' 
				begin
		
					--recupero info offerta da settare sul doc offerta_partecipanti
					select @ProtocolloOfferta=Protocollo,@IdAziPartecipante=azienda,
							@Fascicolo=Fascicolo
						from ctl_doc where id=@IdOff

					--recupero azienda utente collegato
					select @IdAziMittente=pfuidazi from profiliutente where idpfu=@IdUser

					insert into CTL_DOC 
						( IdPfu, TipoDoc, Body ,Azienda, IdDoc,
						ProtocolloRiferimento, Fascicolo, LinkedDoc, StatoFunzionale, StatoDoc, Deleted, Destinatario_Azi ) 
					values 
						( @IdUser, 'ESITO_AMMESSA_CON_RISERVA', dbo.getLottiSenzaCampioni(@idRow), @IdAziMittente , @IdOff,
						@ProtocolloOfferta, @Fascicolo, @idRow , 'InLavorazione', 'Saved',1,@IdAziPartecipante )   

					set @Id=@@IDENTITY


				end

			end	

		end
	END
	if @Errore=''

		-- rirorna l'id del documento
		select @Id as id
	
	else

	begin
		-- rirorna l'errore
		select 'ERRORE' as id , @Errore as Errore
	end
	
	
END










GO
