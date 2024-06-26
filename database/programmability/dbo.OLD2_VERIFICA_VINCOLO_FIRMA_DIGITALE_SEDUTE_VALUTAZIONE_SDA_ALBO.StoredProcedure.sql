USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_VERIFICA_VINCOLO_FIRMA_DIGITALE_SEDUTE_VALUTAZIONE_SDA_ALBO]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[OLD2_VERIFICA_VINCOLO_FIRMA_DIGITALE_SEDUTE_VALUTAZIONE_SDA_ALBO]  ( @id as int , @idPfu int  , @blocco as int output )
AS
BEGIN 
 	set nocount on	
	declare @flusso as varchar(500)
	declare @idSda as int
	declare @Attiva_Vincolo as varchar(10)
	set @blocco=0

	select @flusso=
			case 
				when Bando.TipoDoc='BANDO_SDA' then 'SDA'
				when ( ISNULL(Bando.JumpCheck,'ME')='ME' or Bando.JumpCheck = '' ) and  ( Bando.TipoDoc='BANDO' ) then 'ALBO'
				when Bando.JumpCheck = 'BANDO_ALBO_FORNITORI' then 'ALBO_FORN'
				when Bando.JumpCheck = 'BANDO_ALBO_LAVORI' then 'ALBO_LAVORI'
				when Bando.JumpCheck = 'BANDO_ALBO_PROFESSIONISTI' then 'ALBO_PROF'
			end , @idSda = bando.id
		from ctl_doc documento with(nolock)
			inner join ctl_doc istanza with(nolock) on istanza.id=documento.linkeddoc
			inner join ctl_doc Bando with(nolock) on bando.id=istanza.linkeddoc
		where documento.id=@id


if @flusso ='SDA'
begin
	

	select @Attiva_Vincolo = ISNULL(Attiva_vincolo_firma_digitale_sedute_valutazione ,'si')
		from Document_Parametri_Abilitazioni with(nolock) 
		where deleted=0 and @flusso=TipoDoc and idheader = @idSda
end
else
begin
	select @Attiva_Vincolo = ISNULL(Attiva_vincolo_firma_digitale_sedute_valutazione ,'si')
		from Document_Parametri_Abilitazioni with(nolock) 
		where deleted=0 and @flusso=TipoDoc
end

IF   @Attiva_Vincolo = 'no' 
BEGIN
	--select top 0 * from ctl_doc
	set @blocco = 0
END
ELSE
begin		
	--VALORE si, NON CONSENTE INVIO senza allegare il file firmato.
	--IF EXISTS ( select * from Document_Parametri_Abilitazioni with(nolock) 
	--where deleted=0 and @flusso=TipoDoc and ISNULL(Attiva_vincolo_firma_digitale_sedute_valutazione ,'si')='si' )
	--BEGIN
		select @blocco=1
			from CTL_DOC C1 with(NOLOCK) --CONFERMA
				inner join ctl_doc C2 with(NOLOCK) on C2.Id=C1.LinkedDoc and ISNULL(c2.jumpcheck,'')='' --ISTANZA
			where C1.ID  =@id and isnull(C1.SIGN_ATTACH,'') = '' 
	--END
end
	
END
GO
