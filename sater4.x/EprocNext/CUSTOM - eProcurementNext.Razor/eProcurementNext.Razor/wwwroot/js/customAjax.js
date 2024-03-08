const LoadMenuSX = (data, saveGroups) => {
    let menusx = document.getElementById("menu");
    menusx.innerHTML = "";
    let dataParsed = JSON.parse(data)
    for (const element of dataParsed) {
        let item = MenuElement(element);
        menusx.appendChild(item);
        $("#loader").hide();
    }
    if (saveGroups) {
        menusxGroups = dataParsed;
    }
}

const MenuElement = (item) => {

    let openedGroup = getCookieV2("openGroup");

    const { id, title, subGroupList } = item;
    let dropdownvapor = document.createElement("li");
    dropdownvapor.classList.add("dropdownvapor");
    if (id === openedGroup) {
        dropdownvapor.classList.add("active");
    }
    let ahref = document.createElement("a");
    ahref.href = "#";
    ahref.id = id;
    let span1 = document.createElement("span");
    span1.classList.add("fa-stack");
    span1.classList.add("fa-lg");
    span1.classList.add("pull-left");
    let spanTitle = document.createElement("span");
    spanTitle.className = "textMenu";
    spanTitle.innerText = title;
    let span2 = document.createElement("span");
    span2.classList.add("arrow-right");
    let i1 = document.createElement("i");
    i1.classList.add("fa");
    i1.classList.add("fa-th-list"); //placeholder se non specificata
    i1.classList.add("fa-stack-1x");
    let i2 = document.createElement("i");
    i2.classList.add("fa");
    i2.classList.add("fa-angle-right");
    i2.ariaHidden = true;

    let ul = document.createElement("ul");
    ul.classList.add("submenuvapor");
    for (const element of subGroupList) {
        const { link, title } = element;
        let li1 = document.createElement("li");
        let ahref1 = document.createElement("a");
        ahref1.href = "#";
        ahref1.innerText = title;
        ahref1.setAttribute("onclick", `Javascript:${link};return false;`);
        ahref1.classList.add("custom")
        ahref1.classList.add("submenuvapor_item");
        li1.appendChild(ahref1);
        ul.appendChild(li1);
    }
    span1.appendChild(i1);
    span2.appendChild(i2);
    ahref.appendChild(span1);
    ahref.appendChild(spanTitle);
    ahref.appendChild(span2);
    dropdownvapor.appendChild(ahref);
    dropdownvapor.appendChild(ul);

    return dropdownvapor;
}

const HandleMenuSXChange = (e) => {
    const menusxGroupsFiltered = (e.target.value != null && menusxGroups) ? menusxGroups.filter((obj) => JSON.stringify(obj).toLowerCase().includes(e.target.value.toLowerCase())) : menusxGroups;
    LoadMenuSX(JSON.stringify(menusxGroupsFiltered), false)
}


// POPOLO ATTIVITA RECENTI //

const HandleButtonRecentActivityClick = (e) => {

    closeDrawer();
    openDrawer(``, false, "Recenti", "Gestione delle Attività Recenti", false, false, false, false)

    let url = `/api/${apiVersion}/UserHistory`;
    EprocRequest("GET", url, null, null, (err, data) => {
        if (err) { throw err; }
        data = JSON.parse(data);
        if (data.result?.length != 0) {
            containerRightArea.innerHTML = `
                <div class="input-group search-recent">
                    <input id="recentSearch" oninput="HandleRecentActivityChange(this)" type="text" class="form-control" placeholder="Cerca tra i recenti" aria-label="" aria-describedby="basic-addon1">
                    <div class="input-group-append">
                        <button class="btn input-group-btn" type="button"><i class="fa fa-search"></i></button>
                    </div>
                </div>
                <div id="deleteActivity" class="divider"></div>`;
        }

        if (data.status != "OK") {
            console.error(data.result);
            $("#loader").hide();
        } else {
            LoadRecentActivity(JSON.stringify(data.result), true);
        }
    })

}

const HandleRecentActivityChange = (e) => {
    console.log(e);
    const recentActivityFiltered = (e.value != null && recentActivityList) ? recentActivityList.filter((obj) => JSON.stringify(obj).toLowerCase().includes(e.value.toLowerCase())) : recentActivityList;
    LoadRecentActivity(JSON.stringify(recentActivityFiltered), false)
}

