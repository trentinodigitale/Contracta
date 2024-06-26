USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GENERA_MODELLO_PDA_CONCORSO_RISPOSTE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE  PROCEDURE [dbo].[GENERA_MODELLO_PDA_CONCORSO_RISPOSTE]( @idBando int )
AS
BEGIN

	SET NOCOUNT ON

	
	DECLARE @modOFFERTA VARCHAR(4000)

	DECLARE @nomeModelloOffertePDA VARCHAR(4000)

	set @nomeModelloOffertePDA = 'PDA_CONCORSO_REPORT_RISPOSTE_RICEVUTE_' + cast( @idBando as varchar(10))
	
	-- se il modello esiste gia non faccio niente ed esco
	IF EXISTS ( SELECT TOP 1 * from ctl_models with(nolock) where mod_id = @nomeModelloOffertePDA )
	BEGIN
		return
	END

	
	
	INSERT INTO [CTL_Models] ([MOD_ID],[MOD_Name],[MOD_DescML],[MOD_Type],[MOD_Sys],[MOD_help],[MOD_Param],[MOD_Module],[MOD_Template])
			 VALUES  (@nomeModelloOffertePDA,@nomeModelloOffertePDA,@nomeModelloOffertePDA,1,1,'','Type=griglia&DrawMode=1&NumberColumn=2','GROUP_CONCORSI',NULL)
	
	INSERT INTO [CTL_ModelAttributes] ([MA_MOD_ID],[MA_DZT_Name],[MA_DescML],[MA_Pos],[MA_Len],[MA_Order],[MA_Module])
								VALUES ( @nomeModelloOffertePDA,'Progressivo_Risposta','Progressivo Risposta',1,10,1,'GROUP_CONCORSI')


	INSERT INTO [CTL_ModelAttributes] ([MA_MOD_ID],[MA_DZT_Name],[MA_DescML],[MA_Pos],[MA_Len],[MA_Order],[MA_Module])
								VALUES ( @nomeModelloOffertePDA,'aziRagioneSociale','Ragione Sociale',2,30,2,'GROUP_CONCORSI')

	INSERT INTO [CTL_ModelAttributeProperties] ([MAP_MA_MOD_ID],[MAP_MA_DZT_Name],[MAP_Propety],[MAP_Value],[MAP_Module])
								VALUES ( @nomeModelloOffertePDA,'aziRagioneSociale','Format','Z99','GROUP_CONCORSI' )

	INSERT INTO [CTL_ModelAttributeProperties] ([MAP_MA_MOD_ID],[MAP_MA_DZT_Name],[MAP_Propety],[MAP_Value],[MAP_Module])
								VALUES ( @nomeModelloOffertePDA,'aziRagioneSociale','Wrap','0','GROUP_CONCORSI' )

	INSERT INTO [CTL_ModelAttributeProperties] ([MAP_MA_MOD_ID],[MAP_MA_DZT_Name],[MAP_Propety],[MAP_Value],[MAP_Module])
								VALUES ( @nomeModelloOffertePDA,'aziRagioneSociale','Width','200','GROUP_CONCORSI' )

	INSERT INTO [CTL_ModelAttributes] ([MA_MOD_ID],[MA_DZT_Name],[MA_DescML],[MA_Pos],[MA_Len],[MA_Order],[MA_Module])
								VALUES ( @nomeModelloOffertePDA,'codicefiscale','Codice Fiscale',3,15,3,'GROUP_CONCORSI')

	INSERT INTO [CTL_ModelAttributes] ([MA_MOD_ID],[MA_DZT_Name],[MA_DescML],[MA_Pos],[MA_Len],[MA_Order],[MA_Module])
								VALUES ( @nomeModelloOffertePDA,'ProtocolloOfferta','Registro di Sistema',4,10,4,'GROUP_CONCORSI')

	INSERT INTO [CTL_ModelAttributes] ([MA_MOD_ID],[MA_DZT_Name],[MA_DescML],[MA_Pos],[MA_Len],[MA_Order],[MA_Module])
								VALUES ( @nomeModelloOffertePDA,'graduatoria','Graduatoria',5,3,5,'GROUP_CONCORSI')

	INSERT INTO [CTL_ModelAttributes] ([MA_MOD_ID],[MA_DZT_Name],[MA_DescML],[MA_Pos],[MA_Len],[MA_Order],[MA_Module])
								VALUES ( @nomeModelloOffertePDA,'StatoRiga','Stato Riga',6,10,6,'GROUP_CONCORSI')

	INSERT INTO [CTL_ModelAttributes] ([MA_MOD_ID],[MA_DZT_Name],[MA_DescML],[MA_Pos],[MA_Len],[MA_Order],[MA_Module])
								VALUES ( @nomeModelloOffertePDA,'Posizione','Posizione',7,4,7,'GROUP_CONCORSI')

	INSERT INTO [CTL_ModelAttributes] ([MA_MOD_ID],[MA_DZT_Name],[MA_DescML],[MA_Pos],[MA_Len],[MA_Order],[MA_Module])
								VALUES ( @nomeModelloOffertePDA,'Descrizione','Descrizione',8,30,8,'GROUP_CONCORSI')
	
	INSERT INTO [CTL_ModelAttributeProperties] ([MAP_MA_MOD_ID],[MAP_MA_DZT_Name],[MAP_Propety],[MAP_Value],[MAP_Module])
								VALUES ( @nomeModelloOffertePDA,'Descrizione','Format','Z99','GROUP_CONCORSI' )

	INSERT INTO [CTL_ModelAttributeProperties] ([MAP_MA_MOD_ID],[MAP_MA_DZT_Name],[MAP_Propety],[MAP_Value],[MAP_Module])
								VALUES ( @nomeModelloOffertePDA,'Descrizione','Wrap','0','GROUP_CONCORSI' )

	INSERT INTO [CTL_ModelAttributes] ([MA_MOD_ID],[MA_DZT_Name],[MA_DescML],[MA_Pos],[MA_Len],[MA_Order],[MA_Module])
								VALUES ( @nomeModelloOffertePDA,'importoBaseAsta','Importo del Concorso',9,12,9,'GROUP_CONCORSI')
	

   --aggiungo tante colonne di tipo allegato quanti sono gli allegati richiesti nella busta documentazioen tecnica del concorso
     
   --recupero le righe che ho chiesto nella documentazione tecnica
   --che per noi diventano tanti attributi
   --drop table #temp
   select 
		top 20 
		
		idrow,
		case 
			when Obbligatorio = 1  then  '<div class="Grid_CaptionObblig">' + cast(DescrizioneRichiesta as nvarchar(max))  + '</div>'
			else  cast(DescrizioneRichiesta as nvarchar(max)) 
		end	as Descrizione 
		
		into #temp 

	from Document_Bando_DocumentazioneRichiesta with (nolock) 
		where idheader=@idBando and dse_id='DOCUMENTAZIONE_RICHIESTA_TECNICA'
		order by idrow asc



	INSERT INTO [CTL_ModelAttributes] ([MA_MOD_ID],[MA_DZT_Name],[MA_DescML],[MA_Pos],[MA_Len],[MA_Order],[MA_Module])
		
		select @nomeModelloOffertePDA as [MA_MOD_ID], 'CampoAllegato_' +  cast ( ROW_NUMBER() OVER(ORDER BY idrow ASC) as varchar)  as MA_DZT_Name
				, 	Descrizione , ( ROW_NUMBER() OVER(ORDER BY Descrizione ASC) + 10 ) as MA_Pos
				, 10 as MA_Len ,( ROW_NUMBER() OVER(ORDER BY Descrizione ASC) + 10 ) as MA_Order
				, 'PDA_CONCORSO' as MA_Module
			from 
				#temp
				order by idrow

	drop table #temp


		--select @nomeModelloOffertePDA as [MA_MOD_ID],[MA_DZT_Name],[MA_DescML],( MA_Pos + 10 ) as MA_Pos,[MA_Len],( MA_Order + 10 ) as MA_Order, 'PDA_OFFERTE' as [MA_Module]
		--	from CTL_ModelAttributes with(nolock, index (IX_CTL_ModelAttributes_MA_MOD_ID)) 
		--	where ma_mod_id = @modOFFERTA and MA_DZT_Name not in ( 'FNZ_DEL', 'FNZ_OPEN', 'NotEditable','TipoDoc','EsitoRiga')	
		--	order by ma_order

	--INSERT INTO [CTL_ModelAttributeProperties] ([MAP_MA_MOD_ID],[MAP_MA_DZT_Name],[MAP_Propety],[MAP_Value],[MAP_Module])
	--		SELECT @nomeModelloOffertePDA as [MAP_MA_MOD_ID],[MAP_MA_DZT_Name],[MAP_Propety],[MAP_Value],[MAP_Module]
	--			from [CTL_ModelAttributeProperties] with(nolock,index(IX_CTL_ModelAttributeProperties_MAP_MA_MOD_ID)) 
	--			where MAP_MA_MOD_ID = @modOFFERTA and MAP_MA_DZT_Name not in ( 'FNZ_DEL', 'FNZ_OPEN', 'NotEditable','TipoDoc','EsitoRiga')	

END
GO
