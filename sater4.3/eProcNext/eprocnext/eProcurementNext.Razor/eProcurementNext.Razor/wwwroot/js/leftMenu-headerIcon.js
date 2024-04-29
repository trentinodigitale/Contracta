//global var drawer draggable

var isResizing = false, lastDownX = 0;
function resize(e) {
    const rightArea = document.getElementById("rightArea");

    if (!isResizing)
        return;
    var offsetRight = $('#container').width() - (e.clientX - $('#container').offset().left);
    const divExpand = document.getElementById("divExpand");
    
    if ((document.getElementById("sidebar-wrapper")?.getBoundingClientRect()?.width + offsetRight + (divExpand ? divExpand.getBoundingClientRect()?.width : 0)) > window.innerWidth) {
        return;
    }
    if (divExpand) {
        divExpand.style.right = offsetRight + "px";
    }
    rightArea.setAttribute('style', `width: ${offsetRight + "px" + "!important"}`)

}



/// APRI CHIUDI MENU ///
$(document).on("click", "#menu-toggle", function (e) {
    e.preventDefault();
    $("#wrapper").toggleClass("toggled");
});

$(document).on("click", "#menu-toggle-2", function (e) {
    e.preventDefault();
    $("#wrapper").toggleClass("toggled-2");
    $('#menu ul').hide();
    $(this).find('i').toggleClass('fa-bars fa-times');
    $("#sidebar-wrapper").removeClass('wrapper-submenu');
});

/// SUBMENU ///
$(document).on("click", "li.dropdownvapor a", function (e) {
    e.preventDefault();
    if ($('li.dropdownvapor').hasClass('activeSub')) {
        return false;
    }
    else {
        $("#sidebar-wrapper").addClass('wrapper-submenu');    
    }
});
$(document).on("click", "submenuvapor li a", function (e) {
    e.preventDefault();
    $("#sidebar-wrapper").removeClass("wrapper-submenu");
    $('.submenuvapor').hide();
});


var startHandlerDrawer = () => {
    $(document).on("click", "#page-content-wrapper", function (e) {
        $("#sidebar-wrapper").removeClass("wrapper-submenu");
        $('.submenuvapor').hide();
        $("#rightArea").removeClass("areaOpen");
        $("#bottomButtons").removeClass("areaOpenButton");
    });
}

startHandlerDrawer();

var stopHandlerDrawer = () => { $(document).off("click", "#page-content-wrapper") }