const littleStarClick = (id, isFavorite, thisObject) => {
    console.log(id)
    let url = `/api/${apiVersion}/UserHistory/AddFavorite`;
    let params = {
        "Id": `${id}`,
        "Link": "",
        "Title": "",
		"Breadcrumb": "",
		"Date": "",
        "IsFavorite": !isFavorite
    }
    EprocRequest("POST", url, null, params, (err, data) => {
        data = JSON.parse(data);
        if (data.status != "OK") {
            console.error(data.result);
            $("#loader").hide();
        } else {
            $("#loader").hide();
            thisObject.classList.remove("fa-star");
            thisObject.classList.remove("fa-star-o");
            if (isFavorite) {
                thisObject.classList.add("fa-star-o");
                let newOnClick = thisObject.getAttribute("onclick").replace("true", "false");
                thisObject.setAttribute("onclick", newOnClick);
            } else {
                thisObject.classList.add("fa-star");
                let newOnClick = thisObject.getAttribute("onclick").replace("false", "true");
                thisObject.setAttribute("onclick", newOnClick);
            }
        }
    })

}

const littleTrashUserHistoryClick = (id) => {
    
    let url = `/api/${apiVersion}/UserHistory/UserHistoryItem`;
    let params = { "id": `${id}` }
    EprocRequest("DELETE", url, null, params, (err, data) => {
        data = JSON.parse(data);
        if (data.status != "OK") {
            console.error(data.result);
            $("#loader").hide();
        } else {
            HandleButtonRecentActivityClick();
        }
    })

}

const littleTrashFavoriteClick = (id) => {
    let url = `/api/${apiVersion}/UserHistory/AddFavorite`;
    let params = {
        "Id": `${id}`,
        "Link": "",
        "Title": "",
        "Breadcrumb": "",
        "Date": "",
        "IsFavorite": false
    }
    EprocRequest("POST", url, null, params, (err, data) => {
        data = JSON.parse(data);
        if (data.status != "OK") {
            console.error(data.result);
            $("#loader").hide();
        } else {
            HandleButtonBookmarksClick();
        }
    })
}

const LoadRecentActivity = (data, saveRecentActivity) => {
    let domain = window.location.origin;
    let dataParsed = JSON.parse(data);
    let containerRightArea = document.getElementById("containerRightArea");
    let deleteActivity = document.getElementById("deleteActivity");

    //svuoto l'elenco lasciando i button
    let elementsToRemove = containerRightArea.getElementsByClassName("recentActivityRow");
    let elementsToRemoveLength = elementsToRemove.length;
    for (let i = 0; i < elementsToRemoveLength; i++) {
        elementsToRemove[0].remove();
    }

    for (let i = 0; i < dataParsed.length; i++) {
        const { id, link, title, breadcrumb, date, isFavorite } = dataParsed[i];
        let div1 = document.createElement("div");
        div1.classList.add("recentActivityRow");
        div1.classList.add("row");
        div1.classList.add("divider");
        div1.classList.add("pt-3");
        div1.classList.add("pb-3");
        div1.innerHTML = `
            <div class="col-12 flex">
                <div class="col-1 favoriteIcon">
                    <i class="fa littleStar ${isFavorite ? "fa-star" : "fa-star-o"}" onclick="littleStarClick(${id}, ${isFavorite}, this)" aria-hidden="true"></i>
                </div>
                <div class="col-8">
                <p><b>${title}</b></p>
                <a href="${domain}/${link}"><p class="breadcrumbActivity">${breadcrumb}</p></a>
                </div>
                <div class="col-2 text-right">
                    <p class="timeActivity"><small>${date}</small></p>
                </div>
                <div class="col-1 favoriteIcon">
                    <i class="fa littleTrash fa-trash" onclick="littleTrashUserHistoryClick(${id})" aria-hidden="true"></i>
                </div>
            </div>`;
        containerRightArea.appendChild(div1);
    }

    if (dataParsed?.length === 0) {
        let emptyDiv = document.createElement("div");
        emptyDiv.setAttribute("style", "height: 30vh")
        emptyDiv.innerHTML = emptyStateDrawer("Nessun recente trovato");
        containerRightArea.appendChild(emptyDiv);
    }

    let buttonToDelete = document.getElementById("buttonDeleteRecent");
    buttonToDelete && buttonToDelete.remove();
    let button1 = document.createElement("button");
    let icona = document.createElement("i");
    button1.id = "buttonDeleteRecent";
    button1.classList.add("tertiary-button");
    button1.classList.add("toRight");
    button1.classList.add("custom-modal");
    button1.setAttribute ("data-toogle", "modal");
    button1.setAttribute("data-target", "#modalDelete");
    let contenutoModale = {
        title: "Conferma eliminazione",
        text: "Sei sicuro di voler eliminare i recenti?",
        callbackConfirm: HandleClickDeleteAllUserHistory
    }
    button1.onclick = function () { ModalDelete(contenutoModale) };
    button1.innerText = "cancella tutti i recenti";
    let iconToDelete = document.getElementById("trashButtonDeleteRecent");
    iconToDelete && iconToDelete.remove();
    icona.id = "trashButtonDeleteRecent";
    icona.classList.add("fa");
    icona.classList.add("fa-trash");
    icona.classList.add("pr-1");
    icona.style.color = "var(--main-color)";
    if (dataParsed.length != 0) {
        deleteActivity.appendChild(button1);
        deleteActivity.appendChild(icona);
    }
    if (saveRecentActivity) {
        recentActivityList = dataParsed;
    }
}

