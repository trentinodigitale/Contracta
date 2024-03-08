



function PRODOTTI_OnLoad()
{
    ShowCol_TipoOrdine();
}


function ShowCol_TipoOrdine()
{

        var TipoOrdine = 'B';
        //try{ TipoOrdine = getObjValue( 'val_TipoOrdine' );   } catch ( e ) {TipoOrdine = 'S';};



        if( TipoOrdine == 'S' )
        {

            //ShowCol( 'PRODOTTI' , 'RDP_CodArtProd' , '' );
            ShowCol( 'PRODOTTI' , 'QtMin' , '' );
            //ShowCol( 'PRODOTTI' , 'RDP_Qt' , '' );

            ShowCol( 'PRODOTTI' , 'CostoComplessivo' , 'none' );
            ShowCol( 'PRODOTTI' , 'CoefCorr' , 'none' );
            ShowCol( 'PRODOTTI' , 'PercSconto' , 'none' );
            ShowCol( 'PRODOTTI' , 'DataUtilizzo' , 'none' );
            ShowCol( 'PRODOTTI' , 'ImportoCompenso' , 'none' );
        
        }
        
        if( TipoOrdine == 'P' )
        {
        
            //ShowCol( 'PRODOTTI' , 'RDP_CodArtProd' , 'none' );
            ShowCol( 'PRODOTTI' , 'QtMin' , 'none' );
            //ShowCol( 'PRODOTTI' , 'RDP_Qt' , 'none' );

            ShowCol( 'PRODOTTI' , 'CostoComplessivo' , 'none' );
            ShowCol( 'PRODOTTI' , 'CoefCorr' , 'none' );
            ShowCol( 'PRODOTTI' , 'PercSconto' , '' );
            ShowCol( 'PRODOTTI' , 'DataUtilizzo' , '' );
            ShowCol( 'PRODOTTI' , 'ImportoCompenso' , 'none' );
        
        }

        if( TipoOrdine == 'C' )
        {
        
            //ShowCol( 'PRODOTTI' , 'RDP_CodArtProd' , '' );
            ShowCol( 'PRODOTTI' , 'QtMin' , '' );
            //ShowCol( 'PRODOTTI' , 'RDP_Qt' , '' );

            ShowCol( 'PRODOTTI' , 'CostoComplessivo' , '' );
            ShowCol( 'PRODOTTI' , 'CoefCorr' , '' );
            ShowCol( 'PRODOTTI' , 'PercSconto' , 'none' );
            ShowCol( 'PRODOTTI' , 'DataUtilizzo' , 'none' );
            ShowCol( 'PRODOTTI' , 'ImportoCompenso' , 'none' );
        
        }

        if( TipoOrdine == 'B' )
        {
        
            //ShowCol( 'PRODOTTI' , 'CodArt' , 'none' );
            ShowCol( 'PRODOTTI' , 'QtMin' , 'none' );
            //ShowCol( 'PRODOTTI' , 'CARQuantitaDaOrdinare' , 'none' );

            ShowCol( 'PRODOTTI' , 'CostoComplessivo' , 'none' );
            ShowCol( 'PRODOTTI' , 'CoefCorr' , 'none' );
            ShowCol( 'PRODOTTI' , 'PercSconto' , '' );
            ShowCol( 'PRODOTTI' , 'DataUtilizzo' , '' );
            ShowCol( 'PRODOTTI' , 'ImportoCompenso' , '' );
        
        }
        
        

}


function PRODOTTI_AFTER_COMMAND( com )
{
    ShowCol_TipoOrdine( );
}