var openDrawer = (
    htmlToInject,
    customWidth,
    customTitle,
    customSubtitle,
    expandable,
    removeCloseHandler,
    removeDrawerTitle,
    containerToolbarButtonHtml,
    draggable) => { 
            
    let rightArea = document.getElementById("rightArea");
    let drawerTitle = document.getElementById("drawerTitle");
    let containerRightArea = document.getElementById("containerRightArea");
    let containerToolbarButton = document.getElementById("containerToolbarButton");

    if (customTitle === "" || customTitle) {
        if (rightArea.getElementsByTagName("h1").length != 0) {
            rightArea.getElementsByTagName("h1")[0].innerText = customTitle; 
        }
    }

    if (customSubtitle === "" || customSubtitle) {
        if (drawerTitle.getElementsByTagName("p").length != 0) {
            drawerTitle.getElementsByTagName("p")[0].innerText = customSubtitle;
        }
    }

    if (htmlToInject === "" || htmlToInject) {
        containerRightArea.innerHTML = htmlToInject;
    }

    if (removeCloseHandler) {
        stopHandlerDrawer();
    }
    if (removeDrawerTitle) {
        drawerTitle.style = `
            transform: translateY(13px);
            position: absolute;
            background: transparent;
            border: none;`
        drawerTitle.querySelector("button").classList.remove("me-4");
        if (rightArea.querySelector(".iframeRightAreaContain")) {
            rightArea.querySelector(".iframeRightAreaContain").style.height = (rightArea.getBoundingClientRect().height - 3) + "px";
        }
    }

    if (customWidth) {
        rightArea.setAttribute('style', `width: ${customWidth}px!important`);
    }

    if (containerToolbarButtonHtml) {
        containerToolbarButton.innerHTML = containerToolbarButtonHtml;
    } else {
        containerToolbarButton.innerHTML = "";
    }

    if (expandable) {
        let rightAreaContainer = document.getElementById("rightAreaWrapper");
        let divExpand = document.createElement("div");
        divExpand.setAttribute("id", "divExpand");
        let newButton = drawerTitle.querySelector("button").cloneNode(true);

        divExpand.onclick = function () {
            let widthMenuSX = document.getElementById("sidebar-wrapper")?.getBoundingClientRect()?.width;
            let isFullScreen = (window.innerWidth - rightArea.getBoundingClientRect().width - divExpand.getBoundingClientRect().width - widthMenuSX <= 5);
            if (!isFullScreen) {
                rightArea.setAttribute('style', `width: calc(98% - ${widthMenuSX}px)!important`);
                divExpand.setAttribute('style', `left:calc(0% + ${widthMenuSX}px)!important`);
                divExpand.style.transform = "rotateZ(90deg)";
            } else {
                if (customWidth) {
                    rightArea.setAttribute('style', `width: ${customWidth}px!important`);
                    divExpand.removeAttribute('style');
                    divExpand.style.transform = "rotateZ(270deg)";
                    divExpand.style.right = `${customWidth}px`;
                    divExpand.style.left = `unset`;
                } else {
                    rightArea.setAttribute('style', ``);
                    divExpand.removeAttribute('style');
                    divExpand.style.transform = "rotateZ(270deg)";
                }
            }

        }
        if (customWidth) {
            divExpand.setAttribute("style", `right: ${customWidth}px; left:unset`);
        }
        newButton.classList.remove("closeWindows");
        newButton.classList.remove("rounded-circle");
        newButton.querySelector("i").classList.remove("fa-times");
        newButton.querySelector("i").classList.add("fa-arrow-up");
        divExpand.appendChild(newButton);
        rightAreaContainer.insertBefore(divExpand, rightAreaContainer.firstChild);
    }

    if (draggable) {
        let divDraggable = document.createElement("div");
        divDraggable.setAttribute("id", "divDraggable");
                
        divDraggable.style = `
            background: transparent;
            height: 100%;
            width: 5px;
            position: absolute;
            left: 0px;
            cursor: ew-resize;
            -webkit-user-select: none; /* Safari */
            -ms-user-select: none; /* IE 10 and IE 11 */
            user-select: none; /* Standard syntax */
        `
        divDraggable.onmousedown = (e) => {
            //allo start del drag disattivo i pointerEvents in tutti gli iframe (senza di questo l'iframe nasconde il mousemove)
            let iframeList = document.getElementsByTagName("iframe");
            for (var i = 0; i < iframeList.length; i++) {
                iframeList[i].style.pointerEvents = "none";
            }
            rightArea.classList.add("no-transition");
            let divExpand = document.getElementById("divExpand");
            if (divExpand) {
                divExpand.style.left = "unset";
                divExpand.style.transition = "none"
            }
            document.addEventListener("mousemove", resize, false);
            document.onmouseup = () => {
                let iframeList = document.getElementsByTagName("iframe");
                for (var i = 0; i < iframeList.length; i++) {
                    iframeList[i].style.pointerEvents = "";
                }
                document.removeEventListener("mousemove", resize, false);
                isResizing = false;
                rightArea.classList.remove("no-transition");
                let divExpand = document.getElementById("divExpand");
                if (divExpand) {
                    divExpand.style.transition = ""
                }

            }
            isResizing = true;
            lastDownX = e.clientX;
        }
        rightArea.insertBefore(divDraggable, rightArea.firstChild);
    }

    rightArea.classList.remove("areaOpen");
    rightArea.classList.add("areaOpen");




}
var closeDrawer = () => { 
    let rightArea = document.getElementById("rightArea");
    let drawerTitle = document.getElementById("drawerTitle");
    let containerRightArea = document.getElementById("containerRightArea");

    $("#rightArea").removeClass("areaOpen");
    $("#bottomButtons").removeClass("areaOpenButton");
    //reset Drawer styles
    rightArea.setAttribute('style', ``);
    drawerTitle.style = ``
    drawerTitle.querySelector("button").classList.remove("me-4");
    drawerTitle.querySelector("button").classList.add("me-4");
    containerRightArea.innerHTML = "";
    if (rightArea.getElementsByTagName("h1").length != 0) {
        rightArea.getElementsByTagName("h1")[0].innerText = "";
    }
    if (drawerTitle.getElementsByTagName("p").length != 0) {
        drawerTitle.getElementsByTagName("p")[0].innerText = "";
    }
    if (rightArea) {
        let divExpand = document.getElementById("divExpand");
        if (divExpand) {
            divExpand.remove();
        }

        let divScrollable = document.getElementById("divScrollable");
        if (divScrollable) {
            divScrollable.remove();
        }
    }


    containerToolbarButton.innerHTML = "";
}

