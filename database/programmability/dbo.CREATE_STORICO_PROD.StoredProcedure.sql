USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CREATE_STORICO_PROD]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[CREATE_STORICO_PROD]( @id int,@idPfu INT )
as
begin
	
	

	declare @idDoc INT	
	declare @idr INT
	declare @DOC varchar(100)
	declare @codifica varchar(200)
	declare @ambito varchar(100)
	--declare @prevDoc int
	
	declare @DataTracciaBase as datetime
	declare @Id_Doc_Genera_Prodotto as int
	declare @Codice_regionale as nvarchar(100)
	declare @newId as int
	
	declare @modelloChiave varchar(1000)
	declare @modelloOpt varchar(1000)
	declare @modelloObblig varchar(1000)

	set @ambito = ''

	SET NOCOUNT ON
	
	

	
		
	   --se non esiste lo storico
	   --creo il documento CODIFICA_PROD_DOC che rappresenta la traccia base del prodotto
	   if not exists ( select * from view_microlotti_dettagli_storico_cod_prodotto  where idProdotto = @id )
	   BEGIN
		  
		  --recupero documento che ha generato il prodotto
		  set @Id_Doc_Genera_Prodotto=-1

		  select @Id_Doc_Genera_Prodotto = idheader,@Codice_regionale= CODICE_REGIONALE,  @ambito = Posizione 
			 from Document_MicroLotti_Dettagli d with(nolock)  
			 where d.id=@id
			

		  --se non esiste il documento che ha generato il prodotto recupero il primo LISTINO_CONVENZIONE che lo contiene
		  if @Id_Doc_Genera_Prodotto = -1
		  begin
			 select top 1 @Id_Doc_Genera_Prodotto = idheader 
				from Document_MicroLotti_Dettagli d with(nolock)  
				    inner join ctl_doc c with(nolock)  on c.id=d.idheader and d.tipodoc=c.tipodoc
				where CODICE_REGIONALE =  @Codice_regionale
				order by idheader 
		  end

		  --recupero la data del documento che ha generato il prodotto
		  select @DataTracciaBase=DataInvio 
			 from ctl_doc S with (nolock)
			 where id=@Id_Doc_Genera_Prodotto
    	  

		  insert into CTL_DOC (  Caption,fascicolo,ProtocolloRiferimento,titolo,idpfu,Azienda ,TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted,JumpCheck, Body, idPfuInCharge,StatoFunzionale,DataInvio)
				select 'Base Prodotto','', '','Base Prodotto',@idPfu, pfuidazi , 'CODIFICA_PROD_DOC', 'Sended' , @DataTracciaBase , '', 0 , 0 as Deleted , @ambito,NULL,@idPfu,'Inviato',@DataTracciaBase
				from profiliutente with(nolock) where idpfu = @idpfu
  
		  
		  
		  --IF @@ERROR <> 0 
		  --BEGIN
		  --	 raiserror ('Errore creazione record in ctl_doc.', 16, 1)
			 --return 99
		  --END 

		  set @newId = SCOPE_IDENTITY()
		  
		  insert into Document_dati_protocollo (idHeader) values(@newId)
		  
		  
		  INSERT into Document_MicroLotti_Dettagli ( IdHeader,TipoDoc,StatoRiga,EsitoRiga )
				select @newId , 'CODIFICA_PROD_DOC' as TipoDoc, 'Saved' as StatoRiga, '' as EsitoRiga

		  
		  set @idr = SCOPE_IDENTITY()				
		
		  -- ricopio tutti i valori
		  exec COPY_RECORD  'Document_MicroLotti_Dettagli'  ,@id  , @idr , ',Id,IdHeader,TipoDoc,EsitoRiga,idHeaderLotto, '	
		  
		  --------------------------------------------------------------------------------
		  -- IMPOSTO I MODELLI PER GLI ATTRIBUTI CHIAVE, OBBLIGATORI E OPZIONALE ---------
		  --------------------------------------------------------------------------------

		  set @modelloChiave = 'DOCUMENT_CODIFICA_PROD_' + @ambito + '_Mod_KEY'
		  set @modelloOpt = 'DOCUMENT_CODIFICA_PROD_' + @ambito + '_Mod_OPT'
		  set @modelloObblig = 'DOCUMENT_CODIFICA_PROD_' + @ambito + '_Mod_OBBLIG'

		  insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
			 values (   @newId , 'KEY' , @modelloChiave )

		  insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
			 values (   @newId , 'OBBLIG' , @modelloObblig )

		  insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
			 values (   @newId , 'OPT' , @modelloOpt )
		  	 
	   END
    
    

end

















GO
