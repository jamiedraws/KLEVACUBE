import OrderForm from "ts/applications/form";

import {
    initializeExpressCheckout,
    initializeValidateCommon
} from "Shared/ts/applications/form";


initializeExpressCheckout();

const of = new OrderForm();

of.handleOfferChange();
of.validateOffers();