$(document).on("click", ".closeWindows", function (e) {
    e.preventDefault(); 
    startHandlerDrawer();
    closeDrawer();
});



// APRI/CHIUDI AREA UTENTE
//$(document).on("click", ".openRightArea", function (e) {
//    e.preventDefault();
//    //if (!$("#rightArea").hasClass("areaOpen")) {
//    closeDrawer();
//    openDrawer();
//        //$("#rightArea").toggleClass("areaOpen");
//        //$("#bottomButtons").toggleClass("areaOpenButton");
//    //} else {
//    //    closeDrawer();
//    //    //$("#bottomButtons").toggleClass("areaOpenButton");
//    //}
//});

// APRI/CHIUDI MENU DESTRA MOBILE
$(document).on("click", "#buttonHeaderRightMobile", function (e) {
    e.preventDefault();
    $(".header-right").toggleClass("top100");
});


function initMenu() {
    $('#menu ul').hide();
    $('#menu ul').children('.current').parent().show();
    //$('#menu ul:first').show();
    $(document).on("click", "#menu li a", function () {
            var checkElement = $(this).next();
            if ((checkElement.is('ul')) && (checkElement.is(':visible'))) {
                return false;
            }
            if ((checkElement.is('ul')) && (!checkElement.is(':visible'))) {
                $('#menu ul:visible').css("display", "none");
                checkElement.css("display", "block");
                return false;
            }
        }
    );
}

initMenu();

document.querySelectorAll('button[data-dismiss="toast"]').forEach(item => {
    item.addEventListener('click', event => {
        event.target.closest(".toastVapor").classList.remove("active");
        event.target.closest(".toastVapor").classList.remove("toastInformative");//1
        event.target.closest(".toastVapor").classList.remove("toastWarning");//2
        event.target.closest(".toastVapor").classList.remove("toastCheck");//3
        event.target.closest(".toastVapor").classList.remove("toastError");//4
    })
})

/// Aggiunge/toglie Classe Active al click della prima voce di menu ///


document.querySelectorAll('ul#menu li').forEach(item => {
    item.addEventListener('click', event => {
        document.querySelectorAll('li').forEach(i => { i.classList.remove('active') })
        item.classList.add('active')
    })
})

document.querySelectorAll('.submenuvapor li a').forEach(item => {
    item.addEventListener('click', event => {
        document.querySelectorAll('li a').forEach(i => { i.classList.remove('activeSub') })
        item.classList.add('activeSub')
    })
})