const HandleClickDeleteAllUserHistory = () => {
    //cancella tutti i recenti e anche tutti i favoriti
    let url = `/api/${apiVersion}/UserHistory`;
    EprocRequest("DELETE", url, null, null, (err, data) => {
        if (err) { throw err; }
        data = JSON.parse(data);
        if (data.status != "OK") {
            console.error(data.result);
        } else {
            console.log(data.result)
            HandleButtonRecentActivityClick();
        }
    })
}

// POPOLO PREFERITI //

const HandleButtonBookmarksClick = (e) => {
    closeDrawer();
    openDrawer(``, false, "Bookmarks", "Gestione dei Preferiti", false, false, false, false)

    let url = `/api/${apiVersion}/UserHistory/Favorites`;
    EprocRequest("GET", url, null, null, (err, data) => {
        if (err) { throw err; }
        data = JSON.parse(data);
        if (data.result?.length != 0) {
            containerRightArea.innerHTML = `
                <div class="input-group search-recent">
                    <input id="bookmarksSearch" oninput="HandleBookmarksChange(this)" type="text" class="form-control" placeholder="Cerca tra i preferiti" aria-label="" aria-describedby="basic-addon1">
                    <div class="input-group-append">
                        <button class="btn input-group-btn" type="button"><i class="fa fa-search"></i></button>
                    </div>
                </div>
                <div id="deleteBookmarks" class="divider"></div>`;
        }
        if (data.status != "OK") {
            console.error(data.result);
            $("#loader").hide();
        } else {
            LoadBookmarks(JSON.stringify(data.result), true);

        }
    })
}

const HandleBookmarksChange = (e) => {
    console.log(e);
    const bookmarksFiltered = (e.value != null && bookmarksList) ? bookmarksList.filter((obj) => JSON.stringify(obj).toLowerCase().includes(e.value.toLowerCase())) : bookmarksList;
    LoadBookmarks(JSON.stringify(bookmarksFiltered), false)
}

