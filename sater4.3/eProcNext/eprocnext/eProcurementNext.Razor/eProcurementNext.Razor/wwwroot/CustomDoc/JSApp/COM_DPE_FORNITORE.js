/* Tramite controllo sulla data dell'elemento, controllo se devo nascondere i campi nella comunicazione */
document.addEventListener("DOMContentLoaded", () => {
    if (document.getElementById('DataScadenza_L').innerHTML == '31/12/3000 00:00:00') {
        document.getElementById('cap_DataScadenza').style.display = "none"
        document.getElementById('Cell_DataScadenza').parentNode.parentNode.parentNode.style.display = "none"
        document.getElementById('cap_IdPfu').style.display = "none"
        document.getElementById('Cell_IdPfu').parentNode.parentNode.parentNode.style.display = "none"
    }
});

function afterProcess(param) 
{
	//alert(param);
	if ( param == 'ACCETTA' )
	{
		breadCrumbPop( '');
	}
	
	
	
}