const showDatePickerFaseII = (Name) => {
    let temp = document.getElementById(Name);
    let temp_V = document.getElementById(`${Name}_V`);
    let temp_HH_V = document.getElementById(`${Name}_HH_V`);
    let temp_MM_V = document.getElementById(`${Name}_MM_V`);

    let itaLang = {
        closeText: "Chiudi",
        prevText: "Prec",
        nextText: "Succ",
        currentText: "Oggi",
        monthNames: ["Gennaio", "Febbraio", "Marzo", "Aprile", "Maggio", "Giugno",
            "Luglio", "Agosto", "Settembre", "Ottobre", "Novembre", "Dicembre"],
        monthNamesShort: ["Gen", "Feb", "Mar", "Apr", "Mag", "Giu",
            "Lug", "Ago", "Set", "Ott", "Nov", "Dic"],
        dayNames: ["Domenica", "Luned�", "Marted�", "Mercoled�", "Gioved�", "Venerd�", "Sabato"],
        dayNamesShort: ["Dom", "Lun", "Mar", "Mer", "Gio", "Ven", "Sab"],
        dayNamesMin: ["Do", "Lu", "Ma", "Me", "Gi", "Ve", "Sa"],
        weekHeader: "Sm",
        firstDay: 1,
        isRTL: false,
        showMonthAfterYear: false,
        yearSuffix: ""
    }

    let customLang = {};

    if (typeof userSuffix !== 'undefined' && userSuffix == "i") {
        customLang = itaLang;
    }

    $(temp_V).datepicker({
        onSelect: function (date, datepicker) {
            if (date != "") {
                let hVal, mVal;
                hVal = $(temp_HH_V).val();
                mVal = $(temp_MM_V).val();
                $(temp).val(`${date}T:${hVal ? hVal: '00'}:${mVal ? mVal : '00'}:00`)

                let yyyy, MM, dd;
                yyyy = new Date(date).toLocaleString("default", { year: "numeric" });
                MM = new Date(date).toLocaleString("default", { month: "2-digit" });
                dd = new Date(date).toLocaleString("default", { day: "2-digit" });

				

                $(temp_V).val(`${dd}/${MM}/${yyyy}`)
				
				try{
					ck_VD(temp_V);
				}catch{
				}
				
                if (temp_V.onchange != null) {
                    temp_V.onchange();
                }
				
            }
        },
        dateFormat: "yy/mm/dd",
        changeMonth: true,
        changeYear: true,
        ...customLang
    });

    if (document.getElementById(`${Name}_V`).readOnly) {
        return;
    }
    $(document.getElementById(`${Name}_V`)).datepicker('show');
}

$(document).ready(() => {

    initializeResizableGrids();

    let pageContentWrapper = document.getElementById("page-content-wrapper");
    if (pageContentWrapper) {
        SetLastScrollWindowFaseII(pageContentWrapper);
        pageContentWrapper.addEventListener("scroll", (e) => { OnPageContentWrapperScroll(e) })
    }

    initializeGroup_WinFilter();
    
})

const resizableGrid = (table) => {
    if (!table || (table && table.getAttribute("resizable-grid") == "active"))
        return;
    var row = table.getElementsByTagName('tr')[0],
        cols = row ? row.children : undefined;
    if (!cols) return;
    table.setAttribute("resizable-grid", "active");
    let skipRemoveWidth = false;
    try {
        skipRemoveWidth = table.children[0].children[0].childElementCount === 1;
    } catch {
        skipRemoveWidth = false;
    }
    if (!skipRemoveWidth) {
        table.removeAttribute("width");
    }

    const setListeners = (div) => {
        var pageX, curCol, nxtCol, curColWidth, nxtColWidth, lastCol, lastColWidth;

        div.addEventListener('mousedown', function (e) {
            curCol = e.target.parentElement;
            
            if (curCol.closest("table").clientWidth > curCol.closest("table").scrollWidth) {
                lastCol = findLastSibling(curCol);
                if (lastCol)
                    lastColWidth = lastCol.offsetWidth;
            }

            pageX = e.pageX;

            curColWidth = curCol.offsetWidth;
            if (nxtCol)
                nxtColWidth = nxtCol.offsetWidth;
        });

        div.addEventListener('mouseover', function (e) {
            e.target.style.borderRight = '1px solid black';
            e.target.classList.add("main-color-border-right");
        })

        div.addEventListener('mouseout', function (e) {
            e.target.style.borderRight = '';
        })

        document.addEventListener('mousemove', function (e) {
            if (curCol) {
                var diffX = e.pageX - pageX;

                if ((curColWidth + diffX - paddingDiff(curCol)) < 0)
                    return;

                applyWidthToCol(curCol, curColWidth, diffX, nxtCol, nxtColWidth, lastCol, lastColWidth);
                


            }
        });

        document.addEventListener('mouseup', function (e) {
            curCol = undefined;
            nxtCol = undefined;
            pageX = undefined;
            nxtColWidth = undefined;
            curColWidth = undefined;
            lastCol = undefined;
            lastColWidth = undefined;
        });
    }

    var tableHeight = table.offsetHeight;

    for (var i = 0; i < cols.length; i++) {
        var div = createDiv(tableHeight);
        cols[i].appendChild(div);
        cols[i].style.position = 'relative';
        setListeners(div);
    }

    

};