const LoadBookmarks = (data, saveBookmarks) => {
    let domain = window.location.origin;
    let dataParsed = JSON.parse(data);
    let containerRightArea = document.getElementById("containerRightArea");
    let deleteBookmarks = document.getElementById("deleteBookmarks");

    //svuoto l'elenco lasciando i button
    let elementsToRemove = containerRightArea.getElementsByClassName("bookmarksRow");
    let elementsToRemoveLength = elementsToRemove.length;
    for (let i = 0; i < elementsToRemoveLength; i++) {
        elementsToRemove[0].remove();
    }
    
    for (let i = 0; i < dataParsed.length; i++) {
        const { id, link, title, breadcrumb, date } = dataParsed[i];
        let div1 = document.createElement("div");
        div1.classList.add("bookmarksRow");
        div1.classList.add("row");
        div1.classList.add("divider");
        div1.classList.add("pt-3");
        div1.classList.add("pb-3");
        div1.innerHTML = `
            <div class="col-12 flex">
                <div class="col-9">
                <p><b>${title}</b></p>
                <a href="${domain}/${link}"><p class="breadcrumbActivity">${breadcrumb}</p></a>
                </div>
                <div class="col-2 text-right">
                    <p class="timeActivity"><small>${date}</small></p>
                </div>
                <div class="col-1 favoriteIcon">
                    <i class="fa littleTrash fa-trash" onclick="littleTrashFavoriteClick(${id})" aria-hidden="true"></i>
                </div>
            </div>
        `;
        containerRightArea.appendChild(div1);
    }

    if (dataParsed?.length === 0) {
        let emptyDiv = document.createElement("div");
        emptyDiv.setAttribute("style", "height: 30vh")
        emptyDiv.innerHTML = emptyStateDrawer("Nessun bookmark trovato");
        containerRightArea.appendChild(emptyDiv);
    }

    let buttonToDelete = document.getElementById("buttonDeleteBookmarks");
    buttonToDelete && buttonToDelete.remove();

    let button1 = document.createElement("button");
    let icona = document.createElement("i");
    button1.id = "buttonDeleteBookmarks";
    button1.classList.add("tertiary-button");
    button1.classList.add("toRight");
    button1.classList.add("custom-modal");
    button1.setAttribute("data-toogle", "modal");
    button1.setAttribute("data-target", "#modalDelete");
    let contenutoModale = {
        title: "Conferma eliminazione",
        text: "Sei sicuro di voler eliminare i favoriti?",
        callbackConfirm: HandleClickDeleteAllFavorites
    }
    button1.onclick = function () { ModalDelete(contenutoModale) };
    button1.innerText = "cancella tutti i favoriti";
    let iconToDelete = document.getElementById("trashButtonDeleteBookmarks");
    iconToDelete && iconToDelete.remove();
    icona.id = "trashButtonDeleteBookmarks";
    icona.classList.add("fa");
    icona.classList.add("fa-trash");
    icona.classList.add("pr-1");
    icona.style.color = "var(--main-color)";
    if (dataParsed.length != 0) {
        deleteBookmarks.appendChild(button1);
        deleteBookmarks.appendChild(icona);
    }
    if (saveBookmarks) {
        bookmarksList = dataParsed;
    }
}


const HandleClickDeleteAllFavorites = () => {
    //cancella tutti i favoriti
    let url = `/api/${apiVersion}/UserHistory/Favorites`;
    EprocRequest("DELETE", url, null, null, (err, data) => {
        if (err) { throw err; }
        data = JSON.parse(data);
        if (data.status != "OK") {
            console.error(data.result);
        } else {
            console.log(data.result)
            HandleButtonBookmarksClick();

        }
    })
}

// POPOLO INFO USER //

const HandleButtonUserAreaClick = (e) => {

    //let url = `/api/${apiVersion}/UserInfo`;
    closeDrawer();
    openDrawer(`<div class="iframeRightAreaContain">
            <iframe
                class="iframeRightArea"
                src="${pathRoot}ctl_library/document/UserInfo?type=utente" 
                title="Area Utente">
            </iframe>
            </div>`,false,"Info Utente", "Visualizza Info Utente", false, false, false, false)
    
    /*containerRightArea.innerHTML = "";*/
    
    //EprocRequest("GET", url, null, null, (err, data) => {
    //    if (err) { throw err; }
    //    data = JSON.parse(data);
    //    if (data.status != "OK") {
    //        console.error(data.result);
    //        $("#loader").hide();
    //    }

    //    const result = JSON.parse(data.result);
    //    //Dati User
    //    const {
    //        Nome: UserNome,
    //        RuoloAziendale: UserRuoloAziendale,
    //        E_Mail: UserE_Mail,
    //        Tel: UserTel,
    //        CodiceFiscale: UserCodiceFiscale,
    //        LastLogin: UserLastLogin,
    //        DataCreazione: UserDataCreazione
    //    } = result;

    //    console.log(UserNome);
    //    console.log(UserE_Mail);
    //    containerRightArea.innerHTML = `
    //                            <div class="col-12">
    //                                <div class="card">
    //                                    <div class="card-body">
    //                                        <div class="col-12 flex">
    //                                                <i class="fa fa-user-o mr-3 iconBackgroundGreyRounded" aria-hidden="true" style="color: var(--main-header-menu-color)"></i><h5>${UserNome}</h5>
    //                                                <span class="chip ml-2"><small>${UserRuoloAziendale}</small></span>
    //                                                <a id="userLogout" href="#logout" onclick="logout();" class="link_logout">
    //                                                    <button type="button" aria-haspopup="true" aria-expanded="false" class="btn btn-link rounded-circle">
    //                                                    <span>
    //                                                        <i class="fa fa-sign-out mr-3" aria-hidden="true"></i>
    //                                                    </span>
    //                                                    </button>
    //                                                </a>
    //                                        </div>
    //                                        <div class="col-12">
    //                                            <p><small><i>Ultimo Accesso ${UserLastLogin}</i></small></p>
    //                                        </div>
    //                                        <div class="row p-3">
    //                                            <div class="col-6"><p><i class="fa fa-phone pr-2" aria-hidden="true"></i> Telefono: <b>${UserTel}</b></p></div>
    //                                            <div class="col-6"><p><i class="fa fa-id-card-o pr-2" aria-hidden="true"></i> Codice Fiscale: <b>${UserCodiceFiscale}</b></p></div>
    //                                        </div>
    //                                    </div>
    //                                    <div class="card-footer">
    //                                       <div class="row">
    //                                            <div class="col-6"><p>Nome utente: <b>${UserNome}</b></p></div>
    //                                            <div class="col-6"><p>Email: <a href="mailto:${UserE_Mail}"><b>${UserE_Mail}</b></a></p></div>
    //                                       </div>
    //                                    </div>
    //                                </div>
    //                            </div>
    //                            <div class="line-divider"></div>`
    //})
    

}

