USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CK_LIB_SERVICES_CTLMAILSYSTEM_RUN]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[OLD_CK_LIB_SERVICES_CTLMAILSYSTEM_RUN] 
as
begin

	SET NOCOUNT  ON

	declare @ret as nvarchar(max)
	
	declare @id_s int
	set @id_s = 0

	set @ret=''
	
	select 
			top 1 @id_s= id 
		from CTL_Mail_System with(nolock)
			left outer join CTL_Relations with(nolock) on REL_Type = 'MAIL_PRIORITA_INVIO' and REL_ValueInput = TypeDoc
		where inout='out' 		
	   		  and (		(status='error' and numretry <  dbo.PARAMETRI('CTL_Mail_System' , 'SendMail' , 'NumRetry', '9', -1) ) 
						or	(status='notsent')
					)
				and mailobj is not null
	ORDER BY cast( isnull( REL_ValueOutput , '0' ) as int )  desc , id asc

	--SE CI SONO MAIL IN CODA NEL SERVIZIO 
	IF @id_s > 0
	BEGIN
		--SE TROVO LO STESSO ID DA INVIARE DEL PASSAGGIO PRECEDENTE CI STA IL PROBLEMA
		IF EXISTS ( select ID from CTL_Counters where name='SRV_CTLMAILSYSTEM_RUN' and Counter=@id_s )
		BEGIN
			set @ret='La coda delle EMAIL non sembra smaltirsi, collegarsi e verificare la situazione sul cliente'
		END
		ELSE
		BEGIN
			--CANCELLO LA PRECEDENTE SENTINELLA
			delete CTL_Counters where name='SRV_CTLMAILSYSTEM_RUN'
			--INSERISCE LA SENTINELLA
			insert into CTL_Counters (Name,Counter) values ('SRV_CTLMAILSYSTEM_RUN',@id_s)
				
		END
	END
	

	if @ret='' -- se non ci sono problemi verifico che la ricezione delle mail stia funzionando ma solo sugli ambienti di produzione
	begin
		if exists( select DZT_Name from LIB_Dictionary where dzt_name = 'SYS_AFUPDATE_AMBIENTE' and  dzt_valuedef = 'produzione' )
		and --le produzioni di Afsoluzioni che sono lo scaffale
		not exists ( select DZT_Name from LIB_Dictionary where dzt_name = 'SYS_AFUPDATE_CLIENTE' and dzt_valuedef='35219606')
		begin
			DECLARE @MailData DATETIME
			DECLARE @MailData_out DATETIME
			set @MailData_out = NULL
			select Top 1  @MailData_out=DataSent FROM CTL_Mail_System with(nolock) 	WHERE inout='out' and DataSent is not null ORDER BY ID DESC
			--QUALCHE CLIENTE NON POTREBBE AVERE VALORIZZATA DATASENT
			if @MailData_out is null
			BEGIN
				select Top 1  @MailData_out=MailData FROM CTL_Mail_System with(nolock) 	WHERE inout='out' and Status in ('Sent','Read','Delivered') ORDER BY ID DESC
			END

			select Top 1 @MailData = MailData FROM CTL_Mail_System with(nolock) WHERE inout='IN'  ORDER BY ID DESC

			--faccio il controllo solo se l'ultima mail in uscita è stata inviata da oltre 24H questo per evitare alert da portali che non inviano mail
			IF DATEDIFF( MINUTE	 , getdate() , @MailData_out ) > -1440 
			begin
				IF DATEDIFF( MINUTE	 , @MailData , @MailData_out ) > 1440 
					set @ret='La coda delle EMAIL non riceve nuove mail in ingresso da un giorno, collegarsi e verificare la situazione di PIETRO sul cliente'
			end
		end	
	end
	

	
	select @ret as sentinella 
end
GO
