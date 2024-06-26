USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[InsAteco]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[InsAteco] (@IdAzi int, @valore varchar(8000))
as

set nocount on

declare @valtemp          varchar(8000)
declare @valtemp1         varchar(8000)


if left (@valore, 3) = '###'
        set @valtemp = substring(@valore, 4, 8000)
else
        set @valtemp = @valore

while @valtemp <> '' and @valtemp <> '###'
begin

        if charindex('###', @valtemp) <> 0
        begin
                set @valtemp1 = substring (@valtemp, 1, charindex('###', @valtemp) -1)
                set @valtemp = substring (@valtemp, charindex('###', @valtemp) + 3, 8000)
        end
        else 
        begin
                set @valtemp1 = @valtemp
                set @valtemp = ''
        end

        insert into Aziateco(AtvAtecord, idazi) values (@valtemp1, @idazi)

        if @@error <> 0
        begin
                raiserror ('Errore "INSERT" Aziateco', 16, 1)
                return 99
        end

end 

set nocount off

GO
