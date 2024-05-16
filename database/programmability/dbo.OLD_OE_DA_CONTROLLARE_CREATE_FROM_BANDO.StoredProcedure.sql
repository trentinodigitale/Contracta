USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_OE_DA_CONTROLLARE_CREATE_FROM_BANDO]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[OLD_OE_DA_CONTROLLARE_CREATE_FROM_BANDO] 
	( @iddoc int  , @idUser int )
AS
BEGIN
	declare @id int		
	declare @Errore as nvarchar(4000)
	declare @TipoDocParametri as varchar(200)
	declare @Tipo_Estrazione int
	declare @Perc_Soggetti float
	declare @Num_estrazione_mista int
	declare @numero_o_e_da_controllare int
	declare @elenco_documenti_controlli_OE as nvarchar(max)
	declare @JumpCheck as varchar(200)
	declare @numIscrittiME as INT
	set @Errore = ''

	SET NOCOUNT ON

	--recupeor @@TipoDocParametri sul bando
	select 
			@TipoDocParametri=
			case 
				when TipoDoc='BANDO' AND ISNULL(JumpCheck,'')=''  then 'ALBO'
				when TipoDoc='BANDO_SDA' then 'SDA'
				else 'ERRORE'
			end,
			@JumpCheck=
			case 
				when TipoDoc='BANDO' AND ISNULL(JumpCheck,'')=''  then 'BANDO_ME'
				when TipoDoc='BANDO_SDA' then 'BANDO_SDA'
				else JumpCheck
			end
		from ctl_doc where id=@iddoc
			
	--RECUPERO IL CRITERIO DI ESTRAZIONE DEGLI O.E
	select 				
			@Tipo_Estrazione=Tipo_Estrazione,
			@Perc_Soggetti=Perc_Soggetti,
			@Num_estrazione_mista=Num_estrazione_mista,
			@elenco_documenti_controlli_OE=elenco_documenti_controlli_OE
		from Document_Parametri_Abilitazioni
		where TipoDoc = @TipoDocParametri and isnull( deleted , 0 ) = 0


	--VERIFICHIAMO SE PER IL BANDO E' STATO FATTO IL DOCUMENTO DI CONFIGURAZIONE
	IF ISNULL(@Tipo_Estrazione,'') = '' or @Tipo_Estrazione not in ('1','2','3') or ISNULL(@elenco_documenti_controlli_OE,'')=''
	BEGIN
		set @Errore='Operazione non possibile. Verificare la configurazione del documento di Configurazione Parametri'
	END
	
	--VERIFICHIAMO SE CI SONO ISCRITTI
	select @numIscrittiME = COUNT(*)								
		from CTL_DOC_Destinatari with(nolock)
			where idHeader=@iddoc
		 		and StatoIscrizione in ('Iscritto')
	
	IF @numIscrittiME < 1
	BEGIN
		set @Errore='Operazione non possibile. Sul Bando non sono presenti Iscritti'
	END
	
	--VERIFICA SE ESISTE UN DOCUMENTO IN LAVORAZIONE PER IL BANDO LO RIAPRE
	select @id=id 
		from CTL_DOC with(nolock) 
		where LinkedDoc=@iddoc and TipoDoc='OE_DA_CONTROLLARE' 
			and deleted=0 and StatoFunzionale   in ('InLavorazione') 
	
	--CONTROLLO CHE SONO IL RUP PER ACCEDERE AL DOCUMENTO InLavorazione OPPURE un UTENTE TRA I RIFERIMENTI come istanze
	if ISNULL(@id,0)>0 and @Errore = ''
	begin
		IF NOT EXISTS ( --VERIFICO SE SONO IL RUP
					select idpfu from Document_Bando_Commissione  with(nolock) where idHeader=@iddoc and RuoloCommissione = '15550' and idPfu=@idUser
					UNION
					--verifico se sono tra i riferimenti come istanze
					select idpfu from Document_Bando_Riferimenti  with(nolock) where idHeader=@iddoc and RuoloRiferimenti = 'Istanze' and idPfu=@idUser
				  )
		BEGIN
			set @Errore='Operazione non possibile. Solo il Responsabile del Procedimento oppure gli utenti con ruolo "Istanze" possono accedere al documento'	
		END
	
	end
	
	--CONTROLLO CHE SONO IL RUP PER CREARE UN NUOVO DOCUMENTO
	if ISNULL(@id,0)=0 and @Errore = ''
	begin
		IF NOT EXISTS ( --VERIFICO SE SONO IL RUP
						select idpfu from Document_Bando_Commissione  with(nolock) where idHeader=@iddoc and RuoloCommissione = '15550' and idPfu=@idUser					
					  )
		BEGIN
			set @Errore='Operazione non possibile. Solo il Responsabile del Procedimento può creare un nuovo documento'	
		END
	end




	--CREA IL DOC
	if ISNULL(@id,0)=0 and @Errore = ''
	begin	
			
		--CREA IL DOCUMENTO
		INSERT into CTL_DOC ( IdPfu, Titolo , TipoDoc , deleted  ,LinkedDoc,Body,Fascicolo ,Azienda,ProtocolloRiferimento,JumpCheck)
			select @idUser, 'O.E. da Controllare' ,'OE_DA_CONTROLLARE'  , 0 , id , body ,C.Fascicolo,P.pfuidazi,Protocollo,@JumpCheck
				from CTL_DOC C with(NOLOCK) 
					inner join ProfiliUtente P with(nolock) on P.IdPfu=@idUser				
				WHERE C.Id=@iddoc 		
					
			set @id=SCOPE_IDENTITY()

         --SUL DOCUMENTO IMPOSTO PUBLICA A CHECKED
		 insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Row,Value)
			select @id , 'PUBBLICA' ,'Pubblica' ,0 ,'1'

		
		--SUL DOCUMENTO RECUPERO IN NUMERO ISCRITTI IN QUEL MOMENTO
		 insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Row,Value)
			select @id , 'DOCUMENT' ,'numIscrittiME' ,0 ,@numIscrittiME							
				

		--SUL DOCUMENTO IMPOSTO IL TIPO DI ESTRAZIONE CONFIGURATA
		 insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Row,Value)
			select @id , 'DOCUMENT' ,'Tipo_Estrazione' ,0 ,@Tipo_Estrazione

		 insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Row,Value)
			select @id , 'DOCUMENT' ,'Perc_Soggetti' ,0 ,@Perc_Soggetti

		 insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Row,Value)
			select @id , 'DOCUMENT' ,'Num_estrazione_mista' ,0 ,@Num_estrazione_mista


		
		--CALCOLO IL NUMERO DI O.E. DA ESTRARRE IN BASE ALLA SCELTA IN CONFIGURAZIONE
		IF @Tipo_Estrazione in ( 1 ,3 )  --Esclusivamente in %
		BEGIN
			declare @result as decimal(10,2)
			select
					@result=(@Perc_Soggetti * @numIscrittiME)/convert(decimal(10,2),100)
				
			
			if @result > cast(@result as int) 
				set @result=cast(@result as int)+1
			
			set @numero_o_e_da_controllare=cast(@result as int) 
			
		END	
		
		IF @Tipo_Estrazione = 2   --- Esclusivamente in valore assoluto
			set @numero_o_e_da_controllare=@Num_estrazione_mista
		
		IF @Tipo_Estrazione = 3   ---	Mista: in % limitata dal valore assoluto
		BEGIN	
			if @numero_o_e_da_controllare > @Num_estrazione_mista
				set @numero_o_e_da_controllare=@Num_estrazione_mista
		END


		INSERT into CTL_DOC ( IdPfu,  TipoDoc , deleted  ,LinkedDoc,Body,Fascicolo ,Azienda,ProtocolloRiferimento,Destinatario_Azi,titolo,idPfuInCharge,StatoDoc,JumpCheck)
			select top ( @numero_o_e_da_controllare ) 0, 'CONTROLLI_OE'  , 0 , @id , C.body ,C.Fascicolo,P.pfuidazi,I.Protocollo,IdAzi,'Controllo O.E.',0,'',@JumpCheck
				from CTL_DOC_Destinatari  with(nolock)
					inner join ProfiliUtente P with(nolock) on P.IdPfu=@idUser	
					inner join CTL_DOC C with(nolock) on Id=idHeader		
					inner join CTL_DOC I with(nolock) on I.id=Id_Doc
				where idHeader=@iddoc
					and StatoIscrizione in ('Iscritto')
			ORDER BY rand(CAST( NEWID() AS varbinary ))	

		--INSERISCO I DOCUMENTI DA CONTROLLARE SUI DOCUMENTI CONTROLLI_OE
		insert into Document_Controlli_OE_Controlli (idHeader,NomeDocumento)
		select ID ,items
			from CTL_DOC 
				cross join dbo.Split(@elenco_documenti_controlli_OE ,'###') 
				where LinkedDoc=@id and TipoDoc='CONTROLLI_OE' and  items <> '###' and ISNULL(items,'') <> ''
			order by items

	end

	

		
		if @Errore = '' and ISNULL(@id,0) <> 0
		begin
			-- rirorna l'id del doc da aprire
			select @Id as id
				
		end
		else
		begin

			select 'Errore' as id , @Errore as Errore

		end



END

	
GO
