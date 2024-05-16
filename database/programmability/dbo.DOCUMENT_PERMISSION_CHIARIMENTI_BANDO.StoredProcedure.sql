USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_PERMISSION_CHIARIMENTI_BANDO]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



------------------------------------------------------------------
-- ***** stored generica che controlla l'accessibilita ai documenti nuovi ****
-- *****          Applica le seguente regole  *******
-- Ti permetto l'apertura del documento : 
--	1) Se idpfu coincide con utente che ha compilato il bando 
--   2) Se idpfu è il RUP, utente nei riferimenti come quesiti.
--   3) Se idpfu ha ilprofilo amministratore
--   4) Se idpfu ha la relazione UTENTE_SUPERUSER-DOSSIER

------------------------------------------------------------------
--Versione=1&data=2017-09-27&Attivita=166378&Nominativo=Enrico
CREATE proc [dbo].[DOCUMENT_PERMISSION_CHIARIMENTI_BANDO]
( 
	@idPfu   as int  , 
	@idDoc as varchar(50) ,
	@param as varchar(250)  = NULL  
)
as
begin

    declare @owner int
    declare @passed int -- variabile di controllo
	
    set @owner = -1
    set @passed = 0 -- non passato

    if upper( substring( @idDoc, 1, 3 ) ) = 'NEW' and @param is null 
    begin
	   select 1 as bP_Read , 1 as bP_Write
    end
    else
    begin
	
	   
	   --se non viene dalla parte pubblica
	   if @idPfu>0
	   begin
		  
		  --se l'utente la la relazione UTENTE_SUPERUSER-DOSSIER
		  if exists(select * from CTL_Relations with(nolock)  where rel_type='UTENTE_SUPERUSER' and rel_valueinput='DOSSIER' and REL_ValueOutput=@idPfu)
		  begin
			 set @passed = 1
		  end
			 	
		  -- Se l'utente ha il profilo Amministratore (che può valutare) 
		  if  @passed = 0
		  begin
			 if exists (select * from profiliutenteattrib with(nolock)  where dztnome='profilo' and attvalue='Amministratore' and idpfu=@idPfu)
			 begin
				    set @passed = 1 --passato
			 end 
		  end

		  -- Se l'utente ha copilato il bando
		  if  @passed = 0
		  begin
	 
			 select 
				@owner = isnull(idpfu,-20) 
			 from 
				ctl_doc with(nolock) 
			 where id = @idDoc
				
				
			 --Se il tuo idpfu coincide con l'owner del documento ( ctl_doc.idpfu ) 
			 if @idPfu = @owner 
			 begin
			    set @passed = 1 --passato
			 end 

		 end
		  
		  --se l'utente è tra i riferimenti del bando
		  if  @passed = 0
		  begin
			 if exists ( select * from Document_Bando_Riferimenti with (nolock) where idheader=@idDoc and RuoloRiferimenti = 'Quesiti' and idpfu=@idPfu)
				set @passed = 1 --passato
		  end
		  
		  --se l'utente è il RUP USERRUP
		  if  @passed = 0
		  begin
			 if exists ( select * from ctl_doc_value with (nolock) where idheader=@idDoc and dzt_name = 'UserRup' and dse_id = 'InfoTec_comune' and value=cast(@idPfu as varchar(100)))
				set @passed = 1 --passato
		  end
		  	 	
		  -- output
		  if @passed = 1
				select 1 as bP_Read , 1 as bP_Write
		  else
				select 0 as bP_Read , 0 as bP_Write from profiliutente where idpfu = -100

	   end
			
	 
	end

end



GO
