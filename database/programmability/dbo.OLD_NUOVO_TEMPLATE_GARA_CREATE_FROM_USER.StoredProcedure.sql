USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_NUOVO_TEMPLATE_GARA_CREATE_FROM_USER]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OLD_NUOVO_TEMPLATE_GARA_CREATE_FROM_USER] (@idDoc INT, @IdUser INT)
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @Id AS INT

    -- genero il record per il nuovo documento, cancellato logicamente per evitare che sia visibile se non finalizza le operazioni	
    INSERT INTO CTL_DOC (IdPfu, TipoDoc, Azienda, deleted, StrutturaAziendale, Caption)
    SELECT idpfu
           , 'TEMPLATE_GARA'
           , pfuidazi AS Azienda
           , 1
           , cast(pfuidazi AS VARCHAR) + '#' + '\0000\0000' AS StrutturaAziendale
           , 'Nuovo Template Gara'
    FROM profiliutente WITH(NOLOCK)
    WHERE idpfu = @IdUser

    SET @id = SCOPE_IDENTITY()

    -- aggiunge il record sul bando				
    INSERT INTO Document_Bando (idHeader, TipoProceduraCaratteristica, DirezioneEspletante, EvidenzaPubblica)
    SELECT @id
           , ''
           , cast(pfuidazi AS VARCHAR) + '#' + '\0000\0000' AS DirezioneEspletante
           , '0'
    FROM profiliutente WITH(NOLOCK)
    WHERE idpfu = @IdUser

    --INSERT INTO Document_Bando_Riferimenti (idHeader, idPfu)
    --VALUES (@id, @IdUser)

	--inseriamo i valori utili nel caso di RDO

	insert into CTL_DOC_VALUE (idheader,DSE_ID,DZT_NAME,VALUE)
			select 	@id,'PARAMETRI','Importo_forniture',c2.value
				from ctl_doc
				inner join ctl_doc_value c1 on c1.idheader=id and c1.DSE_ID='DETTAGLI' and c1.dzt_name='Tipologia' and c1.Value='1'
				inner join ctl_doc_value c2 on c2.idheader=id and c2.DSE_ID='DETTAGLI' and c2.dzt_name='Importo'  and C1.Row=C2.Row
			where tipodoc='PARAMETRI_RDO' and deleted=0 and StatoFunzionale='Confermato'
		
		insert into CTL_DOC_VALUE (idheader,DSE_ID,DZT_NAME,VALUE)
			select 	@id,'PARAMETRI','Importo_Warning_forniture',c2.value
				from ctl_doc
				inner join ctl_doc_value c1 on c1.idheader=id and c1.DSE_ID='DETTAGLI' and c1.dzt_name='Tipologia' and c1.Value='1'
				inner join ctl_doc_value c2 on c2.idheader=id and c2.DSE_ID='DETTAGLI' and c2.dzt_name='Importo_Warning'  and C1.Row=C2.Row
			where tipodoc='PARAMETRI_RDO' and deleted=0 and StatoFunzionale='Confermato'



		--inserisco soglia importo servizi dal documento parametri RDO
		insert into CTL_DOC_VALUE (idheader,DSE_ID,DZT_NAME,VALUE)
			select 	@id,'PARAMETRI','Importo_servizi',c2.value
				from ctl_doc
				inner join ctl_doc_value c1 on c1.idheader=id and c1.DSE_ID='DETTAGLI' and c1.dzt_name='Tipologia' and c1.Value='3'
				inner join ctl_doc_value c2 on c2.idheader=id and c2.DSE_ID='DETTAGLI' and c2.dzt_name='Importo'  and C1.Row=C2.Row
			where tipodoc='PARAMETRI_RDO' and deleted=0 and StatoFunzionale='Confermato'

			insert into CTL_DOC_VALUE (idheader,DSE_ID,DZT_NAME,VALUE)
			select 	@id,'PARAMETRI','Importo_Warning_servizi',c2.value
				from ctl_doc
				inner join ctl_doc_value c1 on c1.idheader=id and c1.DSE_ID='DETTAGLI' and c1.dzt_name='Tipologia' and c1.Value='3'
				inner join ctl_doc_value c2 on c2.idheader=id and c2.DSE_ID='DETTAGLI' and c2.dzt_name='Importo_Warning'  and C1.Row=C2.Row
			where tipodoc='PARAMETRI_RDO' and deleted=0 and StatoFunzionale='Confermato'


    select @Id as id

END
GO
