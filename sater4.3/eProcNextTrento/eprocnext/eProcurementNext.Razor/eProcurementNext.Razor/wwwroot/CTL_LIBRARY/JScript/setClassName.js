function setClassName(target, clsName){
 
    try
    {
          target.className=clsName;
    }
    catch(e)
    {
        if (document.all != null) 
            target.className=clsName;
        else 
        {
            target.setAttribute("className", clsName) 
            try{target.setAttribute("class", clsName) }catch(e){};
        }
    }
}