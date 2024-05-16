USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_GENERA_MODELLO_PDA_OFFERTE]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OLD2_GENERA_MODELLO_PDA_OFFERTE]( @idBando int )
AS
BEGIN

	SET NOCOUNT ON

	DECLARE @CodiceModello VARCHAR(4000)
	DECLARE @modOFFERTA VARCHAR(4000)

	DECLARE @nomeModelloOffertePDA VARCHAR(4000)

	set @nomeModelloOffertePDA = 'PDA_MICROLOTTI_REPORT_OFFERTE_RICEVUTE_' + cast( @idBando as varchar(10))
	
	-- se il modello esiste gia non faccio niente ed esco
	IF EXISTS ( SELECT TOP 1 * from ctl_models with(nolock) where mod_id = @nomeModelloOffertePDA )
	BEGIN
		return
	END

	select  @CodiceModello =  b.TipoBando
		from Document_Bando b with(nolock)
		where b.idHeader = @idBando

	set @modOFFERTA = 'MODELLI_LOTTI_' + @CodiceModello + '_MOD_Offerta'

	-- controllo se c'è la necessità di una busta tecnica
	IF exists( 	
				select b.id
					from ctl_doc b with(nolock)
						inner join document_bando ba with(nolock) on ba.idheader = b.id
						inner join document_microlotti_dettagli lb with (nolock) on b.id = lb.idheader and lb.tipodoc = b.Tipodoc
						left outer join Document_Microlotti_DOC_Value v1 with(nolock) on v1.idheader = lb.id and v1.DZT_Name = 'CriterioAggiudicazioneGara'  and v1.DSE_ID = 'CRITERI_AGGIUDICAZIONE'
						left outer join Document_Microlotti_DOC_Value v2 with(nolock) on v2.idheader = lb.id and v2.DZT_Name = 'Conformita'  and v2.DSE_ID = 'CRITERI_AGGIUDICAZIONE'
					where b.id = @idBando and ( isnull( v1.Value , CriterioAggiudicazioneGara ) = '15532' or isnull( v1.Value , CriterioAggiudicazioneGara ) = '25532'  or isnull( v2.Value , Conformita ) <> 'No' ) 
			)
	BEGIN

		SET @modOFFERTA = 'MODELLI_LOTTI_' + @CodiceModello + '_MOD_OffertaINPUT'

	END

	INSERT INTO [CTL_Models] ([MOD_ID],[MOD_Name],[MOD_DescML],[MOD_Type],[MOD_Sys],[MOD_help],[MOD_Param],[MOD_Module],[MOD_Template])
			 VALUES  (@nomeModelloOffertePDA,@nomeModelloOffertePDA,@nomeModelloOffertePDA,1,1,'','Type=griglia&DrawMode=1&NumberColumn=2','PDA_OFFERTE',NULL)

	INSERT INTO [CTL_ModelAttributes] ([MA_MOD_ID],[MA_DZT_Name],[MA_DescML],[MA_Pos],[MA_Len],[MA_Order],[MA_Module])
								VALUES ( @nomeModelloOffertePDA,'aziRagioneSociale','Ragione Sociale',1,30,1,'PDA_OFFERTE')

	INSERT INTO [CTL_ModelAttributeProperties] ([MAP_MA_MOD_ID],[MAP_MA_DZT_Name],[MAP_Propety],[MAP_Value],[MAP_Module])
								VALUES ( @nomeModelloOffertePDA,'aziRagioneSociale','Format','Z99','PDA_OFFERTE' )

	INSERT INTO [CTL_ModelAttributeProperties] ([MAP_MA_MOD_ID],[MAP_MA_DZT_Name],[MAP_Propety],[MAP_Value],[MAP_Module])
								VALUES ( @nomeModelloOffertePDA,'aziRagioneSociale','Wrap','0','PDA_OFFERTE' )

	INSERT INTO [CTL_ModelAttributeProperties] ([MAP_MA_MOD_ID],[MAP_MA_DZT_Name],[MAP_Propety],[MAP_Value],[MAP_Module])
								VALUES ( @nomeModelloOffertePDA,'aziRagioneSociale','Width','200','PDA_OFFERTE' )

	INSERT INTO [CTL_ModelAttributes] ([MA_MOD_ID],[MA_DZT_Name],[MA_DescML],[MA_Pos],[MA_Len],[MA_Order],[MA_Module])
								VALUES ( @nomeModelloOffertePDA,'codicefiscale','Codice Fiscale',2,15,2,'PDA_OFFERTE')

	INSERT INTO [CTL_ModelAttributes] ([MA_MOD_ID],[MA_DZT_Name],[MA_DescML],[MA_Pos],[MA_Len],[MA_Order],[MA_Module])
								VALUES ( @nomeModelloOffertePDA,'ProtocolloOfferta','Registro di Sistema Offerta',3,10,3,'PDA_OFFERTE')

	INSERT INTO [CTL_ModelAttributes] ([MA_MOD_ID],[MA_DZT_Name],[MA_DescML],[MA_Pos],[MA_Len],[MA_Order],[MA_Module])
								VALUES ( @nomeModelloOffertePDA,'graduatoria','Graduatoria',4,3,4,'PDA_OFFERTE')

	INSERT INTO [CTL_ModelAttributes] ([MA_MOD_ID],[MA_DZT_Name],[MA_DescML],[MA_Pos],[MA_Len],[MA_Order],[MA_Module])
								VALUES ( @nomeModelloOffertePDA,'StatoRiga','Stato Riga',5,10,5,'PDA_OFFERTE')

	INSERT INTO [CTL_ModelAttributes] ([MA_MOD_ID],[MA_DZT_Name],[MA_DescML],[MA_Pos],[MA_Len],[MA_Order],[MA_Module])
								VALUES ( @nomeModelloOffertePDA,'Posizione','Posizione',6,4,6,'PDA_OFFERTE')

	INSERT INTO [CTL_ModelAttributes] ([MA_MOD_ID],[MA_DZT_Name],[MA_DescML],[MA_Pos],[MA_Len],[MA_Order],[MA_Module])
		select @nomeModelloOffertePDA as [MA_MOD_ID],[MA_DZT_Name],[MA_DescML],( MA_Pos + 10 ) as MA_Pos,[MA_Len],( MA_Order + 10 ) as MA_Order, 'PDA_OFFERTE' as [MA_Module]
			from CTL_ModelAttributes with(nolock) 
			where ma_mod_id = @modOFFERTA and MA_DZT_Name not in ( 'FNZ_DEL', 'FNZ_OPEN', 'NotEditable','TipoDoc','EsitoRiga')	
			order by ma_order

	INSERT INTO [CTL_ModelAttributeProperties] ([MAP_MA_MOD_ID],[MAP_MA_DZT_Name],[MAP_Propety],[MAP_Value],[MAP_Module])
			SELECT @nomeModelloOffertePDA as [MAP_MA_MOD_ID],[MAP_MA_DZT_Name],[MAP_Propety],[MAP_Value],[MAP_Module]
				from [CTL_ModelAttributeProperties] with(nolock)
				where MAP_MA_MOD_ID = @modOFFERTA and MAP_MA_DZT_Name not in ( 'FNZ_DEL', 'FNZ_OPEN', 'NotEditable','TipoDoc','EsitoRiga')	

END

GO
