USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PROROGA_BANDO_GARA_PROCESS_SEND]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[PROROGA_BANDO_GARA_PROCESS_SEND] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
SET NOCOUNT ON

declare @idmsg INT
declare @inviti as varchar(10)
declare @idazi INT
declare @motivaz_proroga as Nvarchar(4000)
declare @isubtype as varchar(10)
declare @OLD_DataTermineQuesiti as varchar(19)
declare @Old_DataPresentazioneRisposte as varchar(19)
declare @Old_DataSeduta as varchar(19)
declare @DataTermineQuesiti as varchar(19)
declare @DataPresentazioneRisposte as varchar(19)
declare @DataSeduta as varchar(19)
declare @RichiestaQuesito as char(1)



--recupero azienda del mittente
select @idazi=pfuidazi from profiliUtente where idpfu=@IdUser and pfudeleted=0

---recupero idmsg della gara 
select @idmsg=LinkedDoc from ctl_doc where id=@idDoc

---sentinella per capire se la gara prevede invitati
select @inviti= case when TipoBandoGara =  '3' then 'si' 
				else 'no' end ,@RichiestaQuesito=RichiestaQuesito
from document_bando  where idheader=@idmsg


---Recupero la descrizione da anteporre alla descrizione
--set @motivaz_proroga = dbo.CNV('PROROGA_GARA_MSG_BANDO_GARA', 'I' )
set @motivaz_proroga = ''
--recupero la motivazione messa sulla proroga
select @motivaz_proroga=@motivaz_proroga + '
' + Value from ctl_doc_Value where idHeader=@idDoc and DSE_ID='TESTATA' and Dzt_Name='Body'

--recupero le date da sostituire
select @OLD_DataTermineQuesiti=Value 
	from CTl_DOC_VALUE 
		where idheader=@idDoc and DSE_ID='TESTATA'
			 and DZT_Name='OLD_DataTermineQuesiti'
select @Old_DataPresentazioneRisposte=Value 
	from CTl_DOC_VALUE 
		where idheader=@idDoc and DSE_ID='TESTATA'
			 and DZT_Name='Old_DataPresentazioneRisposte'
select @Old_DataSeduta=Value 
	from CTl_DOC_VALUE 
		where idheader=@idDoc and DSE_ID='TESTATA'
			 and DZT_Name='Old_DataSeduta'
select @DataTermineQuesiti=Value 
	from CTl_DOC_VALUE 
		where idheader=@idDoc and DSE_ID='TESTATA'
			 and DZT_Name='DataTermineQuesiti'
select @DataPresentazioneRisposte=Value 
	from CTl_DOC_VALUE 
		where idheader=@idDoc and DSE_ID='TESTATA'
			 and DZT_Name='DataPresentazioneRisposte'
select @DataSeduta=Value 
	from CTl_DOC_VALUE 
		where idheader=@idDoc and DSE_ID='TESTATA'
			 and DZT_Name='DataSeduta'			 			 			 						 

--faccio le replace al template 
IF @RichiestaQuesito = '1'
BEGIN
	set @motivaz_proroga= replace(@motivaz_proroga,'<OLD_DataTermineQuesiti>', convert(varchar(10),cast(@OLD_DataTermineQuesiti as datetime),103) + ' ' + convert(varchar(8),cast(@OLD_DataTermineQuesiti as datetime),108))
	set @motivaz_proroga= replace(@motivaz_proroga,'<DataTermineQuesiti>', convert(varchar(10),cast(@DataTermineQuesiti as datetime),103) + ' ' + convert(varchar(8),cast(@DataTermineQuesiti as datetime),108))
END
	set @motivaz_proroga= replace(@motivaz_proroga,'<Old_DataPresentazioneRisposte>', convert(varchar(10),cast(@Old_DataPresentazioneRisposte as datetime),103) + ' ' + convert(varchar(8),cast(@Old_DataPresentazioneRisposte as datetime),108))
	set @motivaz_proroga= replace(@motivaz_proroga,'<DataPresentazioneRisposte>', convert(varchar(10),cast(@DataPresentazioneRisposte as datetime),103) + ' ' + convert(varchar(8),cast(@DataPresentazioneRisposte as datetime),108))
	set @motivaz_proroga= replace(@motivaz_proroga,'<Old_DataSeduta>', convert(varchar(10),cast(@Old_DataSeduta as datetime),103) + ' ' + convert(varchar(8),cast(@Old_DataSeduta as datetime),108))
	set @motivaz_proroga= replace(@motivaz_proroga,'<DataSeduta>', convert(varchar(10),cast(@DataSeduta as datetime),103) + ' ' + convert(varchar(8),cast(@DataSeduta as datetime),108))
	

	
	
	CREATE TABLE #TempDest  ( IdAzi  int ) ; 

	--ESEGUE LA STORED CHE RECUPERA EVENTUALI DESTINATARI
	insert into #TempDest
		exec DESTINATARI_NOTIFICHE_PROCEDURE  @idDoc 

	--se prevede trova record nella tempdest crea le comunicazioni
	--IF @inviti = 'si' 
	IF EXISTS ( Select idazi from #TempDest)
	BEGIN
			
			Insert into CTL_DOC (IdPfu,TipoDoc,StatoDoc,Data,Titolo,Body,
							 Azienda,ProtocolloRiferimento,Fascicolo,Note,LinkedDoc,JumpCheck,Destinatario_Azi,idPfuInCharge)
				
				 select	@IdUser,'PDA_COMUNICAZIONE_GARA','Saved',getdate(),
						 'Comunicazione Proroga gara Num. ' + c.Protocollo,c.Body,
						 @idazi,c.Protocollo,c.Fascicolo,@motivaz_proroga,@idDoc,'0-PROROGA_BANDO_GARA',d.IdAzi,@IdUser
					from Ctl_doc c
						inner join document_bando b on b.idheader=c.id
						--inner join ctl_doc_destinatari d on d.idheader=c.id and d.seleziona='includi'
						--inner join profiliUtente p on p.pfuidazi=d.idazi and p.pfudeleted=0
						--INNER JOIN ProfiliUtenteAttrib a on a.idpfu = p.idpfu and a.dztNome = 'Profilo' and a.attValue = 'ProcuratoreOE'
						cross join #TempDest d
					where c.id = @idmsg

				
			--inserisco sulle singole comunicazioni gli allegati messi sulla proroga se presenti
			IF EXISTS (select * from CTL_DOC_ALLEGATI  where idHeader=@idDoc)
			BEGIN
				Insert into CTL_DOC_ALLEGATI (idHeader,Descrizione,Allegato)
					Select id,Descrizione,Allegato
						from CTL_DOC_ALLEGATI
							inner join CTL_DOC on LinkedDoc=@idDoc and Tipodoc='PDA_COMUNICAZIONE_GARA'
						where idHeader=@idDoc
			END
				
			--inserisco il dirigente su tutte le comunicazioni
			insert into ctl_doc_value
				select id,'DIRIGENTE',0,'UserDirigente',@IdUser 
					from ctl_doc where LinkedDoc=@idDoc
						and  TipoDoc='PDA_COMUNICAZIONE_GARA'
		
		END


SET NOCOUNT OFF
END




GO
