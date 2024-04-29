$(document).ready(() => {
    loadAllWidgets();
})

var emptyState = `
    <div class="emptyState">
        <div class="fa fa-list emptyStateFirstIcon"></div>
        <div class="fa fa-times-circle emptyStateSecondIcon"></div>
        <div class="emptyStateText"></div>
    </div>`;

const loadAllWidgets = () => {
    let url = `/api/${apiVersion}/Widget`;
    EprocRequest("GET", url, null, null, (err, data) => {
        data = JSON.parse(data);
        if (data.status != "OK") {
            console.error(data.result);
            $("#loader").hide();
        } else {
            let listOfWidgets = data.result;
            let widgetContainer = document.getElementsByClassName("widget-container")[0];
            widgetContainer.innerHTML = "";
            for (let i = 0; i < listOfWidgets.length; i++) {
                //aggiungi loading a widget (il tipo ce l'ho già)
                let elementInserted = insertEmptyWidget(widgetContainer, listOfWidgets[i]);
                loadSingleWidget(listOfWidgets[i].code, elementInserted);
            }

            loadGroupsDashboard(widgetContainer);

        }
    })
}

const loadSingleWidget = (code, elementInserted) => {
    let url = `/api/${apiVersion}/Widget`;
    EprocRequest("GET", url + "/" + code, null, null, (err, dataSingleWidget) => {
        dataSingleWidget = JSON.parse(dataSingleWidget);
        if (dataSingleWidget.status != "OK") {
            console.error(dataSingleWidget);
            //errore caricamento singolo widget
        } else {
            insertFullWidget(elementInserted, dataSingleWidget.result);
        }
    })
}

const insertEmptyWidget = (container, widget) => {
    const { type } = widget;

    switch (type) {
        case 0://Base
            return insertEmptyWidgetBase(container, widget)
            break;
        case 1://List
        case 2://Group
            return insertEmptyWidgetList(container, widget)
            break;
        default:
    }

}

const insertEmptyWidgetBase = (container, widget) => {

    const { title } = widget;

    let div = document.createElement("div");
    div.classList.add("col-12");
    div.classList.add("col-md-6");
    div.classList.add("col-lg-3");
    div.innerHTML = `
        <div class="card-vapor">
            <div class="header">
                <div class="row"><div class="col title">${title}</div></div>

            </div>
            <div class="body">
                ${loader}
            </div>
            <div>
                
            </div>
        </div>
    `
    container.appendChild(div);

    return div;
}

const insertEmptyWidgetList = (container, widget) => {

    const { title } = widget;

    let div = document.createElement("div");
    div.classList.add("col-12");
    div.classList.add("col-md-6");
    div.classList.add("col-lg-6");
    div.classList.add("widget-list");
    div.innerHTML = `
        <div class="card-vapor">
            <div class="header">
                <div class="row">
                    <div class="col widget-list-container-title">
                        <span class="fa-lg"></span>                                        
                        <h5>${title}<h5>
                    </div>
                </div>

            </div>
            <div class="widget-list-body">
                ${loader}
            </div>
            <div>

            </div>
        </div>
    `
    container.appendChild(div);

    return div;
}

const insertFullWidget = (container, widget) => {
    const { type } = widget;

    switch (type) {
        case 0://Base
            insertWidgetBase(container, widget)
            break;
        case 1://List
        case 2://Group
            insertWidgetList(container, widget)
            break;
        default:
    }
}

const insertWidgetBase = (element, widget) => {

    const { params, code } = widget;
    const { title, body, cta } = params;
    let bodyParsed;
    if (body) {
        bodyParsed = JSON.parse(body);
    } else {
        bodyParsed = emptyState;
    }
    
    let footer = `<div></div>`;
    if (cta) {
        
        let ctaParsed = JSON.parse(cta);
        if (ctaParsed.length > 0) {
            footer = `
                <div class="footer">
                    <div class="justify-content-end row no-gutters">`;
            for (let i = 0; i < ctaParsed.length; i++) {
                const { text, action } = ctaParsed[i];
                footer += `
                    <div class="col primary-button" onclick="${action}">
                        ${text}
                    </div>`;
            }
            footer += `
                    </div>
                </div>`;
        }
    }

    element.innerHTML = `
            <div class="card-vapor widgetBase">
                ${code ? `<div class="fa fa-refresh reloadSingleBtnWidget" onclick="reloadSingleWidget(this, '${code}')"></div>` : ``}
                <div class="header">
                    <div class="row">
                        <div class="col title">
                        ${params?.icon ? `<span <i class="fa ${params?.icon}"></i></span>` : ``}    
                            ${title}
                        </div>
                    </div>

                </div>
                <div class="${body ? `body` : `h-100`}">
                    <p class="kpi-text">${bodyParsed}</p>
                </div>
                ${footer}
                ${code ? `<div class="lastUpdateWidget">Aggiornato alle ${lastUpdate()}</div>` : ``}
            </div>
    `;

}