const HandleButtonUserUtilityClick = (e) => {

    closeDrawer();
    //let containerToolbarButton = document.getElementById("containerToolbarButton");
    

    //let urlToolbar = `/api/${apiVersion}/layout/toolbarButtons`;
    //EprocRequest("GET", urlToolbar, null, null, (err, data) => {
    //    if (err) { throw err; }
    //    data = JSON.parse(data);
    //    if (data.status != "OK") {
    //        console.error(data.result);
    //        $("#loader").hide();
    //    } else {
    //        let toolbarButtons = "";
    //        for (const element of data.result) {
    //            const { id, onClick, title, url, enabled, value } = element
    //            if (value != "") {
    //                toolbarButtons
    //                    += `<a id="${id}" href="${url}" onclick="${onClick}" class="mr-2"> <button type="button" aria-haspopup="true" aria-expanded="false" class="btn btn-link primary-button" style="border-radius:0; line-height:0;" title="${title}"> <span>${value} </span> </button> </a>`
    //            }
    //        }
    //        containerToolbarButton.innerHTML
    //            = `<div class="row">
    //                        <div class="col-12 d-flex pt-2 containerToolbarButton">
    //                            ${toolbarButtons}
    //                        </div>
    //                    </div>`;
    //    }
    //});

    let url = `/api/${apiVersion}/UserInfo`;
    EprocRequest("GET", url, null, null, (err, data) => {

        if (err) { throw err; }
        data = JSON.parse(data);
        if (data.status != "OK") {
            console.error(data.result);
            $("#loader").hide();
        }

        const result = JSON.parse(data.result);
        //Dati User
        const {
            Nome: UserNome,
            RuoloAziendale: UserRuoloAziendale,
            E_Mail: UserE_Mail,
            Tel: UserTel,
            CodiceFiscale: UserCodiceFiscale,
            LastLogin: UserLastLogin,
            DataCreazione: UserDataCreazione
        } = result;

        console.log(UserNome);
        console.log(UserE_Mail);
        openDrawer(`<div class="col-12">
                                    <div class="card">
                                        <div class="card-body">
                                            <div class="col-12 flex">
                                                    <i class="fa fa-user-o mr-3 iconBackgroundGreyRounded" aria-hidden="true" style="color: var(--main-header-menu-color)"></i>
                                                    <h5>${UserNome}</h5>
                                                    
                                                    <a id="userLogout" href="#logout" onclick="Javascript:try{ CloseAllSub( 'TOOLBAR_HOMELIGHT' ); }catch(e){};NewDocumentAndReset( 'CHANGE_PWD');return false;" class="link_logout toRight">
                                                        <button type="button" aria-haspopup="true" aria-expanded="false" class="btn btn-link rounded-circle">
                                                        <span>
                                                        Cambio Password
                                                            <i class="fa fa-key mr-3" aria-hidden="true"></i>
                                                        </span>
                                                        </button>
                                                    </a>
                                                    <a id="userLogout" href="#logout" onclick="logout();" class="link_logout">
                                                        <button type="button" aria-haspopup="true" aria-expanded="false" class="btn btn-link rounded-circle">
                                                        <span>
                                                        Logout
                                                            <i class="fa fa-sign-out mr-3" aria-hidden="true"></i>
                                                        </span>
                                                        </button>
                                                    </a>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="line-divider"></div>
                                <div class="iframeRightAreaContain">
                                    <iframe
                                        class="iframeRightArea iframeHeight70"
                                        src="${pathRoot}ctl_library/document/UserInfo?type=utente" 
                                        title="Area Azienda">
                                    </iframe>
                               </div>

                                `, false, "Utility Utente", "Configura le info Utente", false, false, false, false)


    })


}

