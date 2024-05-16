USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[AVCP_LOTTO_MakeDifference]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[AVCP_LOTTO_MakeDifference]( @idDoc int , @PrevDoc int )
as
begin

	
	update  CTL_DOC set Body=' ' where id=@idDoc

	-- determina le differenze con il precedente
	
	IF EXISTS ( select * from document_AVCP_lotti d1
						inner join document_AVCP_lotti d2 on @PrevDoc = d2.idheader
				where d1.idheader = @idDoc  and ISNULL(d1.scelta_contraente,'')<>ISNULL(d2.scelta_contraente,'') )
	BEGIN
		update  CTL_DOC set Body=ISNULL(cast(Body as nvarchar(4000)),'') + 'scelta_contraente' + ' ' where id=@idDoc
	END

	IF EXISTS ( select * from document_AVCP_lotti d1
						inner join document_AVCP_lotti d2 on @PrevDoc = d2.idheader
				where d1.idheader = @idDoc  and ISNULL(d1.cig,'')<>ISNULL(d2.cig,'') )
	BEGIN
		update  CTL_DOC set Body=ISNULL(cast(Body as nvarchar(4000)),'') + 'Cig' + ' ' where id=@idDoc
	END

	IF EXISTS ( select * from document_AVCP_lotti d1
						inner join document_AVCP_lotti d2 on @PrevDoc = d2.idheader
				where d1.idheader = @idDoc  and ISNULL(cast(d1.Oggetto as nvarchar(4000)),'')<>ISNULL(cast(d2.Oggetto as nvarchar(4000)),'') )
	BEGIN
		update  CTL_DOC set Body=ISNULL(cast(Body as nvarchar(4000)),'') + 'Oggetto' + ' ' where id=@idDoc
	END

	IF EXISTS ( select * from document_AVCP_lotti d1
						inner join document_AVCP_lotti d2 on @PrevDoc = d2.idheader
				where d1.idheader = @idDoc  and ISNULL(d1.DataPubblicazione,'')<>ISNULL(d2.DataPubblicazione,'') )
	BEGIN
		update  CTL_DOC set Body=ISNULL(cast(Body as nvarchar(4000)),'') + 'DataPubblicazione' + ' ' where id=@idDoc
	END

	IF EXISTS ( select * from document_AVCP_lotti d1
						inner join document_AVCP_lotti d2 on @PrevDoc = d2.idheader
				where d1.idheader = @idDoc  and ISNULL(d1.ImportoAggiudicazione,'')<>ISNULL(d2.ImportoAggiudicazione,'') )
	BEGIN
		update  CTL_DOC set Body=ISNULL(cast(Body as nvarchar(4000)),'') + 'ImportoAggiudicazione' + ' ' where id=@idDoc
	END

	IF EXISTS ( select * from document_AVCP_lotti d1
						inner join document_AVCP_lotti d2 on @PrevDoc = d2.idheader
				where d1.idheader = @idDoc  and ISNULL(d1.DataInizio,'')<>ISNULL(d2.DataInizio,'') )
	BEGIN
		update  CTL_DOC set Body=ISNULL(cast(Body as nvarchar(4000)),'') + 'DataInizio' + ' ' where id=@idDoc
	END

	IF EXISTS ( select * from document_AVCP_lotti d1
						inner join document_AVCP_lotti d2 on @PrevDoc = d2.idheader
				where d1.idheader = @idDoc  and ISNULL(d1.Datafine,'')<>ISNULL(d2.Datafine,'') )
	BEGIN
		update  CTL_DOC set Body=ISNULL(cast(Body as nvarchar(4000)),'') + 'Datafine' + ' ' where id=@idDoc
	END

	IF EXISTS ( select * from document_AVCP_lotti d1
						inner join document_AVCP_lotti d2 on @PrevDoc = d2.idheader
				where d1.idheader = @idDoc  and ISNULL(d1.ImportoSommeLiquidate,'')<>ISNULL(d2.ImportoSommeLiquidate,'') )
	BEGIN
		update  CTL_DOC set Body=ISNULL(cast(Body as nvarchar(4000)),'') + 'ImportoSommeLiquidate' + ' ' where id=@idDoc
	END
	

end
GO