const insertWidgetList = (element, widget) => {

    const { params, code } = widget;
    const { title, body } = params;
    
    const bodyParsed = JSON.parse(body);
    let rows = "";
    for (let i = 0; i < bodyParsed.length; i++) {
        const { text, action, subText, rightText, counterInfo } = bodyParsed[i];
        
        let firstCol = "";
        let secondCol = "";
        let thirdCol = "";

        if (text && rightText && action) {
            firstCol = "col-8 col-lg-9";
            secondCol = "col-2 text-right";
            thirdCol = "col-2 col-lg-1 favoriteIcon";
        }

        if (text && rightText && !action) {
            firstCol = "col-8 col-lg-9";
            secondCol = "col-2 text-right";
            thirdCol = "d-none";
        }


        if (text && !rightText && action) {
            firstCol = "col-10";
            secondCol = "d-none";
            thirdCol = "col-2 favoriteIcon";
        }

        if (counterInfo) {
            let url = `/api/${apiVersion}/Widget/GroupRowCounter`;
            EprocRequest("GET", url + `?counterInfo=${counterInfo}`, null, null, (err, data) => {
                data = JSON.parse(data);
                if (data.status != "OK") {
                    console.error(data);
                } else {
                    insertCounter(counterInfo, data);
                }
            })
        }



        rows += `
            <div ${counterInfo ? `id="${counterInfo}"` : ``} class="divider pb-3 pt-3 row widget-list-row">
                <div class="col-12 flex">
                    <div class="${firstCol}">
                        <p class=""><b>${counterInfo ? `<span class="counterLoader">(<span class="fa fa-spin fa-circle-o-notch fa-spin"></span>)</span>` : ``} ${text}</b></p>
                        ${subText ? `<p class="breadcrumbActivity">${subText}</p>` : ``}
                    </div>
                    <div class="${secondCol}">
                        ${rightText ? `<p class="timeActivity"><small>${rightText}</small></p>` : ``}
                    </div>
                    <div class="${thirdCol}">
                        ${action ? `<i class="fa fa-arrow-right" onclick="${action}" aria-hidden="true"></i>` : ``}
                    </div>
                </div>
            </div>
        `
    }

    if (bodyParsed?.length === 0) {
        rows = emptyState;
    }
    element.innerHTML = `
        <div class="card-vapor widgetList">
            ${code ? `<div class="fa fa-refresh reloadSingleBtnWidget" onclick="reloadSingleWidget(this, '${code}')"></div>` : ``}
            <div class="header">
                <div class="row">
                    <div class="col widget-list-container-title">
                        ${params?.icon ? `<span class="fa-lg"><i class="fa ${params?.icon}"></i></span>` : ``}                                      
                        <h5>${title}</h5><h5>
                    </h5></div>
                </div>

            </div>
            <div class="widget-list-body">
                ${rows}
            <div>
            ${code ? `<div class="lastUpdateWidget">Aggiornato alle ${lastUpdate()}</div>` : ``}
        </div>
    `
    let bodyElement = element.getElementsByClassName("widget-list-body")[0];
    let tempInterval = setInterval(() => {
        if (bodyElement.getAttribute("to") === "reverse") {
            bodyElement.scrollTo({ top: bodyElement.scrollTop - 100, behavior: 'smooth' });
        } else {
            bodyElement.scrollTo({ top: bodyElement.scrollTop + 100, behavior: 'smooth' });
        }
        if (bodyElement.scrollTop + bodyElement.getBoundingClientRect().height === bodyElement.scrollHeight) {
            bodyElement.setAttribute("to", "reverse");
        } else if (bodyElement.scrollTop === 0) {
            bodyElement.setAttribute("to", null);
        }
    }, 3000);
    bodyElement.addEventListener("mouseenter", () => {
        clearInterval(tempInterval);
    })




}

