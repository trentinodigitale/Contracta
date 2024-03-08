/// MODAL DELETE ///

const ModalDelete = (item) => {

    let emptyModal = document.getElementById("modalDelete");
    if (emptyModal) {
        emptyModal.remove();
    }

    const { title, text, callbackConfirm } = item;
    let container = document.getElementById("container");
    let modalDeleteContainer = document.createElement("div");
    modalDeleteContainer.id = "modalDelete";
    modalDeleteContainer.classList.add("modal");
    modalDeleteContainer.setAttribute("tabindex", "-1");
    modalDeleteContainer.setAttribute("role", "dialog");
    modalDeleteContainer.setAttribute("aria-labelledby", "modalDeleteLabel");
    modalDeleteContainer.setAttribute("aria-hidden", "true");
    let modalDialog = document.createElement("div");
    modalDialog.setAttribute("role", "document");
    modalDialog.classList.add("modal-dialog");
    let modalContent = document.createElement("div");
    modalContent.classList.add("modal-content");
    let modalHeader = document.createElement("div");
    modalHeader.classList.add("modal-header");
    modalHeader.classList.add("header-alert");
    let titleH5 = document.createElement("h5");
    titleH5.classList.add("modal-title");
    titleH5.id = "modalDeleteLabel";
    titleH5.innerText = title; //Titolo default
    let modalBody = document.createElement("div");
    modalBody.classList.add("modal-body");
    modalBody.innerText = text; //Testo default
    let modalFooter = document.createElement("div");
    modalFooter.classList.add("modal-footer");
    let buttonClose = document.createElement("button");
    buttonClose.classList.add("btn");
    buttonClose.classList.add("secondary-button");
    buttonClose.classList.add("closeModal");
    buttonClose.setAttribute("type", "button");
    buttonClose.setAttribute("data-dismiss", "modal");
    buttonClose.innerText = "Annulla"; //Testo default
    let buttonConfirm = document.createElement("button");
    buttonConfirm.classList.add("btn");
    buttonConfirm.classList.add("primary-alert");
    buttonConfirm.classList.add("deleteModelContent");
    buttonConfirm.setAttribute("type", "button");
    buttonConfirm.innerText = "Elimina"; //Testo default
    buttonConfirm.onclick = callbackConfirm;


    container.appendChild(modalDeleteContainer);
    modalDeleteContainer.appendChild(modalDialog);
    modalDialog.appendChild(modalContent);
    modalContent.appendChild(modalHeader);
    modalHeader.appendChild(titleH5);
    modalContent.appendChild(modalBody);
    modalContent.appendChild(modalFooter);
    modalFooter.appendChild(buttonClose);
    modalFooter.appendChild(buttonConfirm);

}

$(document).on("click", ".custom-modal", function (e) {
    e.preventDefault();
    $(".modal").toggleClass("open-modal");
});

$(document).on("click", ".closeModal", function (e) {
    e.preventDefault();
    $(".modal").removeClass("open-modal");
});

$(document).on("click", ".deleteModelContent", function (e) {
    e.preventDefault();
    $(".modal").removeClass("open-modal");
});

