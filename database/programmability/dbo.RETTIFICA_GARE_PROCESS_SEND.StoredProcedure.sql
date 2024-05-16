USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[RETTIFICA_GARE_PROCESS_SEND]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RETTIFICA_GARE_PROCESS_SEND] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
SET NOCOUNT ON

declare @idmsg INT
declare @inviti as varchar(10)
declare @idazi INT
declare @motivaz_rettifica as Nvarchar(4000)
declare @isubtype as varchar(10)
declare @OLD_DataTermineQuesiti as varchar(19)
declare @Old_DataPresentazioneRisposte as varchar(19)
declare @Old_DataSeduta as varchar(19)
declare @DataTermineQuesiti as varchar(19)
declare @DataPresentazioneRisposte as varchar(19)
declare @DataSeduta as varchar(19)




--recupero azienda del mittente
select @idazi=pfuidazi from profiliUtente where idpfu=@IdUser and pfudeleted=0

---recupero idmsg della gara 
select @idmsg=LinkedDoc from ctl_doc where id=@idDoc

---sentinella per capire se la gara prevede invitati
select @inviti= case when isubType = '68' then 'si'
					 when isubType = '48' then 'si' 
					 when isubType = '167' and TipoBando='3' then 'si' 
				else 'no' end ,@isubtype=isubType
from tab_messaggi_fields where idmsg=@idmsg


---Recupero la descrizione da anteporre alla descrizione in base al subtype
--set @motivaz_rettifica = dbo.CNV('RETTIFICA_GARA_MSG_' + @isubtype, 'I' )

set @motivaz_rettifica = ''

--recupero la motivazione messa sulla proroga
select @motivaz_rettifica=@motivaz_rettifica + '
' + cast(Note as varchar(4000)) from ctl_doc where id=@idDoc

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
IF @isubtype = '167'
BEGIN
	set @motivaz_rettifica= replace(@motivaz_rettifica,'<OLD_DataTermineQuesiti>', convert(varchar(10),cast(@OLD_DataTermineQuesiti as datetime),103) + ' ' + convert(varchar(8),cast(@OLD_DataTermineQuesiti as datetime),108))
	set @motivaz_rettifica= replace(@motivaz_rettifica,'<DataTermineQuesiti>', convert(varchar(10),cast(@DataTermineQuesiti as datetime),103) + ' ' + convert(varchar(8),cast(@DataTermineQuesiti as datetime),108))
END
	set @motivaz_rettifica= replace(@motivaz_rettifica,'<Old_DataPresentazioneRisposte>', convert(varchar(10),cast(@Old_DataPresentazioneRisposte as datetime),103) + ' ' + convert(varchar(8),cast(@Old_DataPresentazioneRisposte as datetime),108))
	set @motivaz_rettifica= replace(@motivaz_rettifica,'<DataPresentazioneRisposte>', convert(varchar(10),cast(@DataPresentazioneRisposte as datetime),103) + ' ' + convert(varchar(8),cast(@DataPresentazioneRisposte as datetime),108))
	set @motivaz_rettifica= replace(@motivaz_rettifica,'<Old_DataSeduta>', convert(varchar(10),cast(@Old_DataSeduta as datetime),103) + ' ' + convert(varchar(8),cast(@Old_DataSeduta as datetime),108))
	set @motivaz_rettifica= replace(@motivaz_rettifica,'<DataSeduta>', convert(varchar(10),cast(@DataSeduta as datetime),103) + ' ' + convert(varchar(8),cast(@DataSeduta as datetime),108))
	
--se prevede gli inviti allora creo le comunicazioni per gli invitati

		IF @inviti = 'si' 
		BEGIN
			Insert into CTL_DOC (IdPfu,TipoDoc,StatoDoc,Data,Titolo,Body,
								 Azienda,ProtocolloRiferimento,Fascicolo,Note,LinkedDoc,JumpCheck,Destinatario_Azi,idPfuInCharge)
										
				select	t2.iddestinatario,'PDA_COMUNICAZIONE_GARA','Saved',getdate(),
						 'Comunicazione Rettifica gara Num. ' + t1.ProtocolloBando,t1.Object_Cover1,
						 @idazi,t1.ProtocolloBando,t1.ProtocolBG,@motivaz_rettifica,@idDoc,'0-RETTIFICA_GARA',pfuidazi,t2.iddestinatario
					from tab_messaggi_fields t1
						inner join document d1 on d1.dcmdeleted=0 and d1.dcmisubtype=t1.iSubType
						left join document d2 on d2.dcmdeleted=0 and d1.dcmRelatedIdDcm=d2.idDcm
						inner join tab_messaggi_fields t2 on t1.IdDoc=t2.IdDoc and t2.iSubType=d2.dcmisubtype
						inner join profiliUtente on t2.iddestinatario=idpfu and pfudeleted=0
					where t1.idmsg=@idmsg and d2.dcmisubtype=t2.iSubType
				
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
