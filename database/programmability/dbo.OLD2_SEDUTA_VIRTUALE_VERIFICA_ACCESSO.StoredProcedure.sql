USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_SEDUTA_VIRTUALE_VERIFICA_ACCESSO]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE proc [dbo].[OLD2_SEDUTA_VIRTUALE_VERIFICA_ACCESSO]( 
	@idPfu   as int  , 
	@idDoc as varchar(50) 
	)
as
begin

	set nocount on
	declare @idAzi			int
    declare @IdAziMaster as int
	declare @AziFrom		varchar(100)
	declare @StatoSeduta		varchar(20)
	declare @visibilita		varchar(200)
	declare @Divisione_lotti   as char(1)
	declare @Esito as bit

	set @Esito = 0

	--Il documento è accessibile in funzione dei parametri: Invitati / Partecipanti attraverso la stored di controllo oltre che allo stato della seduta "Aperta"
	select @IdAziMaster=mpidazimaster from marketplace
	
	select @idAzi = pfuIdAzi  from profiliutente with(nolock)	where idPfu = @idPfu
	
	select  @StatoSeduta = b.StatoSeduta,
			@Divisione_lotti=Divisione_lotti 
		from ctl_doc sv 
			inner join Document_Bando b on sv.id = b.idHeader 
	where id=@idDoc

	SELECT @visibilita = [Visibilita] FROM [dbo].[Document_Parametri_Sedute_Virtuali] where deleted=0
	if @StatoSeduta = 'Aperta'
	begin
		--DIVISIONE LOTTI SE L'Azienda dell'utente figura tra i partecipanti
		IF @Divisione_lotti = 3
		begin
			IF EXISTS ( select  * 
							from ctl_doc C2 WITH(NOLOCK)							 
							  inner join  CTL_DOC_Destinatari CD WITH(NOLOCK) on CD.idHeader=c2.Id  and CD.IdAzi=@idAzi--CHI HA FATTO PARTECIPA
							 -- inner join  ctl_doc O WITH(NOLOCK) on O.TipoDoc='OFFERTA' and O.LinkedDoc=c2.id and O.StatoFunzionale='Inviato' and O.Deleted=0 and O.Azienda=CD.IdAzi --OFFERTE INVIATE FATTE DA CHI HA PARTECIPATo
							where C2.id=@idDoc --BANDO_GARA 
						)
				BEGIN
					set @Esito = 1
				END
		end
		else
		begin	
			IF EXISTS ( select  * 
							from ctl_doc C2 WITH(NOLOCK)							 
							  inner join  CTL_DOC_Destinatari CD WITH(NOLOCK) on CD.idHeader=c2.Id  and CD.IdAzi=@idAzi--CHI HA FATTO PARTECIPA
							  inner join  ctl_doc O WITH(NOLOCK) on O.TipoDoc in ( 'OFFERTA' , 'RISPOSTA_CONCORSO') and O.LinkedDoc=c2.id and O.StatoFunzionale='Inviato' and O.Deleted=0 and O.Azienda=CD.IdAzi --OFFERTE INVIATE FATTE DA CHI HA PARTECIPATo
							where C2.id=@idDoc --BANDO_GARA 
						) 
				BEGIN
					set @Esito = 1
				END
		end

		if @visibilita='invitati' 
		begin
			set @Esito = 1
		end
	end

	if @Esito=1
	begin
		select  top 1 1 as bP_Read , 1 as bP_Write
	end
	else
		select  top 0 1 as bP_Read , 1 as bP_Write
end




GO
