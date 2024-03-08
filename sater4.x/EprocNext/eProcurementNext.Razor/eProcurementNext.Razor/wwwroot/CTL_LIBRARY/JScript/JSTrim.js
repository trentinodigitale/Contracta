function JSTrim(Str)
{
	var cnt1, cnt2;
    var objStr = new String(Str);
    var objTmpStr = new String('');
    var LenStr = objStr.length;
    
    // cerca il primo carattere non blank
    for (cnt1=0; ((cnt1 < LenStr - 1) && (objStr.charAt(cnt1) == " ")); cnt1++);

    // partendo dall'ultimo, cerca il primo carattere non blank
    for (cnt2 = LenStr - 1; ((cnt2>=0) && (objStr.charAt(cnt2) == " ")); cnt2--);

    // crea la stringa senza i blank all'inizio
	objTmpStr = objStr.substr(cnt1, (cnt2 - cnt1 + 1));
       
	return objTmpStr;
}