const insertCounter = (id, data) => {
    let elem = document.getElementById(id);
    let target = elem.getElementsByClassName("counterLoader")[0];
    target.innerText = data.result > -1 ? `(${data.result})` : ``;
    if (elem.closest(".card-vapor") && elem.closest(".card-vapor").getElementsByClassName("lastUpdateWidget").length != 0) {
        elem.closest(".card-vapor").getElementsByClassName("lastUpdateWidget")[0].innerText = `Aggiornato alle ${lastUpdate()}`;
    }
}

const insertGroupWidget = (widgetContainer, group) => {
    
    const { id, title, subGroupList } = group;
    let widget = {
        title: title
    }
    let element = insertEmptyWidgetList(widgetContainer, widget);
    element.classList.add("widgetGroup");

    let body = [];
    for (let i = 0; i < subGroupList.length; i++) {
        body.push({
            text: subGroupList[i].title,
            action: subGroupList[i].link,
        })
    }

    let strBody = JSON.stringify(body);

    let widgetFull = {
        params: {
            body: strBody,
            icon: "fa-list",
            title: title,
        }
    };

    insertWidgetList(element, widgetFull);

    //setto l'id per applicare la custom icon (se indicata nei file css)
    let headerOfElement = element.getElementsByClassName("header")[0]
    headerOfElement.setAttribute("id", id);
    headerOfElement.setAttribute("identifier", id);

    let btnDeleteGroup = document.createElement("button");
    let span = document.createElement("span");
    let i = document.createElement("i");

    i.classList.add("fa");
    i.classList.add("fa-times");
    span.appendChild(i);
    btnDeleteGroup.classList.add("deleteGroup");
    btnDeleteGroup.appendChild(span);
    btnDeleteGroup.onclick = () => {
        deleteGroupFromDashboard(id, title, subGroupList);
    }

    headerOfElement.getElementsByClassName("row")[0].appendChild(btnDeleteGroup);



}

const deleteGroupFromDashboard = (idGroup, title, subGroupList) => {
    let url = `/api/${apiVersion}/Layout/DeleteWidgetGroup`;
    let params = {
        id: `${idGroup}`,
        title: title,
        subGroupList: subGroupList
    }
    EprocRequest("DELETE", url, null, params, (err, data) => {
        data = JSON.parse(data);
        if (data.status != "OK") {
            console.error(data.result);
            $("#loader").hide();
        } else {
            reloadGroupsDashboard();
        }
    });




}

const reloadGroupsDashboard = () => {
    let widgetContainer = document.getElementsByClassName("widget-container")[0];
    let listOfWidgetsGroup = widgetContainer.getElementsByClassName("widgetGroup");
    let originalLength = listOfWidgetsGroup.length;
    for (let i = 0; i < originalLength; i++) {
        listOfWidgetsGroup[0].remove();
    }
    loadGroupsDashboard(widgetContainer);
}

const loadGroupsDashboard = (widgetContainer) => {
    EprocRequest("GET", `/api/${apiVersion}/Widget/GroupsWidget`, null, null, (err, data) => {
        data = JSON.parse(data);
        if (data.status != "OK") {
            console.error(data);
        } else {
            for (let i = 0; i < data.result.length; i++) {
                insertGroupWidget(widgetContainer, data.result[i])
            }

        }
    })
}

const reloadSingleWidget = (item, guid) => {
    let elem = item.closest(".card-vapor");
    let body = elem.getElementsByClassName("body")[0] || elem.getElementsByClassName("widget-list-body")[0] || elem.getElementsByClassName("h-100")[0];
    if (body) {
        body.innerHTML = loader;
    }

    loadSingleWidget(guid, elem.parentElement);
}

const lastUpdate = () => {
    let currentDate = new Date();
    let currentHH = currentDate.getHours().toString().length == 1 ? `0${currentDate.getHours()}` : currentDate.getHours();
    let currentMM = currentDate.getMinutes().toString().length == 1 ? `0${currentDate.getMinutes()}` : currentDate.getMinutes();
    let currentSS = currentDate.getSeconds().toString().length == 1 ? `0${currentDate.getSeconds()}` : currentDate.getSeconds();
    let lastUpd = `${currentHH}:${currentMM}:${currentSS}`;
    return lastUpd;
}