const applyWidthToCol = (_curCol, _curColWidth, _diffX, _nxtCol, _nxtColWidth, _lastCol, _lastColWidth) => {
    
    //se riduco una colonna X, se la tabella � grande come lo schermo, aggiungo i pixel che tolgo alla colonna X, all'ultima colonna
    if (true) {
        _nxtCol = null;// _lastCol;
        _nxtColWidth = null;// _lastColWidth;
    }

    if (_nxtCol)
        _nxtCol.style.minWidth = (_nxtColWidth - (_diffX)) + 'px';

    let newWidth = _curColWidth + _diffX;
    let newWidthNextCol = _nxtColWidth - _diffX;
    _curCol.style.minWidth = (newWidth) + 'px';

    let indexOfTH = getIndexOfTH(_curCol);
    let indexOfNextTH = getIndexOfTH(_nxtCol);

    for (let i = 0; i < _curCol.children.length; i++) {
        if (_curCol.children[i].getAttribute("col-resize") === "true") {
            continue;
        }
        let padding = paddingDiff(_curCol);
        applyWidthAndEllipsis(_curCol.children[i], newWidth, padding, indexOfTH);

    }
    if (_nxtCol) {
        for (let i = 0; i < _nxtCol.children.length - 1; i++) {
            if (_nxtCol.children[i].getAttribute("col-resize") === "true") {
                continue;
            }
            let padding = paddingDiff(_nxtCol);
            applyWidthAndEllipsis(_nxtCol.children[i], newWidthNextCol, padding, indexOfNextTH);
        }

    }



    let tbodyOfTable = _curCol.parentElement.parentElement;

    for (let i = 1; i < tbodyOfTable.children.length; i++) {
        let targetTD = tbodyOfTable.children[i].children[indexOfTH];
        for (k = 0; k < targetTD?.children.length; k++) {
            

            let padding = paddingDiff(targetTD);
            applyWidthAndEllipsis(targetTD.children[k], newWidth, padding, indexOfTH);
        }

        let targetTDNext = tbodyOfTable.children[i].children[indexOfNextTH];
        if (targetTDNext && _nxtCol) {
            for (k = 0; k < targetTDNext.children.length; k++) {
                
                let padding = paddingDiff(targetTDNext);
                applyWidthAndEllipsis(targetTDNext.children[k], newWidthNextCol, padding, indexOfNextTH)
            }

        }
    }
}

const paddingDiff = (col) => {

    var padLeft = getStyleVal(col, 'padding-left');
    var padRight = getStyleVal(col, 'padding-right');
    return (parseInt(padLeft) + parseInt(padRight));

}

const createDiv = (height) => {
    var div = document.createElement('div');
    div.style.top = 0;
    div.style.right = 0;
    div.style.width = '4px';
    div.style.position = 'absolute';
    div.style.cursor = 'col-resize';
    div.style.userSelect = 'none';
    div.style.height = height - 1 + 'px';
    div.style.transform = 'translateX(1px)'
    div.ondblclick = resetColumn;
    div.setAttribute("col-resize",true)
    return div;
}

const applyWidthAndEllipsis = (elem, width, padding, index) => {

    //td elements to skip

    console.log(elem.classList)

    if (elem.nodeName.toLowerCase() === "img" ||
        elem.getAttribute("type")?.toLowerCase() == "checkbox" ||
        elem.classList.contains("DateFaseII") || elem.classList.contains("Fld_Domain_label2") || elem.classList.contains("FldExtDom_button") || elem.classList.contains("FldDomainValue") || elem.classList.contains("img_label_alt") || elem.querySelector("input[type=button].FldExtDom_button") || elem.querySelector("input[type=button].Attach_button"))
 {
        return;
    }

    elem.style.whiteSpace = "nowrap";
    elem.style.overflow = "hidden";
    elem.style.textOverflow = "ellipsis";
    elem.style.padding = "0 0 0 10px";
    if (getStyleVal(elem, "display") != "none") {
        elem.style.display = "block";
    }
    elem.style.setProperty('width', (width - padding) + 'px', 'important');
    elem.style.minWidth = "unset";
    if (elem.parentElement.nodeName.toLowerCase() === "th") {
        saveGridSetup(findGridId(elem), index, (width - padding));
    }
}