// POPOLO WORKSPACE AZIENDA //
const WriteButtonWorkspace = (e) => {

    let url = `/api/${apiVersion}/UserInfo`;

    EprocRequest("GET", url, null, null, (err, data) => {
        if (err) { throw err; }
        data = JSON.parse(data);
        if (data.status != "OK") {
            console.error(data.result);
            $("#loader").hide();
        }

        const result = JSON.parse(data.result);
        //Dati User
        const {
            AziendaAssociata: {
                RagioneSociale: AziRagioneSociale,
                DataCreazione: AziDataCreazione,
                PartitaIva: AziPartitaIva,
                E_Mail: AziE_Mail,
                IndirizzoLeg: AziIndirizzoLeg,
                LocalitaLeg: AziLocalitaLeg,
                ProvinciaLeg: AziProvinciaLeg,
                StatoLeg: AziStatoLeg,
                CapLeg: AziCapLeg,
                SitoWeb: AziSitoWeb
            }
        } = result;

        $("#buttonWorkspace").find(".nomeAziendaHeader").html(AziRagioneSociale);
    })


}

const HandleButtonWorkspaceClick = (e) => {

    closeDrawer();
    openDrawer(`<div class="iframeRightAreaContain">
                <iframe 
                    class="iframeRightArea"
                    src="${pathRoot}ctl_library/document/UserInfo?type=azi" 
                    title="Area Azienda">
                </iframe>
           </div>`, false, "Info Azienda", "Gestione delle Info Azienda", false, false, false, false)


    //let url = `/api/${apiVersion}/UserInfo`;
    
    //containerRightArea.innerHTML = "";
    //EprocRequest("GET", url, null, null, (err, data) => {
    //    if (err) { throw err; }
    //    data = JSON.parse(data);
    //    if (data.status != "OK") {
    //        console.error(data.result);
    //        $("#loader").hide();
    //    }

    //    const result = JSON.parse(data.result);
    //    //Dati User
    //    const {
    //        AziendaAssociata: {
    //            RagioneSociale: AziRagioneSociale,
    //            DataCreazione: AziDataCreazione,
    //            PartitaIva: AziPartitaIva,
    //            E_Mail: AziE_Mail,
    //            IndirizzoLeg: AziIndirizzoLeg,
    //            LocalitaLeg: AziLocalitaLeg,
    //            ProvinciaLeg: AziProvinciaLeg,
    //            StatoLeg: AziStatoLeg,
    //            CapLeg: AziCapLeg,
    //            SitoWeb: AziSitoWeb
    //        }
    //    } = result;

    //    containerRightArea.innerHTML = `
    //                            <div class="col-12">
    //                                <div class="card">
    //                                    <div class="card-body">
    //                                        <div class="col-12 flex">
    //                                                <i class="fa fa-building-o mr-3 iconBackgroundGreyRounded" aria-hidden="true" style="color: var(--main-header-menu-color)"></i><h5>${AziRagioneSociale}</h5>
    //                                        </div>
    //                                        <div class="col-12">
    //                                            <p><small><i>Data Creazione: ${AziDataCreazione}</i></small></p>
    //                                        </div>
    //                                        <div class="row p-3">
    //                                            <div class="col-6"><p><i class="fa fa-map-marker pr-2" aria-hidden="true"></i>Indirizzo: <b>${AziIndirizzoLeg}<br/>${AziLocalitaLeg} ${AziProvinciaLeg} - ${AziCapLeg}</b></p></div>
    //                                            <div class="col-6"><p><i class="fa fa-envelope pr-2" aria-hidden="true"></i> Email: <a href="mailto: ${AziE_Mail}"><b>${AziE_Mail}</b></a></p></div>
    //                                        </div>
    //                                    </div>
    //                                    <div class="card-footer">
    //                                       <div class="row">
    //                                            <div class="col-6"><p><i class="fa fa-id-card-o pr-2" aria-hidden="true"></i> PI/CF: <b>${AziPartitaIva}</b></p></div>
    //                                            <div class="col-6"><p><i class="fa fa-globe pr-2" aria-hidden="true"></i> Sito web: <a href="${AziSitoWeb}" target="_blank"><b>${AziSitoWeb}</b></a></p></div>
    //                                       </div>
    //                                    </div>
    //                                </div>
    //                            </div>
    //                            <div class="line-divider"></div>
    //                            <div id="bottomButtonsContainer" class="row p-3">
    //                                <div class="col-12 flex">
    //                                    <button id="goOutDrawerWorkspace" class="tertiary-button toRight"><i class="fa fa-external-link pr-2" aria-hidden="true"></i> Vai alla Sezione Azienda</button>
    //                                    <button id="cancelDrawerWorkspace" class="secondary-button toRight">Annulla</button>
    //                                    <button id="saveDrawerWorkspace" class="primary-button toRight">Conferma</button>
    //                                </div>
    //                            </div>`;

    //    $("#buttonWorkspace").find(".nomeAziendaHeader").html(AziRagioneSociale);
    //})


    

}

