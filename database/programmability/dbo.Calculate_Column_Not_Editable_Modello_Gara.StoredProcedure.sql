USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Calculate_Column_Not_Editable_Modello_Gara]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

















CREATE  PROCEDURE [dbo].[Calculate_Column_Not_Editable_Modello_Gara]( @IdDoc int, @ColName as varchar(200), 
		@off_colonne_non_editabili_lotto as nvarchar(max) out,  @off_colonne_non_editabili_voce  as nvarchar(max) out, 
		@off_colonne_non_editabili as nvarchar(max) out, @off_colonne_base_non_editabili as nvarchar(max) out  ) 
AS
begin

	
	--off_colonne_non_editabili_lotto, off_colonne_non_editabili_voce, off_colonne_non_editabili
	--declare @off_colonne_non_editabili_lotto as nvarchar(max)
	--declare @off_colonne_non_editabili_voce as nvarchar(max)
	--declare @off_colonne_non_editabili as nvarchar(max)
	
	set @off_colonne_non_editabili_lotto =' '
	set @off_colonne_non_editabili_voce =' '
	set @off_colonne_non_editabili =' '
	set @off_colonne_base_non_editabili = ' '

	
	--tutte le colonne della document_microlotti_dettagli
	select 
		@off_colonne_non_editabili = @off_colonne_non_editabili + ' ' + c.name   
		from syscolumns c
			inner join sysobjects o on o.id = c.id
			inner join systypes s on c.xusertype = s.xusertype
					
		where 
			o.name = 'document_microlotti_dettagli'


	set @off_colonne_non_editabili = @off_colonne_non_editabili + ' '

	--mi recupero tutte le colonne presenti nelmodello
	--select 
	--	@off_colonne_non_editabili = @off_colonne_non_editabili + ' ' + Attr.Value 

	--		from ctl_Doc_value Attr with (nolock)  
				 
	--	where 
	--		Attr.idheader = @IdDoc and Attr.dse_id='MODELLI' and Attr.dzt_name='DZT_Name'


	



	--mi recuopero le colonne non editabili a livello lotto ed alivello voce tra quelle ch esono in scrittura,obblig
	select 

		@off_colonne_non_editabili_lotto = @off_colonne_non_editabili_lotto  + 
		case 
			when LottoVoce.value ='Voce' then  Attr.Value + ' ' 
			else ''
		end,
	

		@off_colonne_non_editabili_voce = @off_colonne_non_editabili_voce + 
		case 
			when LottoVoce.value ='Lotto' then Attr.Value + ' ' 
			else ''
		end

			from ctl_Doc_value Attr with (nolock)  
				inner join ctl_Doc_value LottoVoce with (nolock) on LottoVoce.idheader=Attr.IdHeader and LottoVoce.dse_id=Attr.dse_id 
																	and LottoVoce.row = Attr.row and LottoVoce.DZT_Name ='LottoVoce'
				inner join ctl_Doc_value OffTec with (nolock) on OffTec.idheader=Attr.IdHeader and OffTec.dse_id=Attr.dse_id 
																	and offtec.row= Attr.row  and charindex( ',' + offtec.DZT_Name + ',' ,@ColName ) > 0 --in ('MOD_OffertaTec' ,'MOD_Offerta')
																	and OffTec.value  in ('scrittura','obblig')
			where 
				Attr.idheader = @IdDoc and Attr.dse_id='MODELLI' and Attr.dzt_name='DZT_Name'
	
		--select @off_colonne_non_editabili_lotto as 'Non Editabili Lotto'
		--select @off_colonne_non_editabili_voce as 'Non Editabili Voce'
		--select @off_colonne_non_editabili as 'Tutte'


		--recupero gli attributi non editabili di base sul modello (lettura e calcolato)
		select 
			@off_colonne_base_non_editabili = @off_colonne_base_non_editabili  + Attr.Value + ' ' 
		
		from ctl_Doc_value Attr with (nolock)  
				inner join ctl_Doc_value OffTec with (nolock) on OffTec.idheader=Attr.IdHeader and OffTec.dse_id=Attr.dse_id 
																	and offtec.row= Attr.row  and charindex( ',' + offtec.DZT_Name + ',' ,@ColName ) > 0 --in ('MOD_OffertaTec' ,'MOD_Offerta')
																	and OffTec.value  not in ('scrittura','obblig')
			where 
				Attr.idheader = @IdDoc and Attr.dse_id='MODELLI' and Attr.dzt_name='DZT_Name'

		set @off_colonne_base_non_editabili = @off_colonne_base_non_editabili + ' NumeroLotto Voce CIG IdRigaRiferimento '
end
--GO


GO