const getIndexOfTH = (elemTH) => {
    if (!elemTH) {
        return -1;
    }
    for (let i = 0; i < elemTH.parentElement.children.length; i++) {
        if (elemTH.parentElement.children[i] === elemTH) {
            return i;
        }
    }

}

const resetColumn = (e) => {
    let parentTH = e.target.parentElement;
   
    let indexOfTH = getIndexOfTH(parentTH);
    let indexOfNextTH = getIndexOfTH(findNextSibling(parentTH));
    let tbodyOfTable = parentTH.parentElement.parentElement;
    let nextParentTH = indexOfNextTH != -1 ? tbodyOfTable.firstElementChild.children[indexOfNextTH] : null;

    if (parentTH) {
        parentTH.style.minWidth = "";
        for (let i = 0; i < parentTH.children.length - 1; i++) {
            parentTH.children[i].setAttribute("style", "");
        }
    }

    if (nextParentTH) {
        nextParentTH.style.minWidth = "";
        for (let i = 0; i < nextParentTH.children.length - 1; i++) {
            nextParentTH.children[i].setAttribute("style", "");
        }
    }

    for (let i = 1; i < tbodyOfTable.children.length; i++) {
        let targetTD = tbodyOfTable.children[i].children[indexOfTH];
        let targetNextTD = tbodyOfTable.children[i].children[indexOfNextTH];
        for (k = 0; k < targetTD.children.length; k++) {
            if (targetTD.children[k].nodeName.toLowerCase() === "img") {
                continue;
            }

            targetTD.children[k].setAttribute("style", "");
        }
        for (k = 0; k < targetNextTD.children.length; k++) {
            if (targetNextTD.children[k].nodeName.toLowerCase() === "img") {
                continue;
            }

            targetNextTD.children[k].setAttribute("style", "");
        }
    }

    EprocCache.setItem(`${findGridId(e.target)}_${indexOfTH}`, null);
    EprocCache.setItem(`${findGridId(e.target)}_${indexOfNextTH}`, null);



}

const getStyleVal = (elm, css) => {
    return (window.getComputedStyle(elm, null).getPropertyValue(css))
}

const saveGridSetup = (GridID, indexOfCol, width) => {
    EprocCache.setItem(`${GridID}_${indexOfCol}`, width);
}

const findGridId = (elem) => {
    let pageName = "GenericTable";
    if (document.getElementsByClassName('pageTitle').length > 0) {
        try {
            pageName = document.getElementById('page-content-wrapper').getElementsByClassName('pageTitle')[0].getElementsByTagName('td')[1].innerText;
        } catch (e) { }
    } else {
            pageName = (!!elem.closest(".detail") ? elem.closest(".detail").id : "GenericTable")
    }
    return pageName + "_" + elem.closest(".Grid").id;
}

const findNextSibling = (elem) => {
    if (elem.nextElementSibling) {
        if (getStyleVal(elem.nextElementSibling, "display") != "none") {
            return elem.nextElementSibling;
        } else {
            return findNextSibling(elem.nextElementSibling)
        }
    } else {
        return null;
    }
    
    return null;
}

const findLastSibling = (elem) => {
    let runningElem = elem;
    let elemToReturn = null;
    while (runningElem) {
        runningElem = runningElem.nextElementSibling;
        if (runningElem && getStyleVal(runningElem, "display") != "none") {
            elemToReturn = runningElem;
        }
    }
    return elemToReturn;
}