// POPOLO Notifiche //

const HandleButtonNotifyClick = (e) => {
    closeDrawer();
    openDrawer(``, false, "Notifiche", "Gestione delle Notifiche", false, false, false, false)


    let url = `/api/${apiVersion}/UserHistory/Notify`;

    EprocRequest("GET", url, null, null, (err, data) => {
        containerRightArea.innerHTML = "";
        if (err) { throw err; }
        data = JSON.parse(data);
        if (data.status != "OK") {
            console.error(data.result);
            $("#loader").hide();
        } else {

            LoadNotify(data.result)

        }
    })
}

const LoadNotify = (dataParsed) => {
    console.table(dataParsed);
    for (let i = 0; i < dataParsed.length; i++) {
        const { id, oggetto, data, obbligatory } = dataParsed[i];
        console.log(i, id, oggetto, data, obbligatory)
        let div1 = document.createElement("div");
        div1.classList.add("notifyRow");
        div1.classList.add("row");
        div1.classList.add("divider");
        div1.classList.add("pt-3");
        div1.classList.add("pb-3");
        div1.innerHTML = `
            <div class="col-12 flex">
                <div class="col-9">
                <p><b>${oggetto}</b></p>
                </div>
                <div class="col-2 text-right">
                    <p class="timeActivity"><small>${data}</small></p>
                </div>
            </div>
        `;
        containerRightArea.appendChild(div1);

    }


    if (dataParsed?.length === 0) {
        let emptyDiv = document.createElement("div");
        emptyDiv.setAttribute("style", "height: 30vh")
        emptyDiv.innerHTML = emptyStateDrawer("Nessuna notifica trovata");
        containerRightArea.appendChild(emptyDiv);
    }


}


