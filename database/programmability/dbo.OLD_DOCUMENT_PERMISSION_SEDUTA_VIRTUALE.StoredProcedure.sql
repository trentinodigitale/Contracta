USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DOCUMENT_PERMISSION_SEDUTA_VIRTUALE]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[OLD_DOCUMENT_PERMISSION_SEDUTA_VIRTUALE]( 
	@idPfu   as int  , 
	@idDoc as varchar(50) ,
	@param as varchar(250)  = NULL     )
as
begin
	

	declare @idAzi			int
    declare @IdAziMaster as int
	declare @AziFrom		varchar(100)
	declare @StatoSeduta		varchar(20)
	declare @Divisione_lotti   as char(1)
	declare @Esito as bit
	declare @visibilita		varchar(200)

	set @Esito = 0

	--Il documento è accessibile in funzione dei parametri: Invitati / Partecipanti attraverso la stored di controllo oltre che allo stato della seduta "Aperta"
	select @IdAziMaster=mpidazimaster from marketplace
	
	select @idAzi = pfuIdAzi  from profiliutente with(nolock)	where idPfu = @idPfu
	
	select  @StatoSeduta = b.StatoSeduta,
			@Divisione_lotti=Divisione_lotti 
		from ctl_doc sv 
			inner join Document_Bando b on sv.LinkedDoc = b.idHeader 
	where id=@idDoc

	SELECT @visibilita = [Visibilita] FROM [dbo].[Document_Parametri_Sedute_Virtuali] where deleted=0
	if @StatoSeduta = 'Aperta'
	begin
		--DIVISIONE LOTTI SE L'Azienda dell'utente figura tra i partecipanti
		IF @Divisione_lotti = 3
		begin
			IF EXISTS ( select  * 
							from ctl_doc C WITH(NOLOCK)
							  inner join  ctl_doc C2 WITH(NOLOCK) on c2.id=C.LinkedDoc --BANDO_GARA
							  inner join  CTL_DOC_Destinatari CD WITH(NOLOCK) on CD.idHeader=c2.Id  and CD.IdAzi=@idAzi--CHI HA FATTO PARTECIPA
							 -- inner join  ctl_doc O WITH(NOLOCK) on O.TipoDoc='OFFERTA' and O.LinkedDoc=c2.id and O.StatoFunzionale='Inviato' and O.Deleted=0 and O.Azienda=CD.IdAzi --OFFERTE INVIATE FATTE DA CHI HA PARTECIPATo
							where C.id=@idDoc --SEDUTA 
						)
				BEGIN
					set @Esito = 1
				END
		end
		else
		begin	
			IF EXISTS ( select  * 
							from ctl_doc C WITH(NOLOCK)
							  inner join  ctl_doc C2 WITH(NOLOCK) on c2.id=C.LinkedDoc --BANDO_GARA
							  inner join  CTL_DOC_Destinatari CD WITH(NOLOCK) on CD.idHeader=c2.Id  and CD.IdAzi=@idAzi--CHI HA FATTO PARTECIPA
							  inner join  ctl_doc O WITH(NOLOCK) on O.TipoDoc in ('OFFERTA','RISPOSTA_CONCORSO') and O.LinkedDoc=c2.id and O.StatoFunzionale in('Inviato','Rettificata') and O.Deleted=0 and O.Azienda=CD.IdAzi --OFFERTE INVIATE FATTE DA CHI HA PARTECIPATo
							where C.id=@idDoc --SEDUTA 
						) 
				BEGIN
					set @Esito = 1
				END
		end
		
	end

	if @visibilita='invitati' 
	begin
		set @Esito = 1
	end

	if @Esito=1
	begin
		select  top 1 1 as bP_Read , 1 as bP_Write
	end
	else
	begin		
		select top 0 0 as bP_Read , 0 as bP_Write
	end
end



GO