const initializeResizableGrids = () => {
    let listOfGrids = document.getElementsByClassName("Grid");
    for (let i = 0; i < listOfGrids.length; i++) {
        let grid = listOfGrids[i];
        if (grid.offsetWidth == 0) {
            grid.addEventListener("mouseenter", () => { resizableGrid(grid) })
        } else {
            resizableGrid(grid)
        }

        let firstTR = grid.getElementsByTagName("tr")[0];
        firstTR.addEventListener("mouseenter", () => { try { $(document.getElementById(grid.id).tBodies).sortable("disable"); } catch { } })
        let nCols = firstTR?.childElementCount;
        for (let colIndex = 0; colIndex < nCols; colIndex++) {
            let width = (EprocCache.getItem(`${findGridId(grid)}_${colIndex}`))
            if (!!width) {
                let x = width - firstTR.children[colIndex].offsetWidth + paddingDiff(firstTR.children[colIndex]);
                applyWidthToCol(firstTR.children[colIndex], firstTR.children[colIndex].offsetWidth, x, null, null)
            } else {
                if (firstTR.children[colIndex].offsetWidth != 0) {
                    let x = + paddingDiff(firstTR.children[colIndex]);
                    applyWidthToCol(firstTR.children[colIndex], firstTR.children[colIndex].offsetWidth, x, null, null)
                }
            }
        }
    }
}

const OnPageContentWrapperScroll = (e) =>{

    
    try {
        var Y = '0';
        var str = document.location.pathname;
        var PATH_LEVEL_NAVIGATION = getObjValue('PATH_LEVEL_NAVIGATION');

        if (str.toLowerCase().indexOf('document.asp') >= 0) {
            var Y = e.target.scrollTop;
        }

        setCookie2('PATH_LEVEL_Y_' + PATH_LEVEL_NAVIGATION, Y);

        //-- svuota il livello successivo per evitare un effetto collaterale
        PATH_LEVEL_NAVIGATION = parseInt(PATH_LEVEL_NAVIGATION) + 1;
        setCookie2('PATH_LEVEL_Y_' + PATH_LEVEL_NAVIGATION, '0');

    } catch (e) { };



}


//-- recupera dal cookie l'ultima posizione della scroll e la ripristina
const SetLastScrollWindowFaseII = (target) => {
    try {
        var str = document.location.pathname;

        //-- prendo il livello corrente
        var PATH_LEVEL_NAVIGATION = getObjValue('PATH_LEVEL_NAVIGATION')

        var Y = getCookie('PATH_LEVEL_Y_' + PATH_LEVEL_NAVIGATION);

        if (Y != '0') {
            if (str.toLowerCase().indexOf('document.asp') >= 0) {
                try { target.scrollTop = Y; target.scrollTop = Y; } catch (e) { }
            }
        }

        //-- svuoto quello successivo per evitar che aprendo un documento differente mi posiziono erroneamente
        PATH_LEVEL_NAVIGATION = parseInt(PATH_LEVEL_NAVIGATION) + 1;
        setCookie2('PATH_LEVEL_Y_' + PATH_LEVEL_NAVIGATION, '0');


    } catch (e) { }


}

const hideFldExtDom_buttons = () => {
    let FldExtDom_buttons = FormViewerFiltro.getElementsByClassName("FldExtDom_button");
    for (let i = 0; i < FldExtDom_buttons.length; i++) {
        if (window.getComputedStyle(FldExtDom_buttons[i]).position === "absolute") {
            FldExtDom_buttons[i].setAttribute("forced-position-unset", "true");
            FldExtDom_buttons[i].style = "position:unset";
        }
    }
}

const showFldExtDom_buttons = () => {
    let FldExtDom_buttons = FormViewerFiltro.getElementsByClassName("FldExtDom_button");
    for (let i = 0; i < FldExtDom_buttons.length; i++) {
        if (FldExtDom_buttons[i].getAttribute("forced-position-unset") === "true") {
            FldExtDom_buttons[i].style = "";
            FldExtDom_buttons[i].setAttribute("forced-position-unset", "false");
        }
    }
}