const initializeDragAndDrop = () => {
    /* drag n drop gruppo sx*/
    let widgetContainer = document.getElementsByClassName("widget-container")[0];
    if (!widgetContainer) {
        return;
    }
    widgetContainer.ondragover = (ev) => { ev.preventDefault(); }
    widgetContainer.ondrop = (ev) => {

        widgetContainer.style.position = "";
        let div1 = widgetContainer.getElementsByClassName("dropHere");
        if (div1?.[0]) {
            widgetContainer.removeChild(div1?.[0]);
        }


        //console.log(ev.dataTransfer.getData("id"))
        //console.log(ev.dataTransfer.getData("icona"))
        //console.log(ev.dataTransfer.getData("titolo"))
        let listOfLi = JSON.parse(ev.dataTransfer.getData("submenuvapor"));
        console.log(listOfLi)
        let subGroupList = [];
        for (let i = 0; i < listOfLi.length; i++) {
            subGroupList.push({
                title: listOfLi[i].title,
                link: listOfLi[i].onclick,
            })
        }

        let url = `/api/${apiVersion}/Layout/AddWidgetGroup`;
        let id = ev.dataTransfer.getData("id");
        let titolo = ev.dataTransfer.getData("titolo");
        let params = {
            "id": `${id}`,
            "title": `${titolo}`,
            "subGroupList": subGroupList,
        }
        EprocRequest("POST", url, null, params, (err, data) => {
            data = JSON.parse(data);
            if (data.status != "OK") {
                console.error(data.result);
                $("#loader").hide();
            } else {
                reloadGroupsDashboard();
                setTimeout(() => {
                    let element = widgetContainer.querySelectorAll(`[identifier="${id}"]`)[0];
                    if (element) {
                        element.scrollIntoView({ behavior: "smooth" });
                    }
                }, 1000)
                
            }
        });

    };

    let listOfdropdownvapor = document.getElementsByClassName("dropdownvapor");
    for (let i = 0; i < listOfdropdownvapor.length; i++) {
        listOfdropdownvapor[i].firstChild.setAttribute("draggable", true);
        listOfdropdownvapor[i].firstChild.ondragend = (ev) => {
            widgetContainer.style.position = "";
            let div1 = widgetContainer.getElementsByClassName("dropHere");
            if (div1?.[0]) {
                widgetContainer.removeChild(div1?.[0]);
            }
        }
        listOfdropdownvapor[i].firstChild.ondragstart = (ev) => {
            console.log("start dragging " + listOfdropdownvapor[i].firstChild.id)

            widgetContainer.style.position = "relative";
            let div1 = document.createElement("div");
            div1.style.width = `calc(${widgetContainer.getBoundingClientRect().width}px)`
            div1.classList.add("dropHere")
            div1.innerHTML = `<div style="text-align:center; display:grid;"><i class="fa fa-plus" aria-hidden="true" style="padding: 20px 0; font-size: 70px;"></i>Rilascia qui</div>`;
            widgetContainer.appendChild(div1);

            /* dati per creare il div */
            let arrayOfLI = [];
            ev.dataTransfer.setData("id", ev.target.id);
            ev.dataTransfer.setData("icona", ev.target.id);
            ev.dataTransfer.setData("titolo", ev.target.getElementsByClassName("textMenu")[0].innerText);
            let listOfli = ev.target.parentElement.getElementsByClassName("submenuvapor")[0].getElementsByTagName("li");
            for (let i = 0; i < listOfli.length; i++) {
                arrayOfLI.push({
                    onclick: listOfli[i].firstChild.getAttribute("onclick"),
                    title: listOfli[i].firstChild.innerText
                })
            }
            ev.dataTransfer.setData("submenuvapor", JSON.stringify(arrayOfLI));
        }
    }
}

const emptyStateDrawer = (placeholder) => `
    <div class="emptyState">
        <div class="fa fa-list emptyStateFirstIcon"></div>
        <div class="fa fa-times-circle emptyStateSecondIcon"></div>
        <div class="emptyStateText" data-placeholder="${placeholder}""></div>
    </div>`;

let menusxGroups;
let recentActivityList;
let bookmarksList;
// POPOLO I GRUPPI DEL MENU DI SINITRA //

let menusx = document.getElementById("menu");
let url = `/api/${apiVersion}/Layout/Groups`;
if (menusx) {
    menusx.innerHTML = loader;
    EprocRequest("GET", url, null, null, (err, data) => {
        if (err) { throw err; }
        data = JSON.parse(data);
        if (data.status != "OK") {
            console.error(data.result);
            $("#loader").hide();
        } else {
            LoadMenuSX(data.result, true);
            initializeDragAndDrop();
        }
    }, true)
}

WriteButtonWorkspace();

//i menù gruppi sx sono salvati in cache nel localStorage (ultimo parametro EprocRequest passato a true)
let menusxSearch = document.getElementById("menuSXSearch");
if (menusxSearch) {
    menusxSearch.oninput = HandleMenuSXChange;
}

let buttonRecentActivity = document.getElementById("buttonRecentActivity");
if (buttonRecentActivity) {
    buttonRecentActivity.onclick = HandleButtonRecentActivityClick;
}

let buttonUserArea = document.getElementById("buttonUserArea");
if (buttonUserArea) {
    buttonUserArea.onclick = HandleButtonUserAreaClick;
}

let buttonUserUtility = document.getElementById("buttonUserUtility");
if (buttonUserUtility) {
    buttonUserUtility.onclick = HandleButtonUserUtilityClick;
}

let buttonWorkspace = document.getElementById("buttonWorkspace");
if (buttonWorkspace) {
    buttonWorkspace.onclick = HandleButtonWorkspaceClick;
}

let buttonBookmarks = document.getElementById("buttonBookmarks");
if (buttonBookmarks) {
    buttonBookmarks.onclick = HandleButtonBookmarksClick;
}

let buttonNotify = document.getElementById("buttonNotify");
if (buttonNotify) {
    buttonNotify.onclick = HandleButtonNotifyClick;
}




