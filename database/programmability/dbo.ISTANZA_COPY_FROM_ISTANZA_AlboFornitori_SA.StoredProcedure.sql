USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ISTANZA_COPY_FROM_ISTANZA_AlboFornitori_SA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[ISTANZA_COPY_FROM_ISTANZA_AlboFornitori_SA]( @idDoc as int , @oldIdDoc as int, @idpfu as int ) 
as
--@idDoc nuovo id
--@oldIdDoc id istanza precedente
--@idpfu -20 fisso per adesso
--riceve l'id della nuova istanza creata, il linkeddoc è il bando, prevdoc istanza precedente

declare @IdAzi int

declare @Valore nvarchar (4000)
declare @RagSoc		nvarchar( 500)
declare @NaGi nvarchar( 500)
declare @INDIRIZZOLEG nvarchar( 500)
declare @LOCALITALEG nvarchar( 500)
declare @CAPLEG nvarchar( 500)
declare @PROVINCIALEG nvarchar( 500)
declare @NUMTEL nvarchar( 500)
declare @NUMTEL2 nvarchar( 500)
declare @NUMFAX nvarchar( 500)
declare @EMail nvarchar( 500)
declare @PIVA nvarchar( 500)
declare @NomeRapLeg varchar(500)
declare @CognomeRapLeg varchar(500)
declare @CFRapLeg varchar(500)
declare @TelefonoRapLeg varchar(500)
declare @CellulareRapLeg varchar(500)
declare @EmailRapLeg varchar(500)
declare @RuoloRapLeg varchar(500)

--recupero azienda associata all'istanza
Select @IdAzi=azienda from CTL_DOC where id=@idDoc
--recupero tutti i valori
Select 	 @RagSoc=aziRagioneSociale 
		,@NaGi=aziIdDscFormasoc 
		,@INDIRIZZOLEG=aziIndirizzoLeg
		,@LOCALITALEG=aziLocalitaLeg 
		,@CAPLEG=aziCAPLeg
		,@PROVINCIALEG=aziProvinciaLeg
		,@NUMTEL=aziTelefono1
		,@NUMTEL2=aziTelefono2 
		,@NUMFAX=aziFAX
		,@EMail=aziE_Mail
		,@PIVA=aziPartitaIVA 
from Aziende where idazi = @IdAzi


---SE NON HO RECUPERATO CLASSI ISCRIZIONE DA DM_ATTRIBUTI PROVO A PRENDERLE DAL PREV DOC
IF NOT EXISTS ( select * from CTL_DOC_Value where IdHeader=@idDoc and DSE_ID='DISPLAY_CLASSI' and DZT_Name='ClasseIscriz' and ISNULL(value,'')<>'' )
BEGIN
	declare @previst as int
	set @previst=0
	select @previst=prevdoc from ctl_doc where id=@idDoc
	if @previst > 0
	BEGIN
		update CTL_DOC_Value set value=(Select value from CTL_DOC_Value where IdHeader=@previst and DSE_ID='DISPLAY_CLASSI' and DZT_Name='ClasseIscriz' )
			where IdHeader=@idDoc and DSE_ID='DISPLAY_CLASSI' and DZT_Name='ClasseIscriz' 
	END
END

---RIMUOVO LE CLASSIISCRIZ NON PRESENTI NEL DOMINIO 
DECLARE @classi_ok as varchar(MAX)
set @classi_ok='###'

select @classi_ok=@classi_ok + items + '###' 
		from dbo.Split((select value from CTL_DOC_Value where IdHeader=@idDoc and DSE_ID='DISPLAY_CLASSI' and DZT_Name='ClasseIscriz'),'###')
			inner join ClasseIscriz on DMV_Cod=items and dmv_deleted=0

--update CTL_DOC_Value set value=@classi_ok
--	 where IdHeader=@idDoc and DSE_ID='DISPLAY_CLASSI' and DZT_Name='ClasseIscriz' 

update CTL_DOC_Value set value= [dbo].[GetClasseIscrizFoglie] (@classi_ok)
			where IdHeader=@idDoc and DSE_ID='DISPLAY_CLASSI' and DZT_Name='ClasseIscriz'

---RIMUOVO LE CLASSIISCRIZ NON PRESENTI SUL BANDO


declare @classi_OK_PATH as nvarchar(max)

set @classi_OK_PATH=dbo.RIPULISCE_CLASSIISCRIZ_NON_BUONE_BANDO ( @idDoc , @classi_ok )

--NELLA TEMP CI SONO I CODICI DELLE CLASSI CHE NON POSSO AVERE SULL'ISTANZA
	select distinct DMV_Cod into #temp
		from dbo.Split(@classi_OK_PATH,'###')
	inner join ClasseIscriz on DMV_Father=items

	set @classi_ok='###'

	select 
		@classi_ok=@classi_ok + DMV_Cod + '###' 
	from #temp

	update CTL_DOC_Value set value=@classi_ok
		where IdHeader=@idDoc and DSE_ID='DISPLAY_CLASSI' and DZT_Name='ClasseIscriz' 

	 drop table #temp	

---FINE RIMUOVO LE CLASSIISCRIZ NON PRESENTI SUL BANDO
update CV 
	set value=DB.ClasseIscriz
from CTL_DOC_Value CV with(NOLOCK)
	inner join ctl_doc I  with(NOLOCK) on CV.IdHeader=I.id 
	inner join Document_Bando DB with(NOLOCK) on DB.idHeader=I.LinkedDoc
where CV.IdHeader=@idDoc and CV.DSE_ID='DISPLAY_CLASSI' and CV.DZT_Name='ClasseIscriz_Bando' 
GO