const initializeGroup_WinFilter = () => {
    let FormViewerFiltro = document.getElementById("FormViewerFiltro");
    if (!FormViewerFiltro) {
        return;
    }
    let Group_WinFilter = document.getElementById("Group_WinFilter");
    if (Group_WinFilter) {
        if (getStyleVal(Group_WinFilter, "display") == "none") {
            Group_WinFilter.style.display = "unset";
        }
    } else {
        
        //try {
        //    if (window.location.href.toLowerCase().indexOf("cube.asp")) {
        //        return;
        //    }
        //} catch (e) {

        //}
    }

    let closed = EprocCache.getItem(`Group_WinFilter`) == "closed";

    let heightFormViewerFiltro = FormViewerFiltro.offsetHeight + 34;
    if (heightFormViewerFiltro === 34) {
        return;
    }
    if (closed) {
        FormViewerFiltro.style = `height:33px; overflow-y: hidden;`; 
        hideFldExtDom_buttons();
    } else {
        FormViewerFiltro.style = `height:   ${heightFormViewerFiltro}px; overflow-y: hidden;`; 
    }

    let table1 = document.createElement("table");
    table1.classList.add("SinteticHelp_Tab");
    table1.classList.add("searchAreaGroup_WinFilter");
    table1.classList.add("pointer");
    let tbody1 = document.createElement("tbody");
    let tr1 = document.createElement("tr");
    let td1 = document.createElement("td");
    let span1 = document.createElement("span");
    span1.textContent = "Filtri di ricerca";
    span1.classList.add("spanSearchAreaGroup_WinFilter")
    let td2 = document.createElement("td");
    td2.classList.add("nowrap");
    td2.classList.add("SinteticHelp_label");
    td2.classList.add("tdSearchAreaGroup_WinFilter");
    td2.setAttribute("id", "_label");
    let icon1 = document.createElement("icon");
    icon1.setAttribute("id", "accordionGroup_WinFilter");
    icon1.classList.add("fa");
    if (closed) {
        icon1.classList.add("fa-chevron-right");
    } else {
        icon1.classList.add("fa-chevron-up");

    }

    td2.appendChild(icon1);
    td2.appendChild(span1);
    //td1.appendChild(img1);
    tr1.appendChild(td1);
    tr1.appendChild(td2);
    tbody1.appendChild(tr1);
    table1.appendChild(tbody1);

    //<table class="SinteticHelp_Tab">
    //    <tbody>
    //        <tr>
    //            <td></td>
    //            <td class="nowrap SinteticHelp_label pointer" id="_label">Filtri di ricerca
    //                <icon id="accordionGroup_WinFilter" class="fa fa-chevron-down"></icon>
    //            </td>
    //        </tr>
    //    </tbody>
    //</table>

    let SinteticHelp_TabFound = FormViewerFiltro.getElementsByClassName("SinteticHelp_Tab");
    if (SinteticHelp_TabFound && SinteticHelp_TabFound[0]) {
        let firstTableFound = FormViewerFiltro.getElementsByTagName("tbody");
        SinteticHelp_TabFound[0].replaceWith(table1);
        if (firstTableFound && firstTableFound[0]) {
            firstTableFound[0].classList.add("firstTableFound");
        }
    } else {
        let firstTableFound = FormViewerFiltro.getElementsByTagName("tbody");
        if (firstTableFound && firstTableFound[0]) {
            firstTableFound[0].classList.add("firstTableFound");
            let tr_ = document.createElement("tr");
            tr_.appendChild(table1);
            firstTableFound[0].insertBefore(tr_, firstTableFound[0].firstChild);
        }
    }

    let listOfTextareas = FormViewerFiltro.getElementsByTagName("textarea");
    for (let i = 0; i < listOfTextareas.length; i++) {

        listOfTextareas[i].addEventListener('mousemove', function () {
            
            if (listOfTextareas[i].clientHeight > 100) {
                FormViewerFiltro.style = `height:   ${heightFormViewerFiltro + (listOfTextareas[i].currentHeight - 100) }px;`
            }

        });
    }

    table1.onclick = () => {
        if (EprocCache.getItem(`Group_WinFilter`) == "closed") {
            EprocCache.setItem(`Group_WinFilter`, "opened");
            FormViewerFiltro.style = `transition:0.2s all; height:   ${heightFormViewerFiltro}px; overflow-y: hidden;`;
            icon1.classList.replace("fa-chevron-right", "fa-chevron-up");
            showFldExtDom_buttons();
        } else {
            heightFormViewerFiltro = FormViewerFiltro.offsetHeight;
            EprocCache.setItem(`Group_WinFilter`, "closed");
            FormViewerFiltro.style = `transition:0.2s all; height:                               33px; overflow-y: hidden;`; 
            icon1.classList.replace("fa-chevron-up", "fa-chevron-right");
            hideFldExtDom_buttons();
        }
    }
}