USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_MODULO_TEMPLATE_REQUEST_CREATE_FROM_MANIFESTAZIONE_INTERESSE]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[OLD_MODULO_TEMPLATE_REQUEST_CREATE_FROM_MANIFESTAZIONE_INTERESSE] 
	( @idDoc int , @IdUser int  )
AS
--Versione=1&data=2016-10-21&Attivita=126293&Nominativo=Sabato
BEGIN
	SET NOCOUNT ON;
	
	
	declare @IdBando as int
	declare @StatoFunzionale	as varchar(100)
	declare @Id					as INT
	declare @Errore				as nvarchar(max)

	set @IdBando=0
	set @Errore = ''
	set @Id = 0

	--recupero id bando 
	select @IdBando = linkeddoc, @StatoFunzionale=StatoFunzionale from ctl_doc with(nolock) where Id=@idDoc

	--se offerta è in lavorazione e la data scadenza superata allora provo a recuperare il dgue se esiste ma non posso crearlo
	if @StatoFunzionale = 'InLavorazione' and exists (select idHeader from Document_Bando with(nolock) where idHeader=@IdBando and GETDATE() >= DataScadenzaOfferta )
	begin
		
		--recupero DGUE
		select @Id = Id from ctl_doc with(nolock) where deleted = 0 and TipoDoc = 'MODULO_TEMPLATE_REQUEST' and linkeddoc = @idDoc

		if isnull( @Id , 0 ) = 0
			set @Errore='Documento non presente'

		if @Errore=''
			--ritorna id del dgue
			select @Id as id,'' as Errore
		else
			-- rirorna l'errore
			select 'Errore' as id , @Errore as Errore

	end
	else
	begin
		
		select top 0 
			cast( '' as varchar(250)) as id , 
			cast( '' as varchar(max)) as Errore
			into #Result

		insert into #Result exec MODULO_TEMPLATE_REQUEST_CREATE_FOR @IdDoc , @idUser , 'DGUE_MANDATARIA'
	

		select * from #Result
	end



END

GO
