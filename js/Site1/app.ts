// components
import Accordion from "Shared/ts/components/accordion";
import Carousel from "Shared/ts/components/carousel";

// adapters
import SlideCarouselAdapter from "Shared/ts/api/carousel/slide/adapters/slide-carousel";

// observers
import { observer } from "Shared/ts/observers/intersection";

// utils
import {
    initializePartialView,
    initializePartialViewControllersByObserver
} from "Shared/ts/utils/partial-view";

// applications
import {
    initializeBase,
    initializeMicrosite
} from "Shared/ts/applications/template";

import {
    importScrollableHeightByElement,
    initializeNavById
} from "Shared/ts/applications/navigation";

import {
    initalizeDocumentModalDialogsByDOMMutation,
    initializeDocumentModalDialogsByTemplates
} from "Shared/ts/applications/modal-dialog";

// api
import ModalDialogVimeoIframe from "Shared/ts/api/modal/modal-dialog-vimeo-iframe";

const initializeScrollableNav = () => {
    const nav = initializeNavById("nav");

    const root = nav?.root;
    if (!root) return;

    importScrollableHeightByElement(root);

    observer("#nav-tracker", {
        inRange: (element) => {
            root.classList.remove("nav--use-small-logo");
        },
        outRange: (element) => {
            root.classList.add("nav--use-small-logo");
        },
        unObserve: false
    });
};

initializeScrollableNav();

initializeBase();
initializeMicrosite();

const modalDialogIframe = new ModalDialogVimeoIframe();
modalDialogIframe.initializeObserver();
modalDialogIframe.initializeCapture();

initializeDocumentModalDialogsByTemplates();
initalizeDocumentModalDialogsByDOMMutation();

observer(".slide--carousel", {
    inRange: (element) => {
        const carousel = new Carousel(new SlideCarouselAdapter(element));

        carousel.enablePrevNextControls();
        carousel.autoplay();
    }
});

Array.from(document.querySelectorAll(".accordion")).map(
    (accordion) => new Accordion(accordion)
);

initializePartialView();
initializePartialViewControllersByObserver();
